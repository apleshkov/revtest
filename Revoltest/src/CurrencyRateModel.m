//
//  CurrencyRateModel.m
//  Revoltest
//
//  Created by Andrew Pleshkov on 06/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "CurrencyRateModel.h"
#import "Extensions.h"
#import <IGHTMLQuery.h>

static const int64_t _kInterval = 30;
static const CurrencyType _kAnchorCurrency = CurrencyTypeEUR;

@implementation CurrencyRateModel {
    NSMutableDictionary<CurrencyPair *, NSDecimalNumber *> *_rates;
    NSURLSessionDataTask *_dataTask;
}

- (instancetype)init {
    return [self initWithRates:nil];
}

- (instancetype)initWithRates:(NSDictionary<CurrencyPair *,NSDecimalNumber *> *)rates {
    self = [super init];
    _rates = (rates ? [rates mutableCopy] : [NSMutableDictionary new]);
    return self;
}

- (NSDecimalNumber *)rateOfPair:(CurrencyPair *)pair {
    if (pair.a == pair.b) {
        return [NSDecimalNumber one];
    }
    NSDecimalNumber *rate = _rates[pair];
    if (!rate) {
        rate = [self _invertedRateOfPair:pair];
    }
    if (!rate) {
        rate = [self _calculatedRateOfPair:pair];
    }
    if ([rate isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return nil;
    }
    return rate;
}

- (NSDecimalNumber *)_invertedRateOfPair:(CurrencyPair *)pair {
    NSDecimalNumber *invertedRate = _rates[[CurrencyPair pairWithA:pair.b b:pair.a]];
    if (invertedRate) {
        return [[NSDecimalNumber one] decimalNumberByDividingBy:invertedRate];
    }
    return nil;
}

- (NSDecimalNumber *)_calculatedRateOfPair:(CurrencyPair *)pair {
    if (pair.a != _kAnchorCurrency && pair.b != _kAnchorCurrency) {
        NSDecimalNumber *rateA = [self rateOfPair:[CurrencyPair pairWithA:_kAnchorCurrency b:pair.a]];
        NSDecimalNumber *rateB = [self rateOfPair:[CurrencyPair pairWithA:_kAnchorCurrency b:pair.b]];
        if (rateA && rateB) {
            return [rateB decimalNumberByDividingBy:rateA];
        }
    }
    return nil;
}

- (NSDecimalNumber *)convertedValue:(NSDecimalNumber *)value withPair:(CurrencyPair *)pair {
    NSParameterAssert(value);
    NSDecimalNumber *rate = [self rateOfPair:pair];
    if (!rate) {
        return nil;
    }
    return [value decimalNumberByMultiplyingBy:rate];
}

- (void)startLoading {
    if (_dataTask && _dataTask.state == NSURLSessionTaskStateRunning) {
        return;
    }
    NSURL *url = [NSURL URLWithString:@"https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"];
    typeof(self) __weak weakSelf = self;
    _dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [weakSelf _didLoadData:data withError:error];
    }];
    [_dataTask resume];
}

- (NSNumber *)_currencyTypeWithString:(NSString *)string {
#define _matchCurrency(__c) if ([string isEqualToString:@#__c]) { return @(CurrencyType##__c); }
    _matchCurrency(USD)
    _matchCurrency(GBP)
    return nil;
}

- (void)_didLoadData:(NSData *)data withError:(NSError *)error {
    if (error) {
        [self _completeWithError:error];
        return;
    }
    if (data.length == 0) {
        NSError *error = [NSError errorWithDomain:CurrencyRateModelErrorDomain
                                             code:CurrencyRateModelErrorInvalidData
                                         userInfo:nil];
        [self _completeWithError:error];
        return;
    }
    NSError *parseError = nil;
    IGXMLDocument *doc = [[IGXMLDocument alloc] initWithXMLData:data encoding:@"utf8" error:&parseError];
    if (parseError) {
        [self _completeWithError:parseError];
        return;
    }
    IGXMLNodeSet *contents = [doc queryWithXPath:@"//*[@currency]"];
    [self _processXMLNodeSet:contents];
}

- (void)_processXMLNodeSet:(IGXMLNodeSet *)contents {
    typeof(_rates) newRates = [NSMutableDictionary new];
    [contents enumerateNodesUsingBlock:^(IGXMLNode *node, NSUInteger idx, BOOL *stop) {
        NSString *rawCurrency = [node attribute:@"currency"];
        NSNumber *currencyNum = [self _currencyTypeWithString:rawCurrency];
        if (!currencyNum) {
            return;
        }
        CurrencyType b = (CurrencyType)currencyNum.integerValue;
        NSString *rawRate = [node attribute:@"rate"];
        if (!rawRate) {
            return;
        }
        NSDecimalNumber *rate = [NSDecimalNumber decimalNumberWithString:rawRate];
        if ([[NSDecimalNumber notANumber] isEqualToNumber:rate]) {
            return;
        }
        CurrencyPair *pair = [CurrencyPair pairWithA:CurrencyTypeEUR b:b];
        newRates[pair] = rate;
    }];
    if (newRates.count == 0) {
        [self _scheduleLoading];
        return;
    }
    TSTQueueMainAsync(^{
        [newRates enumerateKeysAndObjectsUsingBlock:^(CurrencyPair * _Nonnull key, NSDecimalNumber * _Nonnull obj, BOOL * _Nonnull stop) {
            _rates[key] = obj;
        }];
        
        [self _completeWithError:nil];
    });
}

- (void)_completeWithError:(NSError *)error {
    TSTQueueMainAsync(^{
        [self.delegate currencyRateModel:self didUpdateRatesWithError:error];
    });
    [self _scheduleLoading];
}

- (void)_scheduleLoading {
    typeof(self) __weak weakSelf = self;
    TSTQueueMainAfter(_kInterval, ^{
        [weakSelf startLoading];
    });
}

@end
