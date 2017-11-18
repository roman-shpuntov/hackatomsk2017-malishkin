//
//  CNFConnection.m
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "CNFConnection.h"
#import "CNFLog.h"
#import "CNFWeakArray.h"

NSString *const	CNFConnectionKey				= @"994095a2c453e06bd4c1";

@interface CNFConnection() {
	PTPusher 		*_pusher;
	
	NSMutableArray	*_delegates;
}
@end

@implementation CNFConnection

- (void) _pusherSetup {
	CNFLog(@"");
	
	_pusher = [PTPusher pusherWithKey:CNFConnectionKey delegate:self encrypted:YES cluster:@"eu"];
	[_pusher connect];
}

- (id) init {
	self = [super init];
	
	if (self) {
		_delegates	= [NSMutableArray mutableArrayUsingWeakReferences];
		
		[self _pusherSetup];
	}
	return self;
}

+ (CNFConnection *) sharedInstance {
	static dispatch_once_t onceToken;
	static CNFConnection *instance = nil;
	
	dispatch_once(&onceToken, ^{
		instance = [[CNFConnection alloc] init];
	});
	
	return instance;
}

- (void) dealloc {
	CNFLog(@"");
}

- (void) addDelegate:(id <CNFConnectionDelegate> ) delegate {
	@synchronized(self) {
		[_delegates addObject:delegate];
	}
	
	CNFLog(@"delegates %@", @(_delegates.count));
}

- (void) removeDelegate:(id <CNFConnectionDelegate> ) delegate {
	@synchronized(self) {
		[_delegates removeObject:delegate];
	}
	
	CNFLog(@"delegates %@", @(_delegates.count));
}

@end
