//
//  CNFParser.h
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNFConnection.h"

@interface CNFMove : NSObject

@property (nonatomic, assign)		NSUInteger x;
@property (nonatomic, assign)		NSUInteger y;

@end

@protocol CNFParserDelegate <NSObject>
@optional
- (void) serverError:(NSError *) error;
- (void) serverLoginReady:(NSString *) token;
- (void) serverGameReady:(NSString *) userName;
- (void) serverStepReady;
- (void) serverStepWait;
- (void) serverFields:(NSArray *) fields;
@end

@interface CNFParser : NSObject <CNFConnectionDelegate>

+ (CNFParser *) sharedInstance;
- (void) dealloc;
- (void) addDelegate:(id <CNFParserDelegate> ) delegate;
- (void) removeDelegate:(id <CNFParserDelegate> ) delegate;

- (int) registration:(NSString *) name email:(NSString *) email password:(NSString *) password;
- (int) login:(NSString *) email password:(NSString *) password;
- (int) startGame;
- (int) step:(CNFMove *) from to:(CNFMove *) to;
- (int) logout;

@property (nonatomic, readonly)	NSString	*user;
@property (nonatomic, readonly)	NSNumber	*money;
@property (nonatomic, readonly)	NSString	*token;
@property (nonatomic, readonly)	NSString	*channel;
@property (nonatomic, readonly)	NSNumber	*userid;
@property (nonatomic, readonly)	NSNumber	*peerid;
@property (nonatomic, readonly)	NSString	*peerName;
@property (nonatomic, readonly)	NSNumber	*prize;
@property (nonatomic, readonly)	NSNumber	*gameid;
@property (nonatomic, readonly)	NSNumber	*gamekey;

@end
