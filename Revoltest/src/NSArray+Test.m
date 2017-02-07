//
//  NSArray+Test.m
//  Revoltest
//
//  Created by Andrew Pleshkov on 05/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "NSArray+Test.h"

@implementation NSArray (Test)

- (void)tst_each:(void (^)(id _Nonnull, NSUInteger))block {
    NSParameterAssert(block);
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj, idx);
    }];
}

- (NSArray *)tst_map:(id (^)(id _Nonnull, NSUInteger))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self tst_each:^(id  _Nonnull obj, NSUInteger idx) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

@end
