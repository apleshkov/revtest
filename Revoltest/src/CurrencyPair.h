//
//  CurrencyPair.h
//  Revoltest
//
//  Created by Andrew Pleshkov on 06/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrencyType.h"
#import "Macros.h"

NS_ASSUME_NONNULL_BEGIN

@interface CurrencyPair : NSObject <NSCopying>

@property (nonatomic, readonly) CurrencyType a;
@property (nonatomic, readonly) CurrencyType b;

TST_UNAVAILABLE_INIT_AND_NEW

- (instancetype)initWithA:(CurrencyType)a b:(CurrencyType)b;

+ (nonnull instancetype)pairWithA:(CurrencyType)a b:(CurrencyType)b;

@end

NS_ASSUME_NONNULL_END
