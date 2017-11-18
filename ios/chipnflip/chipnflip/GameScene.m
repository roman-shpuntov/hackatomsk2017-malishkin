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
	SKSpriteNode	*_selectedNode;
	CGPoint			_selectedLocation;
}

const NSUInteger	CNFGridSide		= 7;
const NSUInteger	CNFGridSpace	= 10;
const CGFloat		CNFTouchAplha	= 0.5;

-(void)dealloc {
	CNFLog(@"");
}

- (void)sceneDidLoad {
    _lastUpdateTime = 0;
	
	self.anchorPoint = CGPointMake(0.0, 0.0);
	
	_cover	= self.size.width / CNFGridSide;
	_space	= _cover / CNFGridSpace;
	_side	= _cover - _space;
	
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
	
	CNFLog(@"range %f:%f %f:%f", _fieldRange.origin.x, _fieldRange.origin.y,
		_fieldRange.size.width, _fieldRange.size.height);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		CGPoint location = [touch locationInNode:self];
		
		int x = (int) ((location.x - _fieldRange.origin.x) / _cover);
		int y = (int) ((location.y - _fieldRange.origin.y) / _cover);

		_selectedLocation.x = _fieldRange.origin.x + x * _cover + _side / 2 + _space / 2;
		_selectedLocation.y = _fieldRange.origin.y + y * _cover + _side / 2 + _space / 2;

		SKNode *touchedNode = [self nodeAtPoint:location];
		
		CNFLog(@"%f:%f", location.x, location.y);
		
		if (touchedNode != self) {
			if ([touchedNode.name isEqualToString:@"chip"]) {
				_selectedNode = (SKSpriteNode *) touchedNode;
				
				if ([touchedNode isKindOfClass:[SKSpriteNode class]]) {
					SKSpriteNode    *node = (SKSpriteNode *) touchedNode;
					node.alpha = CNFTouchAplha;
					node.zPosition++;
				}
			}
		}
	}
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		CGPoint location  = [touch locationInNode:self];
		
		if (_selectedNode) {
			_selectedNode.position = location;
			CNFLog(@"%f:%f", location.x, location.y);
		}
	}
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	if (_selectedNode) {
		for (UITouch *touch in touches) {
			_selectedNode.zPosition--;
			_selectedNode.alpha = 1.0;
			
			CGPoint location = [touch locationInNode:self];
			
			int x = (int) ((location.x - _fieldRange.origin.x) / _cover);
			int y = (int) ((location.y - _fieldRange.origin.y) / _cover);
			
			location.x = _fieldRange.origin.x + x * _cover + _side / 2 + _space / 2;
			location.y = _fieldRange.origin.y + y * _cover + _side / 2 + _space / 2;
			
			if (location.x < _fieldRange.origin.x ||
				location.x >= _fieldRange.origin.x + _fieldRange.size.width) {
				[_selectedNode runAction:[SKAction moveTo:_selectedLocation duration:0.2]];
			}
			else if (location.y < _fieldRange.origin.y ||
					 location.y >= _fieldRange.origin.y + _fieldRange.size.height) {
				[_selectedNode runAction:[SKAction moveTo:_selectedLocation duration:0.2]];
			}
			else
				[_selectedNode runAction:[SKAction moveTo:location duration:0.2]];
			
			_selectedNode = nil;
		}
	}
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
