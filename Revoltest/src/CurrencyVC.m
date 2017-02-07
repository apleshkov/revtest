//
//  CurrencyVC.m
//  Revoltest
//
//  Created by Andrew Pleshkov on 05/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "CurrencyVC.h"
#import "CurrencyVC+Private.h"
#import "Extensions.h"
#import "Style.h"

@interface CurrencyVC () <UITextFieldDelegate>
@end

@implementation CurrencyVC {
    NSString *_stringValue;
    UILabel *_amountLabel;
    UILabel *_valueLabel;
    UILabel *_multiplierLabel;
}

- (instancetype)initWithCurrency:(CurrencyType)currency conversionDirection:(CurrencyConversionDirection)conversionDirection {
    self = [super initWithNibName:nil bundle:nil];
    _currency = currency;
    _conversionDirection = conversionDirection;
    return self;
}

#pragma mark

- (NSDecimalNumber *)value {
    if (_stringValue.length == 0) {
        return [NSDecimalNumber zero];
    }
    NSString *string = _stringValue;
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:string locale:[NSLocale currentLocale]];
    if ([[NSDecimalNumber notANumber] isEqualToNumber:number]) {
        return [NSDecimalNumber zero];
    }
    return number;
}

- (NSString *)stringValue {
    return _stringValue;
}

- (void)setStringValue:(NSString *)stringValue {
    _stringValue = stringValue;
    [self _syncValueText];
    [self _syncAmountText];
}

#pragma mark

- (void)reloadData {
    [self _syncValueText];
    [self _syncAmountText];
    [self _syncMultiplierText];
}

- (NSString *)_convertedValueText {
    NSDecimalNumber *value = [self.dataSource currencyVCConvertedValueTo:self];
    if (value) {
        static NSNumberFormatter *formatter = nil;
        if (!formatter) {
            formatter = [CurrencyVC _createCurrencyNumberFormatter];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
        }
        return [formatter stringFromNumber:value];
    }
    return nil;
}

- (NSString *)_valueText {
    switch (_conversionDirection) {
        case CurrencyConversionDirectionTo: {
            return [self _convertedValueText];
        }
        case CurrencyConversionDirectionFrom: {
            return _stringValue;
        }
    }
}

- (void)_syncValueText {
    NSString *input = [self _valueText];
    NSString *result = (input.length > 0 ? input : @"0");
    NSString *prefix = nil;
    switch (_conversionDirection) {
        case CurrencyConversionDirectionTo:
            prefix = @"+";
            break;
        case CurrencyConversionDirectionFrom:
            prefix = @"-";
    }
    NSParameterAssert(prefix);
    _valueLabel.text = [prefix stringByAppendingString:result];
}

- (void)_syncAmountText {
    NSDecimalNumber *amount = [self.dataSource currencyVCAvailableAmount:self];
    if (!amount) {
        _amountLabel.text = nil;
        return;
    }
    NSString *string = [[CurrencyVC _numberFormatterWithCurrency:self.currency] stringFromNumber:amount];
    _amountLabel.text = [NSString stringWithFormat:@"You have %@", string];
    BOOL isAble = [self.dataSource currencyVCIsConvertibleValueFrom:self];
    _amountLabel.textColor = (isAble ? StyleColorTextPrimary : StyleColorTextError);
}

- (void)_syncMultiplierText {
    switch (_conversionDirection) {
        case CurrencyConversionDirectionTo:
            _multiplierLabel.text = [self _conversionMultiplierText];
            break;
        case CurrencyConversionDirectionFrom:
            _multiplierLabel.text = nil;
            break;
    }
}

- (NSString *)_conversionMultiplierText {
    CurrencyType otherCurrency = [self.dataSource currencyVCCurrencyToConvertAgainst:self];
    if (self.currency == otherCurrency) {
        return nil;
    }
    NSDecimalNumber *rate = [self.dataSource currencyVC:self conversionRateAgainstCurrency:otherCurrency];
    if (!rate) {
        return nil;
    }
    NSString *a = [[CurrencyVC _numberFormatterWithCurrency:self.currency] stringFromNumber:@1];
    NSString *b = [[CurrencyVC _numberFormatterWithCurrency:otherCurrency] stringFromNumber:rate];
    return [NSString stringWithFormat:@"%@ = %@", a, b];
}

+ (NSNumberFormatter *)_numberFormatterWithCurrency:(CurrencyType)currency {
    static NSMutableDictionary<NSString *, NSNumberFormatter *> *map = nil;
    if (!map) {
        map = [NSMutableDictionary new];
    }
    NSString *code = nil;
    switch (currency) {
        case CurrencyTypeEUR:
            code = @"EUR";
            break;
        case CurrencyTypeGBP:
            code = @"GBP";
            break;
        case CurrencyTypeUSD:
            code = @"USD";
            break;
    }
    NSParameterAssert(code);
    NSNumberFormatter *formatter = map[code];
    if (!formatter) {
        formatter = map[code] = [self _createCurrencyNumberFormatter];
        formatter.currencyCode = code;
    }
    return formatter;
}

+ (NSNumberFormatter *)_createCurrencyNumberFormatter {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.locale = [NSLocale currentLocale];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    [formatter setMaximumFractionDigits:2];
    return formatter;
}

#pragma mark

- (void)loadView {
    [super loadView];
 
    _valueLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentRight;
        label.font = StyleFontBoldSized(30);
        switch (_conversionDirection) {
            case CurrencyConversionDirectionTo:
                label.textColor = StyleColorCurrencyTo;
                break;
            case CurrencyConversionDirectionFrom:
                label.textColor = self.view.tintColor;
                break;
        }
        label;
    });
    
    UILabel *currencyLabel = ({
        UILabel *label = [UILabel new];
        label.textColor = StyleColorTextPrimary;
        label.font = StyleFontBoldSized(30);
        label.text = [self _currencyTitle];
        label;
    });
    
    _amountLabel = ({
        UILabel *label = [UILabel new];
        label.font = StyleFontRegularSized(13);
        label;
    });
    
    _multiplierLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = StyleColorTextPrimary;
        label.font = StyleFontRegularSized(13);
        label;
    });
    
    UIStackView *row1 = [UIStackView tst_stackViewWithViews:@[currencyLabel, _valueLabel]
                                                       axis:UILayoutConstraintAxisHorizontal
                                                    spacing:0
                                               distribution:UIStackViewDistributionFill
                                                  alignment:UIStackViewAlignmentFill];
    UIStackView *row2 = [UIStackView tst_stackViewWithViews:@[_amountLabel, _multiplierLabel]
                                                       axis:UILayoutConstraintAxisHorizontal
                                                    spacing:0
                                               distribution:UIStackViewDistributionFill
                                                  alignment:UIStackViewAlignmentFill];
    UIStackView *stackView = [UIStackView tst_stackViewWithViews:@[row1, row2]
                                                            axis:UILayoutConstraintAxisVertical
                                                         spacing:10
                                                    distribution:UIStackViewDistributionFill
                                                       alignment:UIStackViewAlignmentFill];
    
    [self.view addSubview:stackView];
    [stackView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    [self reloadData];
}

- (NSString *)_currencyTitle {
    switch (self.currency) {
        case CurrencyTypeEUR:
            return @"EUR";
        case CurrencyTypeGBP:
            return @"GBP";
        case CurrencyTypeUSD:
            return @"USD";
    }
}

@end
