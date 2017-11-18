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

@interface CNFParser() {
	CNFConnection	*_connection;
	NSMutableArray	*_delegates;
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

- (void) _notifyData:(NSString *) str {
	NSArray	*delegates = [self _getDelegates];
	
	dispatch_sync(dispatch_get_main_queue(), ^(void) {
		for (id <CNFParserDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(serverData:)])
				[delegate serverData:str];
		}
	});
}

- (void) _notifyLoginReady:(NSString *) token channel:(NSString *) channel {
	NSArray	*delegates = [self _getDelegates];
	
	dispatch_sync(dispatch_get_main_queue(), ^(void) {
		for (id <CNFParserDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(serverLoginReady:channel:)])
				[delegate serverLoginReady:token channel:channel];
		}
	});
}

- (void) _notifyGameReady:(NSString *) userName {
	NSArray	*delegates = [self _getDelegates];
	
	dispatch_sync(dispatch_get_main_queue(), ^(void) {
		for (id <CNFParserDelegate> delegate in delegates) {
			if ([delegate respondsToSelector:@selector(serverGameReady:)])
				[delegate serverGameReady:userName];
		}
	});
}

- (void)recvData:(NSDictionary *)dict {
	NSString	*string = [dict objectForKey:@"error"];
	if (string && ![string isEqualToString:@""]) {
		[self _notifyError:string];
		return;
	}
	
	string = [dict objectForKey:@"channel"];
	if (string && ![string isEqualToString:@""]) {
		//[self _notifyGameReady:];
		return;
	}
	
	[self _notifyData:string];
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

- (void) registration:(NSString *) name email:(NSString *) email password:(NSString *) password {
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", email, @"email", password, @"password", nil];
	
	CNFLog(@"name '%@' email '%@' password '%@'", name, email, password);
	[_connection registration:dict];
}

- (void) login:(NSString *) email password:(NSString *) password {
	NSDictionary	*dict = [NSDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", nil];
	
	CNFLog(@"email '%@' password '%@'", email, password);
	[_connection login:dict];
}

- (void) logout {
	NSDictionary	*dict = [[NSDictionary alloc] init];
	
	CNFLog(@"");
	[_connection logout:dict];
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
