//
//  CNFTextField.m
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "CNFTextField.h"

@implementation CNFTextField

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.layer.cornerRadius = 20.0;
		self.layer.borderWidth = 2.0;
	}
	return self;
}

@end
