//
//  CurrencyAmountModel.m
//  Revoltest
//
//  Created by Andrew Pleshkov on 06/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "CurrencyAmountModel.h"
#import "CurrencyRateModel.h"

@implementation CurrencyAmountModel {
    NSMutableDictionary<NSNumber *, NSDecimalNumber *> *_data;
    CurrencyRateModel *_rateModel;
}

- (instancetype)initWithData:(NSDictionary<NSNumber *,NSDecimalNumber *> *)data rateModel:(CurrencyRateModel *)rateModel {
    NSParameterAssert(data);
    NSParameterAssert(rateModel);
    self = [super init];
    _data = [data mutableCopy];
    _rateModel = rateModel;
    return self;
}

- (NSDecimalNumber *)amountWithCurrency:(CurrencyType)currency {
    return _data[@(currency)];
}

- (BOOL)convertValue:(NSDecimalNumber *)value fromCurrency:(CurrencyType)from to:(CurrencyType)to {
    if ([self isAbleToConvertValue:value fromCurrency:from to:to]) {
        NSDecimalNumber *newValue = [_rateModel convertedValue:value withPair:[CurrencyPair pairWithA:from b:to]];
        _data[@(from)] = [[self amountWithCurrency:from] decimalNumberBySubtracting:value];
        _data[@(to)] = [[self amountWithCurrency:to] decimalNumberByAdding:newValue];
        return YES;
    }
    return NO;
}

- (BOOL)isAbleToConvertValue:(NSDecimalNumber *)value fromCurrency:(CurrencyType)from to:(CurrencyType)to {
    NSParameterAssert(value);
    if (from == to) {
        return NO;
    }
    NSDecimalNumber *fromAmount = [self amountWithCurrency:from];
    if (!fromAmount) {
        return NO;
    }
    if (value.doubleValue > fromAmount.doubleValue) {
        return NO;
    }
    NSDecimalNumber *newValue = [_rateModel convertedValue:value withPair:[CurrencyPair pairWithA:from b:to]];
    if (!newValue) {
        return NO;
    }
    return YES;
}

@end
