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
NSString *const	CNFConnectionServerIP			= @"http://172.16.12.51:80/api";
NSString *const	CNFConnectionAPIVersion			= @"v1";

NSString *const	CNFConnectionSuffixRegistration	= @"user";
NSString *const	CNFConnectionSuffixLogin		= @"login";
NSString *const	CNFConnectionSuffixLogout		= @"logout";

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

-(void) _postString:(NSString *) suffix json:(NSString *) json {
	NSData				*data		= [json dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSMutableURLRequest	*request	= [[NSMutableURLRequest alloc] init];
	NSString			*urlstr		= [NSString stringWithFormat:@"%@/%@/%@", CNFConnectionServerIP, CNFConnectionAPIVersion, suffix];
	
	[request setURL:[NSURL URLWithString:urlstr]];
	if ([suffix isEqualToString:CNFConnectionSuffixRegistration]) {
		[request setHTTPMethod:@"POST"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	}
	else if ([suffix isEqualToString:CNFConnectionSuffixLogin]) {
		[request setHTTPMethod:@"POST"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	}
	else if ([suffix isEqualToString:CNFConnectionSuffixLogout]) {
		NSString	*bearer = [NSString stringWithFormat:@"Bearer %@", _token];
		
		[request setHTTPMethod:@"GET"];
		[request setValue:bearer forHTTPHeaderField:@"Authorization"];
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
			NSDictionary	*dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parse];
			
			[_rxcond lock];
			[_rxarray addObject:dict];
			[_rxcond signal];
			[_rxcond unlock];
		}
	}];
	
	[postDataTask resume];
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
		
		for (NSDictionary *txitem in tmp) {
			NSError			*error;
			NSDictionary	*jsonDict	= [txitem objectForKey:@"json"];
			NSString		*suffix		= [txitem objectForKey:@"suffix"];
			NSData			*jsonData	= [NSJSONSerialization dataWithJSONObject:jsonDict
																 options:NSJSONWritingPrettyPrinted
																   error:&error];
			
			if (!jsonData)
				CNFLog(@"Got an error: %@", error);
			else {
				NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
				[self _postString:suffix json:json];
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

- (int) registration:(NSDictionary *) dict {
	[_txcond lock];
	[_txarray addObject:[NSDictionary dictionaryWithObjectsAndKeys:CNFConnectionSuffixRegistration, @"suffix", dict, @"json", nil]];
	[_txcond signal];
	[_txcond unlock];
	
	return 0;
}

- (int) login:(NSDictionary *) dict {
	[_txcond lock];
	[_txarray addObject:[NSDictionary dictionaryWithObjectsAndKeys:CNFConnectionSuffixLogin, @"suffix", dict, @"json", nil]];
	[_txcond signal];
	[_txcond unlock];
	
	return 0;
}

- (int) logout:(NSDictionary *) dict {
	[_txcond lock];
	[_txarray addObject:[NSDictionary dictionaryWithObjectsAndKeys:CNFConnectionSuffixLogout, @"suffix", dict, @"json", nil]];
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
