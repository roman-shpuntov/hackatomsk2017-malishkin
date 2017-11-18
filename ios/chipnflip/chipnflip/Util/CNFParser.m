//
//  CNFParser.m
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "CNFParser.h"
#import "CNFLog.h"
#import "CNFWeakArray.h"

typedef NS_ENUM(NSUInteger, CNFState) {
	CNFStateNone = 0,
	CNFStateLoggedin,
	CNFStateSubscribe,
	CNFStateSubscribed,
};

NSString *const	CNFConnectionSuffixRegistration		= @"user";
NSString *const	CNFConnectionSuffixLogin			= @"login";
NSString *const	CNFConnectionSuffixSubscribe		= @"game-offer";
NSString *const	CNFConnectionSuffixLogout			= @"logout";

NSString *const	CNFConnectionLoginAnswerToken		= @"token";
NSString *const	CNFConnectionLoginAnswerUserID		= @"user_id";
NSString *const	CNFConnectionSubscribeAnswerChannel	= @"channel";

NSString *const	CNFConnectionEventOfferAccepted		= @"offer-accepted";
NSString *const	CNFConnectionEventGridUpdated		= @"grid-updated";
NSString *const	CNFConnectionEventGameEnded			= @"game-ended";

@interface CNFParser() {
	CNFConnection	*_connection;
	NSMutableArray	*_delegates;
	CNFState		_state;
}

@end

@implementation CNFParser

- (NSArray *) _getDelegates {
	NSArray		*delegates;
	
	@synchronized(self) {
		delegates = [NSArray arrayWithArray:_delegates];
	}
	
	return delegates;
}

- (void) _notifyError:(NSString *) str {
	NSError	*error = [[NSError alloc] initWithDomain:str code:-1 userInfo:nil];
	NSArray	*delegates = [self _getDelegates];
	
	dispatch_sync(dispatch_get_main_queue(), ^(void) {
		for (id <CNFParserDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(serverError:)])
				[delegate serverError:error];
		}
	});
}

- (void) _notifyLoginReady {
	NSArray	*delegates = [self _getDelegates];
	
	dispatch_sync(dispatch_get_main_queue(), ^(void) {
		for (id <CNFParserDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(serverLoginReady:)])
				[delegate serverLoginReady:_token];
		}
	});
}

- (void) _notifyGameReady {
	NSArray	*delegates = [self _getDelegates];
	
	dispatch_sync(dispatch_get_main_queue(), ^(void) {
		for (id <CNFParserDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(serverGameReady:)])
				[delegate serverGameReady:_peerName];
		}
	});
}

- (void) _parseToken:(NSDictionary *) json {
	_token = [json objectForKey:CNFConnectionLoginAnswerToken];
	_userid = [json objectForKey:CNFConnectionLoginAnswerUserID];
	if ((!_token || [_token isEqualToString:@""]) || !_userid) {
		_token = @"";
		_userid = [NSNumber numberWithLong:0];
		CNFLog(@"error no token");
	}
	else {
		_state = CNFStateLoggedin;
		CNFLog(@"got token %@ user id %@", _token, _userid);
		[self _notifyLoginReady];
	}
}

- (void) _parseGameInfo:(NSDictionary *) json {
	CNFLog(@"");
	
	NSDictionary	*gameInfo = [json objectForKey:@"game_info"];
	if (!gameInfo) {
		CNFLog(@"no game info");
		return;
	}
	
	NSArray *users = [gameInfo objectForKey:@"users"];
	if (!users) {
		CNFLog(@"no users");
		return;
	}
	
	for (NSDictionary *u in users) {
		NSNumber *userid = [u objectForKey:@"user_id"];
		if ([userid longValue] != [_userid longValue])
			_peerName = [u objectForKey:@"name"];
	}
}

- (void) _parseChannel:(NSDictionary *) json {
	_channel = [json objectForKey:CNFConnectionSubscribeAnswerChannel];
	if (!_channel || [_channel isEqualToString:@""]) {
		_channel = @"";
		CNFLog(@"error no channel name");
	}
	else {
		_state = CNFStateSubscribe;
		CNFLog(@"got channel name %@", _channel);
		
		if ([_connection pusherSubscribeChannel:_channel]) {
			CNFLog(@"error on pusherSubscribeChannel");
			return;
		}
		
		if ([_connection pusherBindToEvent:CNFConnectionEventOfferAccepted]) {
			CNFLog(@"error on pusherBindToEvent CNFConnectionEventOfferAccepted");
			return;
		}

		if ([_connection pusherBindToEvent:CNFConnectionEventGridUpdated]) {
			CNFLog(@"error on pusherBindToEvent CNFConnectionEventGridUpdated");
			return;
		}

		if ([_connection pusherBindToEvent:CNFConnectionEventGameEnded]) {
			CNFLog(@"error on pusherBindToEvent CNFConnectionEventGameEnded");
			return;
		}
		
		[self _parseSubscribe:json];
	}
}

