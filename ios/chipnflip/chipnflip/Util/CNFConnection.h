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
@end

@interface CNFConnection : NSObject <PTPusherDelegate, NSURLSessionDelegate>

+ (CNFConnection *) sharedInstance;
- (void) dealloc;
- (void) addDelegate:(id <CNFConnectionDelegate> ) delegate;
- (void) removeDelegate:(id <CNFConnectionDelegate> ) delegate;

- (int) send:(NSDictionary *) json suffix:(NSString *) suffix method:(NSString *) method header:(NSDictionary *) header;

- (int) pusherSubscribeChannel:(NSString *) channelName;
- (void) pusherUnsubscribeAll;

- (int) pusherBindToEvent:(NSString *) eventName;
- (void) pusherUnbindAll;

- (void) start;
- (void) stop;

@end
