//
//  Extensions.h
//  Revoltest
//
//  Created by Andrew Pleshkov on 05/02/17.
//  Copyright © 2017 test. All rights reserved.
//


#import <PureLayout.h>

#import "NSArray+Test.h"
#import "UIStackView+Test.h"


#define TSTSafeCast(CLAZZ, OBJ) ({ CLAZZ *__obj = (id)(OBJ); ([__obj isKindOfClass:[CLAZZ class]] ? __obj : nil); })

#define TSTEnsure(OBJ) ({ id __obj = (OBJ); NSCParameterAssert(__obj); (id _Nonnull)__obj; })


#pragma mark - GCD


#define TSTQueueMainAssert() NSCAssert([NSThread isMainThread], @"Not main thread: %@", [NSThread currentThread])

static inline void TSTQueueMainAsync(dispatch_block_t block) {
    NSCParameterAssert(block);
    if ([NSThread isMainThread]) {
        block();
        return;
    }
    dispatch_async(dispatch_get_main_queue(), block);
}

static inline void TSTQueueAfter(dispatch_queue_t queue, int64_t secs, dispatch_block_t block) {
    NSCParameterAssert(queue);
    NSCParameterAssert(block);
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secs * NSEC_PER_SEC));
    dispatch_after(time, queue, block);
}

static inline void TSTQueueMainAfter(int64_t secs, dispatch_block_t block) {
    TSTQueueAfter(dispatch_get_main_queue(), secs, block);
}
