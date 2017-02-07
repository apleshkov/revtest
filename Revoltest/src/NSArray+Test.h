//
//  NSArray+Test.h
//  Revoltest
//
//  Created by Andrew Pleshkov on 05/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<T> (Test)

- (void)tst_each:(void (^)(T obj, NSUInteger idx))block;

- (NSArray *)tst_map:(id (^)(T obj, NSUInteger idx))block;

@end

NS_ASSUME_NONNULL_END
