//
//  CurrencyPagerVC.h
//  Revoltest
//
//  Created by Andrew Pleshkov on 05/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macros.h"
#import "CurrencyConversionDirection.h"
#import "CurrencyVC.h"

@protocol CurrencyPagerVCDelegate;
@protocol CurrencyPagerVCDataSource;

NS_ASSUME_NONNULL_BEGIN

@interface CurrencyPagerVC : UIViewController

@property (nonatomic, weak, nullable) id<CurrencyPagerVCDelegate> delegate;
@property (nonatomic, weak, nullable) id<CurrencyPagerVCDataSource> dataSource;
@property (nonatomic, readonly) CurrencyConversionDirection conversionDirection;
@property (nonatomic, readonly) CurrencyVC *currentPage;

TST_UNAVAILABLE_VC_INITIALIZERS

- (instancetype)initWithConversionDirection:(CurrencyConversionDirection)conversionDirection;

- (void)reloadData;

- (CurrencyVC *)pageAtIndex:(NSUInteger)index;

- (void)resetCurrentValue;

@end


@protocol CurrencyPagerVCDelegate <NSObject>

- (void)currencyPagerVC:(CurrencyPagerVC *)currencyPagerVC didSelectPageAtIndex:(NSUInteger)index;

- (void)currencyPagerVC:(CurrencyPagerVC *)currencyPagerVC didUpdateValueOfPageAtIndex:(NSUInteger)index;

@end


@protocol CurrencyPagerVCDataSource <NSObject>

/// NSArray<CurrencyType>
- (NSArray<NSNumber *> *)currencyPagerVCCurrencies:(CurrencyPagerVC *)pagerVC;

- (nullable NSDecimalNumber *)currencyPagerVC:(CurrencyPagerVC *)pagerVC convertedValueForPageAtIndex:(NSUInteger)index;

- (nullable NSDecimalNumber *)currencyPagerVC:(CurrencyPagerVC *)pagerVC forPageAtIndex:(NSUInteger)index conversionRateAgainstCurrency:(CurrencyType)otherCurrency;

- (nullable NSDecimalNumber *)currencyPagerVC:(CurrencyPagerVC *)pagerVC availableAmountForPageAtIndex:(NSUInteger)index;

- (BOOL)currencyPagerVC:(CurrencyPagerVC *)pagerVC isConvertibleValueFromPageAtIndex:(NSUInteger)index;

- (CurrencyType)currencyPagerVC:(CurrencyPagerVC *)pagerVC currencyToConvertAgainstForPageAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
