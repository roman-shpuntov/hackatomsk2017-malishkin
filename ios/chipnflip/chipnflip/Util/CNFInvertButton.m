//
//  CNFInvertButton.m
//  chipnflip
//
//  Created by roman on 19.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "CNFInvertButton.h"
#import "CNFColor.h"

@implementation CNFInvertButton

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.layer.cornerRadius = 20.0f;
		self.clipsToBounds = true;
		self.layer.backgroundColor = [CNFColor purpleColor].CGColor;
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor yellowColor] forState:(UIControlStateHighlighted|UIControlStateSelected)];
	}
	return self;
}

@end
