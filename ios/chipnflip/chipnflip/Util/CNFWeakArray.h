//
//  CNFWeakArray.h
//  chipnflip
//
//  Created by roman on 18.11.2017.
//  Copyright © 2017 roman.shpuntov. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation NSMutableArray (WeakReferences)

+ (id)mutableArrayUsingWeakReferences {
	return [self mutableArrayUsingWeakReferencesWithCapacity:0];
}

+ (id)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
	CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
	return (__bridge id)(CFArrayCreateMutable(0, capacity, &callbacks));
}

@end
