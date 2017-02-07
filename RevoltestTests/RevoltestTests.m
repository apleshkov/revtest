//
//  RevoltestTests.m
//  RevoltestTests
//
//  Created by Andrew Pleshkov on 03/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CurrencyRateModel.h"
#import "CurrencyAmountModel.h"

@interface RevoltestTests : XCTestCase

@end

@implementation RevoltestTests

#define _decim(__v) ([NSDecimalNumber decimalNumberWithDecimal:@((__v)).decimalValue])

#define _pair(__a, __b) ([CurrencyPair pairWithA:CurrencyType##__a b:CurrencyType##__b])

- (void)testRateModel1 {
    CurrencyPair *EUR_GBP = _pair(EUR, GBP);
    CurrencyPair *GBP_EUR = _pair(GBP, EUR);
    
    NSDictionary *rates = @{ EUR_GBP: _decim(2) };
    CurrencyRateModel *rateModel = [[CurrencyRateModel alloc] initWithRates:rates];
    
    XCTAssertEqualObjects(_decim(2), [rateModel rateOfPair:EUR_GBP]);
    XCTAssertEqualObjects(_decim(0.5), [rateModel rateOfPair:GBP_EUR]);
    
    XCTAssertEqualObjects(_decim(1), [rateModel rateOfPair:_pair(GBP, GBP)]);
    XCTAssertEqualObjects(_decim(1), [rateModel rateOfPair:_pair(EUR, EUR)]);
    
    XCTAssertNil([rateModel convertedValue:_decim(1) withPair:_pair(USD, EUR)]);
    XCTAssertEqualObjects(_decim(2), [rateModel convertedValue:_decim(1) withPair:EUR_GBP]);
    XCTAssertEqualObjects(_decim(4), [rateModel convertedValue:_decim(2) withPair:EUR_GBP]);
    
    XCTAssertEqualObjects(_decim(0.5), [rateModel convertedValue:_decim(1) withPair:GBP_EUR]);
    XCTAssertEqualObjects(_decim(1), [rateModel convertedValue:_decim(2) withPair:GBP_EUR]);
}

- (void)testRateModel2 {
    NSDictionary *rates = @{ _pair(EUR, GBP): _decim(2),
                             _pair(EUR, USD): _decim(4) };
    CurrencyRateModel *rateModel = [[CurrencyRateModel alloc] initWithRates:rates];
    
    XCTAssertEqualObjects(_decim(0.5), [rateModel rateOfPair:_pair(USD, GBP)]);
    XCTAssertEqualObjects(_decim(2), [rateModel rateOfPair:_pair(GBP, USD)]);
}

- (void)testConversion {
    NSDictionary *rates = @{ _pair(EUR, GBP): _decim(2) };
    CurrencyRateModel *rateModel = [[CurrencyRateModel alloc] initWithRates:rates];
    
    NSDictionary *data = @{ @(CurrencyTypeEUR): _decim(100),
                            @(CurrencyTypeGBP): _decim(100) };
    CurrencyAmountModel *amountModel = [[CurrencyAmountModel alloc] initWithData:data rateModel:rateModel];
    
    XCTAssertNil([amountModel amountWithCurrency:CurrencyTypeUSD]);
    XCTAssertEqualObjects(_decim(100), [amountModel amountWithCurrency:CurrencyTypeEUR]);
    XCTAssertEqualObjects(_decim(100), [amountModel amountWithCurrency:CurrencyTypeGBP]);
    
    XCTAssertFalse([amountModel isAbleToConvertValue:_decim(1) fromCurrency:CurrencyTypeUSD to:CurrencyTypeGBP]);
    
    XCTAssertFalse([amountModel isAbleToConvertValue:_decim(49) fromCurrency:CurrencyTypeUSD to:CurrencyTypeGBP]);
    XCTAssertTrue([amountModel isAbleToConvertValue:_decim(1) fromCurrency:CurrencyTypeEUR to:CurrencyTypeGBP]);
    
    XCTAssertTrue([amountModel isAbleToConvertValue:[amountModel amountWithCurrency:CurrencyTypeEUR] fromCurrency:CurrencyTypeEUR to:CurrencyTypeGBP]);
    XCTAssertFalse([amountModel isAbleToConvertValue:_decim(210) fromCurrency:CurrencyTypeEUR to:CurrencyTypeGBP]);
    
    XCTAssertTrue([amountModel convertValue:[amountModel amountWithCurrency:CurrencyTypeEUR] fromCurrency:CurrencyTypeEUR to:CurrencyTypeGBP]);
    XCTAssertEqualObjects(_decim(0), [amountModel amountWithCurrency:CurrencyTypeEUR]);
    XCTAssertEqualObjects(_decim(300), [amountModel amountWithCurrency:CurrencyTypeGBP]);
    
    XCTAssertFalse([amountModel convertValue:_decim(1) fromCurrency:CurrencyTypeEUR to:CurrencyTypeGBP]);
    XCTAssertTrue([amountModel convertValue:_decim(0) fromCurrency:CurrencyTypeEUR to:CurrencyTypeGBP]);
    
    XCTAssertTrue([amountModel convertValue:[amountModel amountWithCurrency:CurrencyTypeGBP] fromCurrency:CurrencyTypeGBP to:CurrencyTypeEUR]);
    XCTAssertEqualObjects(_decim(150), [amountModel amountWithCurrency:CurrencyTypeEUR]);
    XCTAssertEqualObjects(_decim(0), [amountModel amountWithCurrency:CurrencyTypeGBP]);
}

@end
