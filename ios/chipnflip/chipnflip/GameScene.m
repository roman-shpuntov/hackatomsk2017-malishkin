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
	NSArray			*_lastMove;
}

const NSUInteger	CNFGridSide		= 7;
const NSUInteger	CNFStepMax		= 3;
const NSUInteger	CNFGridSpace	= 10;
const CGFloat		CNFTouchAplha	= 0.5;
const CGFloat		CNFTouchMove	= 0.2;

-(void)dealloc {
	CNFLog(@"");
	
	CNFParser *parser = [CNFParser sharedInstance];
	[parser removeDelegate:self];
}

- (void) serverFields:(NSArray *) fields {
	CNFParser	*parser = [CNFParser sharedInstance];
	
	for (int i=0; i<fields.count; i++) {
		NSArray *row = fields[i];
		for (int j=0; j<row.count; j++) {
			NSNumber	*col = [row objectAtIndex:j];
			if (col == parser.peerid) {
				[self _createChip:[NSNumber numberWithLong:i] ypos:[NSNumber numberWithLong:j] selfChip:NO];
			}
			else if (col == parser.userid) {
				[self _createChip:[NSNumber numberWithLong:i] ypos:[NSNumber numberWithLong:j] selfChip:YES];
			}
		}
	}
	
	_lastMove = [NSArray arrayWithArray:fields];
}

- (void)_createChip:(NSNumber *) xpos ypos:(NSNumber *) ypos selfChip:(BOOL) selfChip {
	int				i = (int) xpos.longValue;
	int				j = (int) ypos.longValue;
	CGFloat			x = i * _side + i * _space;
	CGFloat			y = j * _side + j * _space + (self.size.height - self.size.width) / 2;
	CGFloat			mx = x + _side / 2 + _space / 2;
	CGFloat			my = y + _side / 2 + _space / 2;
	
	NSString		*m = [NSString stringWithFormat:@"%@", selfChip?@"wchip.png":@"bchip.png"];
	SKSpriteNode	*n = [SKSpriteNode spriteNodeWithImageNamed:m];
	
	n.position = CGPointMake(mx, my);
	n.size  = CGSizeMake(_side, _side);
	n.name = @"chip";
	[self addChild:n];
}

- (void)sceneDidLoad {
	CNFLog(@"");
	
	CNFParser *parser = [CNFParser sharedInstance];
	[parser removeDelegate:self];
	[parser addDelegate:self];
	
	for (SKNode* node in self.children)
		[node removeFromParent];
	
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
	
/*	for (int i=0; i<CNFGridSide; i++) {
		for (int j=0; j<CNFGridSide; j++) {
			[self _createChip:[NSNumber numberWithLong:i] ypos:[NSNumber numberWithLong:j] selfChip:(i+j)%2];
		}
	}*/
	
	_fieldRange.size.width	= _cover * CNFGridSide;
	_fieldRange.size.height	= _cover * CNFGridSide;
	
	CNFLog(@"range %f:%f %f:%f", _fieldRange.origin.x, _fieldRange.origin.y,
		_fieldRange.size.width, _fieldRange.size.height);
}

- (CGPoint) _location2cell:(CGPoint) location {
	int x = (int) ((location.x - _fieldRange.origin.x) / _cover);
	int y = (int) ((location.y - _fieldRange.origin.y) / _cover);
	
	location.x = x;
	location.y = y;
	
	return location;
}

- (CGPoint) _location2grid:(CGPoint) location {
	location = [self _location2cell:location];
	
	location.x = _fieldRange.origin.x + location.x * _cover + _side / 2 + _space / 2;
	location.y = _fieldRange.origin.y + location.y * _cover + _side / 2 + _space / 2;
	
	return location;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		CGPoint location = [touch locationInNode:self];
		_selectedLocation = [self _location2grid:location];
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
			location = [self _location2grid:location];
			
			if (location.x < _fieldRange.origin.x ||
				location.x >= _fieldRange.origin.x + _fieldRange.size.width) {
				[_selectedNode runAction:[SKAction moveTo:_selectedLocation duration:CNFTouchMove]];
			}
			else if (location.y < _fieldRange.origin.y ||
					 location.y >= _fieldRange.origin.y + _fieldRange.size.height) {
				[_selectedNode runAction:[SKAction moveTo:_selectedLocation duration:CNFTouchMove]];
			}
			else {
				CGPoint		grid = [self _location2cell:location];
				NSArray		*xarr = _lastMove[(int) grid.x];
				NSNumber	*yval = xarr[(int) grid.y];
				if ([yval longValue])
					[_selectedNode runAction:[SKAction moveTo:_selectedLocation duration:CNFTouchMove]];
				else {
					CGPoint		old = [self _location2cell:_selectedLocation];
					int			x = (int) (old.x - grid.x);
					int			y = (int) (old.y - grid.y);
					
					if (abs(x) >= CNFStepMax || abs(y) >= CNFStepMax)
						[_selectedNode runAction:[SKAction moveTo:_selectedLocation duration:CNFTouchMove]];
					else
						[_selectedNode runAction:[SKAction moveTo:location duration:CNFTouchMove]];
				}
			}
			
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
