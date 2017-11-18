//
//  CNFButton.m
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "CNFButton.h"

@implementation CNFButton

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.layer.cornerRadius = 20;
		self.clipsToBounds = true;
		self.backgroundColor = [UIColor blueColor];
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		//[self setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
		[self setTitleColor:[UIColor yellowColor] forState:(UIControlStateHighlighted|UIControlStateSelected)];
		//[self setTitleColor:[UIColor yellowColor] forState:UIControlStateFocused];
	}
	return self;
}

@end
