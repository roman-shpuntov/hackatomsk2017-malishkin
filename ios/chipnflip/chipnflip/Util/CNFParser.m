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

- (id) init {
	self = [super init];
	
	if (self) {
		_delegates	= [NSMutableArray mutableArrayUsingWeakReferences];
		_connection	= [CNFConnection sharedInstance];
		[_connection addDelegate:self];
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
