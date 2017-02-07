//
//  CurrencyAmountModel.h
//  Revoltest
//
//  Created by Andrew Pleshkov on 06/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrencyType.h"
#import "Macros.h"

@class CurrencyRateModel;

NS_ASSUME_NONNULL_BEGIN

@interface CurrencyAmountModel : NSObject

TST_UNAVAILABLE_INIT_AND_NEW

/// NSDictionary<CurrencyType, NSDecimalNumber>
- (instancetype)initWithData:(NSDictionary<NSNumber *, NSDecimalNumber *> *)data
                   rateModel:(CurrencyRateModel *)rateModel;

- (nullable NSDecimalNumber *)amountWithCurrency:(CurrencyType)currency;

- (BOOL)convertValue:(NSDecimalNumber *)value fromCurrency:(CurrencyType)from to:(CurrencyType)to;

- (BOOL)isAbleToConvertValue:(NSDecimalNumber *)value fromCurrency:(CurrencyType)from to:(CurrencyType)to;

@end

NS_ASSUME_NONNULL_END
