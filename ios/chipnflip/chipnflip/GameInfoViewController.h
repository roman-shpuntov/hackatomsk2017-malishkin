//
//  GameInfoViewController.h
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNFParser.h"

@interface GameInfoViewController : UIViewController <CNFParserDelegate, UITableViewDelegate, UITableViewDataSource>

@end
