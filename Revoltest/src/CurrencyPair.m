//
//  CurrencyPair.m
//  Revoltest
//
//  Created by Andrew Pleshkov on 06/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "CurrencyPair.h"
#import "Extensions.h"

@implementation CurrencyPair

- (instancetype)initWithA:(CurrencyType)a b:(CurrencyType)b {
    self = [super init];
    _a = a;
    _b = b;
    return self;
}

- (instancetype)initWithCurrency:(CurrencyType)currency {
    return [self initWithA:currency b:currency];
}

+ (instancetype)pairWithA:(CurrencyType)a b:(CurrencyType)b {
    return [[self alloc] initWithA:a b:b];
}

- (BOOL)isEqual:(id)object {
    CurrencyPair *other = TSTSafeCast(CurrencyPair, object);
    if (other) {
        return (self.a == other.a && self.b == other.b);
    }
    return NO;
}

- (NSUInteger)hash {
    return (self.a * 3 + (self.b + 1) * (CurrencyTypeCount + 187));
}

#pragma mark <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
