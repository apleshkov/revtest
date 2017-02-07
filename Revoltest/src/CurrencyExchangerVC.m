//
//  ViewController.m
//  Revoltest
//
//  Created by Andrew Pleshkov on 03/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "CurrencyExchangerVC.h"
#import "Extensions.h"
#import "CurrencyPagerVC.h"
#import "CurrencyRateModel.h"
#import "CurrencyAmountModel.h"
#import "Style.h"


@interface CurrencyExchangerVC ()
<
CurrencyRateModelDelegate,
CurrencyPagerVCDelegate,
CurrencyPagerVCDataSource
>
@end


@implementation CurrencyExchangerVC {
    BOOL _isAlreadyAppeared;
    UIActivityIndicatorView *_spinner;
    
    CurrencyRateModel *_rateModel;
    CurrencyAmountModel *_amountModel;
    
    CurrencyPagerVC *_fromVC;
    CurrencyPagerVC *_toVC;
    NSLayoutConstraint *_bottomConstraint;
}

+ (NSArray<NSNumber *> *)_currencies {
    NSArray<NSNumber *> *currencies = @[@(CurrencyTypeEUR), @(CurrencyTypeGBP), @(CurrencyTypeUSD)];
    NSAssert(currencies.count == CurrencyTypeCount, @"Not all currencies are presented");
    return currencies;
}

