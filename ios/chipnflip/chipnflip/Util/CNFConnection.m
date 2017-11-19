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

NSString *const	CNFConnectionKey					= @"994095a2c453e06bd4c1";
NSString *const	CNFConnectionServerIP				= @"http://172.16.12.51:80/api";
NSString *const	CNFConnectionAPIVersion				= @"v1";

@interface CNFConnection() {
	BOOL			_work;
	PTPusher 		*_pusher;
	PTPusherChannel *_channel;
	
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

- (int) _pusherSetup {
	CNFLog(@"");
	
	_pusher = [PTPusher pusherWithKey:CNFConnectionKey delegate:self encrypted:YES cluster:@"eu"];
	if (!_pusher) {
		CNFLog(@"no pusher");
		return -1;
	}
	
	[_pusher connect];
	return 0;
}

- (int) pusherSubscribeChannel:(NSString *) channelName {
	CNFLog(@"");
	
	_channel = [_pusher subscribeToChannelNamed:channelName];
	if (!_channel) {
		CNFLog(@"no channel");
		return -1;
	}
	
	return 0;
}

- (void) pusherUnsubscribeAll {
	CNFLog(@"");
	
	if (_pusher && _channel)
		[_pusher unsubscribeAllChannels];
}

- (int) pusherBindToEvent:(NSString *) eventName {
	CNFLog(@"");
	
	PTPusherEventBinding *binding = [_channel bindToEventNamed:eventName handleWithBlock:
									 ^(PTPusherEvent *channelEvent) {
										 CNFLog(@"data");
										 [self _addRX:channelEvent.data];
	}];
	
	if (!binding) {
		CNFLog(@"no binding");
		return -1;
	}
	
	return 0;
}

- (void) pusherUnbindAll {
	CNFLog(@"");
	
	if (_channel)
		[_channel removeAllBindings];
}

-(void) _postString:(NSString *) suffix json:(NSString *) json header:(NSDictionary *) header method:(NSString *) method {
	NSData				*data		= [json dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSMutableURLRequest	*request	= [[NSMutableURLRequest alloc] init];
	NSString			*urlstr		= [NSString stringWithFormat:@"%@/%@/%@", CNFConnectionServerIP, CNFConnectionAPIVersion, suffix];
	
	[request setURL:[NSURL URLWithString:urlstr]];
	[request setHTTPMethod:method];
	
	for (NSString *key in [header allKeys]) {
		NSString	*value = [header valueForKey:key];
		
		CNFLog(@"value %@ key %@", value, key);
		[request setValue:value forHTTPHeaderField:key];
	}
	
	[request setHTTPBody:data];
	
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	
	NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error && error.code)
			CNFLog(@"err code %@ %@", @(error.code), error.domain);
		
		NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		CNFLog(@"result %@", result);
		
		if (data && data.length) {
			NSError			*parse;
			NSDictionary	*json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parse];
			
			[self _addRX:json];
		}
	}];
	
	[postDataTask resume];
}

- (void) _notifyRecv:(NSDictionary *) rxitem {
	NSArray		*delegates = [self _getDelegates];
	
	for (id <CNFConnectionDelegate> delegate in delegates) {
		if ([delegate respondsToSelector:@selector(recvData:)])
			[delegate recvData:rxitem];
	}
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
		
		for (NSDictionary *rxitem in tmp)
			[self _notifyRecv:rxitem];
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
		
		for (NSDictionary *txitem in tmp) {
			NSError			*error;
			NSDictionary	*jsonDict	= [txitem objectForKey:@"json"];
			NSDictionary	*header		= [txitem objectForKey:@"header"];
			NSString		*suffix		= [txitem objectForKey:@"suffix"];
			NSString		*method		= [txitem objectForKey:@"method"];
			NSData			*jsonData	= [NSJSONSerialization dataWithJSONObject:jsonDict
																 options:NSJSONWritingPrettyPrinted
																   error:&error];
			
			if (!jsonData)
				CNFLog(@"Got an error: %@", error);
			else {
				NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
				[self _postString:suffix json:json header:header method:method];
			}
		}
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

- (int) _addRX:(NSDictionary *) dict {
	[_rxcond lock];
	[_rxarray addObject:dict];
	[_rxcond signal];
	[_rxcond unlock];
	
	return 0;
}

- (int) send:(NSDictionary *) json suffix:(NSString *) suffix method:(NSString *) method header:(NSDictionary *) header {
	CNFLog(@"");
	
	[_txcond lock];
	[_txarray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						 suffix, @"suffix",
						 json, @"json",
						 method, @"method",
						 header, @"header", nil]];
	[_txcond signal];
	[_txcond unlock];
	
	return 0;
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
