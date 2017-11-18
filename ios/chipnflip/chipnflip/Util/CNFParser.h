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
- (void) serverData:(NSString *) string;
- (void) serverReady:(NSString *) token channel:(NSString *) channel;
@end

@interface CNFParser : NSObject <CNFConnectionDelegate>

+ (CNFParser *) sharedInstance;
- (void) dealloc;
- (void) addDelegate:(id <CNFParserDelegate> ) delegate;
- (void) removeDelegate:(id <CNFParserDelegate> ) delegate;

@property (nonatomic, readonly)	NSString	*user;
@property (nonatomic, readonly)	NSUInteger	money;

@end