- (void)_createPagers {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Exchange"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(_exchangeButtonTapped)];
    
    UIStackView *stackView = [UIStackView tst_stackViewWithViews:@[]
                                                            axis:UILayoutConstraintAxisVertical
                                                         spacing:0
                                                    distribution:UIStackViewDistributionFillEqually
                                                       alignment:UIStackViewAlignmentFill];
    
    _fromVC = [[CurrencyPagerVC alloc] initWithConversionDirection:CurrencyConversionDirectionFrom];
    _toVC = [[CurrencyPagerVC alloc] initWithConversionDirection:CurrencyConversionDirectionTo];
    
    NSArray<CurrencyPagerVC *> *pagers = @[_fromVC, _toVC];
    [pagers tst_each:^(CurrencyPagerVC * _Nonnull obj, NSUInteger idx) {
        obj.delegate = self;
        obj.dataSource = self;
        [self addChildViewController:obj];
        [stackView addArrangedSubview:obj.view];
        [obj didMoveToParentViewController:self];
    }];
    
    [self.view addSubview:stackView];
    [stackView autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [stackView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [stackView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    _bottomConstraint = [stackView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
    [self _reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)loadView {
    [super loadView];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.color = [StyleColorTextPrimary colorWithAlphaComponent:0.5];
    [_spinner startAnimating];
    [self.view addSubview:_spinner];
    
    [_spinner autoCenterInSuperview];
    
    _rateModel = [CurrencyRateModel new];
    _rateModel.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_isAlreadyAppeared) {
        [_rateModel startLoading];
    }
    _isAlreadyAppeared = YES;
}

#pragma mark

- (void)_reloadData {
    [_fromVC reloadData];
    [_toVC reloadData];
}

- (void)_exchangeButtonTapped {
    CurrencyVC *fromPage = _fromVC.currentPage;
    CurrencyVC *toPage = _toVC.currentPage;
    if (!fromPage || !toPage) {
        return;
    }
    if ([_amountModel convertValue:fromPage.value fromCurrency:fromPage.currency to:toPage.currency]) {
        [_fromVC resetCurrentValue];
        [self _reloadData];
    }
}

#pragma mark <CurrencyRateModelDelegate>

- (void)currencyRateModel:(CurrencyRateModel *)rateModel didUpdateRatesWithError:(NSError *)error {
    TSTQueueMainAssert();
    if (error) {
        NSLog(@"ERROR: %@", error);
        return;
    }
    if (_amountModel) {
        [self _reloadData];
        return;
    }
    [_spinner stopAnimating];
    
    NSMutableDictionary<NSNumber *,NSDecimalNumber *> *data = [NSMutableDictionary new];
    [[CurrencyExchangerVC _currencies] tst_each:^(NSNumber * _Nonnull obj, NSUInteger idx) {
        data[obj] = [NSDecimalNumber decimalNumberWithDecimal:@(100).decimalValue];
    }];
    _amountModel = [[CurrencyAmountModel alloc] initWithData:data rateModel:_rateModel];
    
    [self _createPagers];
    [_fromVC becomeFirstResponder];
}

#pragma mark <CurrencyPagerVCDelegate>

- (void)currencyPagerVC:(CurrencyPagerVC *)currencyPagerVC didSelectPageAtIndex:(NSUInteger)index {
    if (currencyPagerVC == _fromVC) {
        [_toVC reloadData];
    } else {
        [_fromVC.currentPage reloadData];
    }
}

- (void)currencyPagerVC:(CurrencyPagerVC *)currencyPagerVC didUpdateValueOfPageAtIndex:(NSUInteger)index {
    if (currencyPagerVC == _fromVC) {
        [_toVC reloadData];
    }
}

#pragma mark <CurrencyPagerVCDataSource>

- (NSArray<NSNumber *> *)currencyPagerVCCurrencies:(CurrencyPagerVC *)currencyPagerVC {
    return [CurrencyExchangerVC _currencies];
}

- (NSDecimalNumber *)currencyPagerVC:(CurrencyPagerVC *)pagerVC convertedValueForPageAtIndex:(NSUInteger)index {
    CurrencyVC *pageA = [pagerVC pageAtIndex:index];
    CurrencyVC *pageB = [self _oppositePagerForPager:pagerVC].currentPage;
    if (!pageB) {
        return nil;
    }
    NSDecimalNumber *value = pageB.value;
    CurrencyPair *pair = [CurrencyPair pairWithA:pageB.currency b:pageA.currency];
    return [_rateModel convertedValue:value withPair:pair];
}

- (NSDecimalNumber *)currencyPagerVC:(CurrencyPagerVC *)pagerVC forPageAtIndex:(NSUInteger)index conversionRateAgainstCurrency:(CurrencyType)otherCurrency {
    CurrencyVC *pageA = [pagerVC pageAtIndex:index];
    CurrencyPair *pair = [CurrencyPair pairWithA:pageA.currency b:otherCurrency];
    return [_rateModel rateOfPair:pair];
}

- (NSDecimalNumber *)currencyPagerVC:(CurrencyPagerVC *)pagerVC availableAmountForPageAtIndex:(NSUInteger)index {
    return [_amountModel amountWithCurrency:[pagerVC pageAtIndex:index].currency];
}

- (BOOL)currencyPagerVC:(CurrencyPagerVC *)pagerVC isConvertibleValueFromPageAtIndex:(NSUInteger)index {
    CurrencyVC *pageA = [pagerVC pageAtIndex:index];
    CurrencyVC *pageB = [self _oppositePagerForPager:pagerVC].currentPage;
    if (!pageB) {
        return NO;
    }
    return [_amountModel isAbleToConvertValue:pageA.value fromCurrency:pageA.currency to:pageB.currency];
}

- (CurrencyType)currencyPagerVC:(CurrencyPagerVC *)pagerVC currencyToConvertAgainstForPageAtIndex:(NSUInteger)index {
    CurrencyVC *page = [self _oppositePagerForPager:pagerVC].currentPage;
    return page.currency;
}

#pragma mark

- (CurrencyPagerVC *)_oppositePagerForPager:(CurrencyPagerVC *)pagerVC {
    if (pagerVC == _fromVC) {
        return _toVC;
    }
    if (pagerVC == _toVC) {
        return _fromVC;
    }
    assert(NO);
}

#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [(NSNumber *)userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = keyboardFrameValue.CGRectValue;
    CGFloat keyboardHeight = keyboardFrame.size.height;
    _bottomConstraint.constant = -keyboardHeight;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration = [(NSNumber *)userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    _bottomConstraint.constant = 0;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
