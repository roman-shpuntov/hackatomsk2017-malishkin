//
//  GameScene.m
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "GameScene.h"
#import "CNFLog.h"

@implementation GameScene {
	CGFloat			_side;
	CGFloat			_cover;
	CGFloat			_space;
    NSTimeInterval	_lastUpdateTime;
	CGRect			_fieldRange;
}

const NSUInteger	CNFGridSide		= 7;

-(void)dealloc {
	CNFLog(@"");
}

- (void)sceneDidLoad {
    _lastUpdateTime = 0;
	
	self.anchorPoint = CGPointMake(0.0, 0.0);
	
	_cover = self.size.width / CNFGridSide;
	_space = _cover / 10;
	_side = _cover - _space;
	
	for (int i=0; i<CNFGridSide; i++) {
		for (int j=0; j<CNFGridSide; j++) {
			CGFloat			x = i * _side + i * _space;
			CGFloat			y = j * _side + j * _space + (self.size.height - self.size.width) / 2;
			CGFloat			mx = x + _side / 2 + _space / 2;
			CGFloat			my = y + _side / 2 + _space / 2;
			
			if (i == 0 && j == 0) {
				_fieldRange.origin.x = x;
				_fieldRange.origin.y = y;
			}
			
			//if (rand() % 2) {
			NSString		*m = [NSString stringWithFormat:@"%@", ((i + j) % 2 == 0)?@"wchip.png":@"bchip.png"];
			SKSpriteNode	*n = [SKSpriteNode spriteNodeWithImageNamed:m];
			
			n.position = CGPointMake(mx, my);
			n.size  = CGSizeMake(_side, _side);
			n.name = @"chip";
			[self addChild:n];
			//}
			
			SKShapeNode *item = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(_cover, _cover)];
			item.name = @"grid";
			if ((i + j) % 2)
				item.fillColor = SKColor.whiteColor;
			else
				item.fillColor = SKColor.blackColor;
			item.lineWidth = 0.0;
			item.position = CGPointMake(mx, my);
			item.zPosition = -100;
			
			[self addChild:item];
		}
	}
	
	_fieldRange.size.width	= _cover * CNFGridSide;
	_fieldRange.size.height	= _cover * CNFGridSide;
	
	CNFLog(@"range %f:%f %f:%f", _fieldRange.origin.x, _fieldRange.origin.y, _fieldRange.size.width, _fieldRange.size.height);
}

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    
    // Initialize _lastUpdateTime if it has not already been
    if (_lastUpdateTime == 0) {
        _lastUpdateTime = currentTime;
    }
    
    // Calculate time since last update
    CGFloat dt = currentTime - _lastUpdateTime;
    
    // Update entities
    for (GKEntity *entity in self.entities) {
        [entity updateWithDeltaTime:dt];
    }
    
    _lastUpdateTime = currentTime;
}

@end
