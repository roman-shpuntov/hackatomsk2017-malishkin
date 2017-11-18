//
//  CNFConnection.h
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Pusher/Pusher.h>

@protocol CNFConnectionDelegate <NSObject>
@optional
- (void) recvData:(NSDictionary *) dict;
- (void) ready:(NSString *) token channel:(NSString *) channel;
@end

@interface CNFConnection : NSObject <PTPusherDelegate, NSURLSessionDelegate>

+ (CNFConnection *) sharedInstance;
- (void) dealloc;
- (void) addDelegate:(id <CNFConnectionDelegate> ) delegate;
- (void) removeDelegate:(id <CNFConnectionDelegate> ) delegate;
- (int) registration:(NSDictionary *) dict;
- (int) login:(NSDictionary *) dict;
- (int) logout:(NSDictionary *) dict;
- (void) start;
- (void) stop;

@property (nonatomic, readonly)	NSString	*token;
@property (nonatomic, readonly)	NSString	*channel;
@property (nonatomic, readonly)	NSNumber	*userid;

@end
