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

@implementation CNFMove

@end

typedef NS_ENUM(NSUInteger, CNFState) {
	CNFStateNone = 0,
	CNFStateLoggedin,
	CNFStateSubscribe,
	CNFStateSubscribed,
};

NSString *const	CNFConnectionSuffixRegistration		= @"user";
NSString *const	CNFConnectionSuffixLogin			= @"login";
NSString *const	CNFConnectionSuffixSubscribe		= @"game-offer";
NSString *const	CNFConnectionSuffixStep				= @"step";
NSString *const	CNFConnectionSuffixLogout			= @"logout";

NSString *const	CNFConnectionToken					= @"token";
NSString *const	CNFConnectionUserID					= @"user_id";
NSString *const	CNFConnectionGameInfo				= @"game_info";
NSString *const	CNFConnectionGameID					= @"game_id";
NSString *const	CNFConnectionGameKey				= @"game_key";
NSString *const	CNFConnectionChannel				= @"channel";
NSString *const	CNFConnectionTurnUserID				= @"turn_user_id";

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

- (void) _notifyStepWait {
	NSArray	*delegates = [self _getDelegates];
	
	dispatch_sync(dispatch_get_main_queue(), ^(void) {
		for (id <CNFParserDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(serverStepWait)])
				[delegate serverStepWait];
		}
	});
}

- (void) _notifyStepReady {
	NSArray	*delegates = [self _getDelegates];
	
	dispatch_sync(dispatch_get_main_queue(), ^(void) {
		for (id <CNFParserDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(serverStepReady)])
				[delegate serverStepReady];
		}
	});
}

- (void) _notifyFieldUpdate:(NSArray *) array {
	NSArray	*delegates = [self _getDelegates];
	
	dispatch_sync(dispatch_get_main_queue(), ^(void) {
		for (id <CNFParserDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(serverFields:)])
				[delegate serverFields:array];
		}
	});
}

- (void) _parseToken:(NSDictionary *) json {
	_token = [json objectForKey:CNFConnectionToken];
	_userid = [json objectForKey:CNFConnectionUserID];
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

- (void) _parseSnapshot:(NSDictionary *) json {
	CNFLog(@"");
	
	NSDictionary	*snap	= [json objectForKey:@"snapshot"];
	NSNumber		*turnid	= [snap objectForKey:CNFConnectionTurnUserID];
	NSArray			*rows	= [snap valueForKey:@"field"];
	
	if ([turnid isEqualToNumber:_userid])
		[self _notifyStepWait];
	else
		[self _notifyStepReady];
	
	[self _notifyFieldUpdate:rows];
}

- (void) _parseGameInfo:(NSDictionary *) json {
	CNFLog(@"");
	
	NSDictionary	*gameInfo = [json objectForKey:CNFConnectionGameInfo];
	if (!gameInfo) {
		CNFLog(@"no game info");
		return;
	}
	
	_gamekey = [gameInfo objectForKey:CNFConnectionGameKey];
	if (!_gamekey) {
		CNFLog(@"no gamekey");
		return;
	}
	
	NSArray *users = [gameInfo objectForKey:@"users"];
	if (!users) {
		CNFLog(@"no users");
		return;
	}
	
	for (NSDictionary *u in users) {
		NSNumber *userid = [u objectForKey:CNFConnectionUserID];
		if ([userid longValue] != [_userid longValue]) {
			_peerName = [u objectForKey:@"name"];
			_peerid = [u objectForKey:CNFConnectionUserID];
		}
	}
	
	_prize = [gameInfo objectForKey:@"prize"];
	_gameid = [gameInfo objectForKey:CNFConnectionGameID];
	
	[self _parseSnapshot:gameInfo];
}

- (void) _parseChannel:(NSDictionary *) json {
	_channel = [json objectForKey:CNFConnectionChannel];
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
	NSDictionary	*gameInfo = [json objectForKey:CNFConnectionGameInfo];
	if (gameInfo) {
		_state = CNFStateSubscribed;
		
		[self _parseGameInfo:json];
		[self _notifyGameReady];
	}
}

- (void) _parseFields:(NSDictionary *) json {
	[self _parseSnapshot:json];
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
			[self _parseFields:json];
			break;
	}
}

- (id) init {
	self = [super init];
	
	if (self) {
		[self _shutdown];
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
	
	return [_connection send:json suffix:CNFConnectionSuffixRegistration method:@"POST" header:header];
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

- (int) step:(CNFMove *) from to:(CNFMove *) to {
	CNFLog(@"");
	
	if (_state < CNFStateSubscribed)
		return -1;
	
	NSString *sfrom = [NSString stringWithFormat:@"%@:%@", @(from.x), @(from.y)];
	NSString *sto = [NSString stringWithFormat:@"%@:%@", @(to.x), @(to.y)];
	NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:
						  _userid, CNFConnectionUserID,
						  _gameid, CNFConnectionGameID,
						  _gamekey, CNFConnectionGameKey,
						  sfrom, @"from",
						  sto, @"to", nil];
	
	NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
							@"application/json", @"Content-Type",
							@"application/json", @"Accept", nil];
	
	return [_connection send:json suffix:CNFConnectionSuffixStep method:@"POST" header:header];
}

- (int) logout {
	CNFLog(@"");
	
	if (_state < CNFStateLoggedin)
		return -1;
	
	NSString *bearer = [NSString stringWithFormat:@"Bearer %@", _token];
	NSDictionary *json = [[NSDictionary alloc] init];
	NSDictionary *header = [NSDictionary dictionaryWithObjectsAndKeys:
							@"application/json", @"Content-Type",
							@"application/json", @"Accept",
							bearer, @"Authorization",nil];
	
	[self _shutdown];
	
	return [_connection send:json suffix:CNFConnectionSuffixLogout method:@"GET" header:header];
}

- (void) _shutdown {
	CNFLog(@"");
	
	[_connection pusherUnbindAll];
	[_connection pusherUnsubscribeAll];
	
	_state		= CNFStateNone;
	_user		= @"";
	_money		= [NSNumber numberWithLong:0];
	_token		= @"";
	_channel	= @"";
	_userid		= [NSNumber numberWithLong:0];
	_peerid		= [NSNumber numberWithLong:0];
	_peerName	= @"";
	_prize		= [NSNumber numberWithLong:0];
	_gameid		= [NSNumber numberWithLong:0];
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
