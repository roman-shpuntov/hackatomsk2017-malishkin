//
//  CNFParser.h
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNFConnection.h"

@protocol CNFParserDelegate <NSObject>
@optional
- (void) serverError:(NSError *) error;
- (void) serverLoginReady:(NSString *) token;
- (void) serverGameReady:(NSString *) userName;
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

@end
