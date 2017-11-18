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
	BOOL			_work;
	PTPusher 		*_pusher;
	
	NSMutableArray	*_rxarray;
	NSMutableArray	*_txarray;
	
	NSCondition		*_rxcond;
	NSCondition		*_txcond;
	
	NSThread		*_rxthread;
	NSThread		*_txthread;

	NSMutableArray	*_delegates;
}
@end

@implementation CNFConnection

- (NSArray *) _getDelegates {
	NSArray		*delegates;
	
	@synchronized(self) {
		delegates = [NSArray arrayWithArray:_delegates];
	}
	
	return delegates;
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillConnect:(PTPusherConnection *)connection {
	CNFLog(@"connectionWillConnect");
	return YES;
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection {
	CNFLog(@"connectionDidConnect");
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect {
	CNFLog(@"didDisconnectWithError");
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error {
	CNFLog(@"failedWithError");
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay {
	CNFLog(@"connectionWillAutomaticallyReconnect");
	return YES;
}

- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withAuthOperation:(PTPusherChannelAuthorizationOperation *)operation {
	CNFLog(@"willAuthorizeChannel");
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
	CNFLog(@"didSubscribeToChannel %@", channel.name);
}

- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel {
	CNFLog(@"didUnsubscribeFromChannel %@", channel.name);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error {
	CNFLog(@"didFailToSubscribeToChannel %@ %@", channel.name, error.domain);
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent {
	CNFLog(@"didReceiveErrorEvent %@", errorEvent.message);
}

- (void) _pusherSetup {
	CNFLog(@"");
	
	_pusher = [PTPusher pusherWithKey:CNFConnectionKey delegate:self encrypted:YES cluster:@"eu"];
	[_pusher connect];
}

-(void) _rxProcessing:(NSNumber *) number {
	NSArray			*tmp = [[NSArray alloc] init];
	
	while (_work) {
		[_rxcond lock];
		
		while (!_rxarray.count)
			[_rxcond wait];
		
		tmp = [NSArray arrayWithArray:_rxarray];
		_rxarray = [[NSMutableArray alloc] init];
		[_rxcond unlock];
	}
}

-(void) _txProcessing:(NSNumber *) number {
	NSArray	*tmp = [[NSArray alloc] init];
	
	while (_work) {
		[_txcond lock];
		
		while (!_txarray.count)
			[_txcond wait];
		
		tmp = [NSArray arrayWithArray:_txarray];
		_txarray = [[NSMutableArray alloc] init];
		[_txcond unlock];
	}
}

- (id) init {
	self = [super init];
	
	if (self) {
		_work		= NO;
		_rxcond		= [[NSCondition alloc] init];
		_txcond		= [[NSCondition alloc] init];
		_rxarray	= [[NSMutableArray alloc] init];
		_txarray	= [[NSMutableArray alloc] init];
		_delegates	= [NSMutableArray mutableArrayUsingWeakReferences];
		_rxthread	= [[NSThread alloc] initWithTarget:self
											selector:@selector(_rxProcessing:)
											  object:nil];
		_txthread	= [[NSThread alloc] initWithTarget:self
											selector:@selector(_txProcessing:)
											  object:nil];
		
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

- (void) start {
	CNFLog(@"");
	
	_work = YES;
	[_txthread start];
	[_rxthread start];
}

- (void) stop {
	CNFLog(@"");
	
	_work = NO;
	[_txthread cancel];
	[_rxthread cancel];
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