- (void) _parseSubscribe:(NSDictionary *) json {
	NSDictionary	*gameInfo = [json objectForKey:@"game_info"];
	if (gameInfo) {
		_state = CNFStateSubscribed;
		
		[self _parseGameInfo:json];
		[self _notifyGameReady];
	}
}

- (void)recvData:(NSDictionary *) json {
	NSString	*string = [json objectForKey:@"error"];
	if (string && ![string isEqualToString:@""]) {
		[self _notifyError:string];
		return;
	}
	
	switch (_state) {
		case CNFStateNone:
			[self _parseToken:json];
			break;
			
		case CNFStateLoggedin:
			[self _parseChannel:json];
			break;
			
		case CNFStateSubscribe:
			[self _parseSubscribe:json];
			break;
			
		default:
		case CNFStateSubscribed:
			break;
	}
}

- (id) init {
	self = [super init];
	
	if (self) {
		_delegates	= [NSMutableArray mutableArrayUsingWeakReferences];
		_connection	= [CNFConnection sharedInstance];
		[_connection addDelegate:self];
		[_connection start];
	}
	return self;
}

+ (CNFParser *) sharedInstance {
	static dispatch_once_t onceToken;
	static CNFParser *instance = nil;
	
	dispatch_once(&onceToken, ^{
		instance = [[CNFParser alloc] init];
	});
	
	return instance;
}

- (void) dealloc {
	CNFLog(@"");
	
	[_connection removeDelegate:self];
}

- (int) registration:(NSString *) name email:(NSString *) email password:(NSString *) password {
	CNFLog(@"name '%@' email '%@' password '%@'", name, email, password);
	
	if (_state >= CNFStateLoggedin)
		return -1;
	
	NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
						  name, @"name",
						  email, @"email",
						  password, @"password", nil];
	
	NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
							   @"application/json", @"Content-Type",
							   @"application/json", @"Accept", nil];
	
	return [_connection send:json suffix:CNFConnectionSuffixLogin method:@"POST" header:header];
}

- (int) login:(NSString *) email password:(NSString *) password {
	CNFLog(@"email '%@' password '%@'", email, password);
	
	if (_state >= CNFStateLoggedin)
		return -1;
	
	NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
						  email, @"email",
						  password, @"password", nil];
	
	NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
							   @"application/json", @"Content-Type",
							   @"application/json", @"Accept", nil];
	
	return [_connection send:json suffix:CNFConnectionSuffixLogin method:@"POST" header:header];
}

- (int) startGame {
	CNFLog(@"");
	
	if (_state < CNFStateLoggedin)
		return -1;
	
	NSString *bearer = [NSString stringWithFormat:@"Bearer %@", _token];
	NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"free", @"type",
						  [NSNumber numberWithLong:10], @"bet", nil];
	
	NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
							@"application/json", @"Content-Type",
							@"application/json", @"Accept",
							bearer, @"Authorization", nil];
	
	return [_connection send:json suffix:CNFConnectionSuffixSubscribe method:@"POST" header:header];
}

- (int) logout {
	CNFLog(@"");
	
	if (_state < CNFStateSubscribed)
		return -1;
	
	NSString *bearer = [NSString stringWithFormat:@"Bearer %@", _token];
	NSDictionary *json = [[NSDictionary alloc] init];
	NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
							@"application/json", @"Content-Type",
							@"application/json", @"Accept",
							bearer, @"Authorization",nil];
	
	return [_connection send:json suffix:CNFConnectionSuffixLogout method:@"GET" header:header];
}

- (void) addDelegate:(id <CNFParserDelegate> ) delegate {
	@synchronized(self) {
		[_delegates addObject:delegate];
	}
	CNFLog(@"delegates %@", @(_delegates.count));
}

- (void) removeDelegate:(id <CNFParserDelegate> ) delegate {
	@synchronized(self) {
		[_delegates removeObject:delegate];
	}
	CNFLog(@"delegates %@", @(_delegates.count));
}

@end
