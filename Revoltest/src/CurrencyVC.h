//
//  CurrencyVC.h
//  Revoltest
//
//  Created by Andrew Pleshkov on 05/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macros.h"
#import "CurrencyType.h"
#import "CurrencyConversionDirection.h"

@protocol CurrencyVCDataSource;

NS_ASSUME_NONNULL_BEGIN

@interface CurrencyVC : UIViewController

@property (nonatomic, weak, nullable) id<CurrencyVCDataSource> dataSource;
@property (nonatomic, readonly) CurrencyType currency;
@property (nonatomic, readonly) CurrencyConversionDirection conversionDirection;
@property (nonatomic, readonly) NSDecimalNumber *value;

TST_UNAVAILABLE_VC_INITIALIZERS

- (instancetype)initWithCurrency:(CurrencyType)currency conversionDirection:(CurrencyConversionDirection)conversionDirection;

- (void)reloadData;

@end


@protocol CurrencyVCDataSource <NSObject>

/// CurrencyConversionDirectionTo
- (nullable NSDecimalNumber *)currencyVCConvertedValueTo:(CurrencyVC *)currencyVC;

/// CurrencyConversionDirectionTo
- (nullable NSDecimalNumber *)currencyVC:(CurrencyVC *)currencyVC conversionRateAgainstCurrency:(CurrencyType)otherCurrency;

- (nullable NSDecimalNumber *)currencyVCAvailableAmount:(CurrencyVC *)currencyVC;

/// CurrencyConversionDirectionFrom
- (BOOL)currencyVCIsConvertibleValueFrom:(CurrencyVC *)currencyVC;

/// CurrencyConversionDirectionTo
- (CurrencyType)currencyVCCurrencyToConvertAgainst:(CurrencyVC *)currencyVC;

@end

NS_ASSUME_NONNULL_END
