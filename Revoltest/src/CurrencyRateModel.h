//
//  CurrencyRateModel.h
//  Revoltest
//
//  Created by Andrew Pleshkov on 06/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrencyPair.h"

@protocol CurrencyRateModelDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface CurrencyRateModel : NSObject

@property (nonatomic, weak, nullable) id<CurrencyRateModelDelegate> delegate;

/// NSDictionary<CurrencyType, NSDecimalNumber>
- (instancetype)initWithRates:(nullable NSDictionary<CurrencyPair *, NSDecimalNumber *> *)rates;

- (nullable NSDecimalNumber *)rateOfPair:(CurrencyPair *)pair;

- (nullable NSDecimalNumber *)convertedValue:(NSDecimalNumber *)value withPair:(CurrencyPair *)pair;

- (void)startLoading;

@end


@protocol CurrencyRateModelDelegate <NSObject>

- (void)currencyRateModel:(CurrencyRateModel *)rateModel didUpdateRatesWithError:(nullable NSError *)error;

@end


static NSString *const CurrencyRateModelErrorDomain = @"CurrencyRateModelErrorDomain";

enum {
    CurrencyRateModelErrorInvalidData = 1
};

NS_ASSUME_NONNULL_END
