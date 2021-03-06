//
//  GameViewController.h
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import "CNFParser.h"

@interface GameViewController : UIViewController <CNFParserDelegate>

@property (nonnull, strong) UIViewController	*prevViewController;

@end
