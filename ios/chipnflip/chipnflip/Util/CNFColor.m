//
//  CNFColor.m
//  chipnflip
//
//  Created by roman on 19.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import "CNFColor.h"

@implementation CNFColor

+ (UIColor *) purpleColor {
	return [UIColor colorWithRed:(CGFloat)0x8d/(CGFloat)0xff
					green:(CGFloat)0x41/(CGFloat)0xff
					 blue:(CGFloat)0xc1/(CGFloat)0xff
						   alpha:1.0];
}

+ (UIColor *) grayColor {
	return [UIColor colorWithRed:(CGFloat)0xee/(CGFloat)0xff
						   green:(CGFloat)0xee/(CGFloat)0xff
							blue:(CGFloat)0xee/(CGFloat)0xff
						   alpha:1.0];
}

+ (UIColor *) boardColor {
	return [UIColor colorWithRed:(CGFloat)0xc7/(CGFloat)0xff
						   green:(CGFloat)0xaa/(CGFloat)0xff
							blue:(CGFloat)0xe6/(CGFloat)0xff
						   alpha:1.0];
}

@end
