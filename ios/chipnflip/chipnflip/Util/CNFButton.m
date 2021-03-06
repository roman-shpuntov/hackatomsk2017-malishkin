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
		self.layer.cornerRadius = 20.0f;
		self.clipsToBounds = true;
		self.layer.borderWidth = 1.0f;
		self.layer.borderColor = [UIColor whiteColor].CGColor;
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor yellowColor] forState:(UIControlStateHighlighted|UIControlStateSelected)];
	}
	return self;
}

@end
