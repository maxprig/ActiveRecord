//
//  NSSortDescriptor+AR.m
//  ActiveRecord
//
//  Created by Michal Konturek on 25/02/2014.
//  Copyright (c) 2014 Michal Konturek. All rights reserved.
//

#import "NSSortDescriptor+AR.h"

@implementation NSSortDescriptor (AR)

+ (NSArray *)from:(NSArray *)object {
    id result = [NSMutableArray array];
    for (id item in object) {
        id descriptor = [self createFrom:item];
        if (descriptor) [result addObject:descriptor];
    }
    return result;
}

+ (instancetype)createFrom:(id)object {
    if ([object isKindOfClass:[self class]]) return object;
    if ([object isKindOfClass:[NSString class]]) return [self createWithKey:object ascending:YES];
    return nil;
}

+ (instancetype)createWithKey:(NSString *)key ascending:(BOOL)ascending {
    return [self sortDescriptorWithKey:key ascending:ascending];
}

@end
