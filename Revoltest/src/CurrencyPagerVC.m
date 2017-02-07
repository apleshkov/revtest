//
//  CurrencyPagerVC.m
//  Revoltest
//
//  Created by Andrew Pleshkov on 05/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "CurrencyPagerVC.h"
#import "CurrencyVC+Private.h"
#import "Extensions.h"

@interface CurrencyPagerVC ()
<
UIPageViewControllerDataSource,
UIPageViewControllerDelegate,
UITextFieldDelegate,
CurrencyVCDataSource
>

@end

@implementation CurrencyPagerVC {
    UITextField *_textField;
    CurrencyConversionDirection _conversionDirection;
    UIPageViewController *_pageVC;
    NSArray<CurrencyVC *> *_pages;
}

- (instancetype)initWithConversionDirection:(CurrencyConversionDirection)conversionDirection {
    self = [super initWithNibName:nil bundle:nil];
    _conversionDirection = conversionDirection;
    return self;
}

- (CurrencyVC *)currentPage {
    NSUInteger idx = [self _currentPageIndex];
    return [self pageAtIndex:idx];
}

- (CurrencyVC *)pageAtIndex:(NSUInteger)index {
    return _pages[index];
}

- (void)resetCurrentValue {
    self.currentPage.stringValue = nil;
    [self _syncStringValue];
}

- (void)reloadData {
    [_pages enumerateObjectsUsingBlock:^(CurrencyVC * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj reloadData];
    }];
}

- (void)loadView {
    [super loadView];
    
    _textField = ({
        UITextField *field = [UITextField new];
        field.delegate = self;
        field.keyboardType = UIKeyboardTypeDecimalPad;
        field.hidden = YES;
        field;
    });
    [self.view addSubview:_textField];
    
    NSArray<NSNumber *> *listOfCurrencies = TSTEnsure([self.dataSource currencyPagerVCCurrencies:self]);
    _pages = [listOfCurrencies tst_map:^id _Nonnull(NSNumber * _Nonnull obj, NSUInteger idx) {
        CurrencyVC *currencyVC = [[CurrencyVC alloc] initWithCurrency:obj.integerValue
                                                  conversionDirection:_conversionDirection];
        currencyVC.dataSource = self;
        return currencyVC;
    }];
    
    _pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                            options:nil];
    _pageVC.dataSource = self;
    _pageVC.delegate = self;
    
    [self addChildViewController:_pageVC];
    [self.view addSubview:_pageVC.view];
    [_pageVC.view autoPinEdgesToSuperviewEdges];
    [_pageVC didMoveToParentViewController:self];
    
    [_pageVC setViewControllers:@[_pages.firstObject]
                      direction:UIPageViewControllerNavigationDirectionForward
                       animated:NO
                     completion:nil];
    [self _syncStringValue];
}

- (BOOL)becomeFirstResponder {
    return [_textField becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return [_textField canBecomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_textField resignFirstResponder];
}

- (BOOL)canResignFirstResponder {
    return [_textField canResignFirstResponder];
}

#pragma mark

- (void)_syncStringValue {
    _textField.text = self.currentPage.stringValue;
}

- (void)_processInputWithString:(NSString *)string {
    _textField.text = string;
    self.currentPage.stringValue = string;
    [self.delegate currencyPagerVC:self didUpdateValueOfPageAtIndex:[self _currentPageIndex]];
}

#pragma mark

- (NSUInteger)_currentPageIndex {
    return [self _indexOfPage:_pageVC.viewControllers.firstObject];
}

- (CurrencyVC *)_pageWithIndex:(NSInteger)index {
    if (index >= 0 && index < _pages.count) {
        return _pages[index];
    }
    if (index < 0) {
        return _pages.lastObject;
    }
    return _pages.firstObject;
}

- (NSUInteger)_indexOfPage:(CurrencyVC *)page {
    return [_pages indexOfObject:page];
}

#pragma mark <UIPageViewControllerDataSource>

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger idx = ([_pages indexOfObject:(CurrencyVC *)viewController] + 1);
    return [self _pageWithIndex:idx];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger idx = ((NSInteger)[_pages indexOfObject:(CurrencyVC *)viewController] - 1);
    return [self _pageWithIndex:idx];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return _pages.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return [self _currentPageIndex];
}

#pragma mark <UIPageViewControllerDelegate>

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        [self _syncStringValue];
        [self.delegate currencyPagerVC:self didSelectPageAtIndex:[self _currentPageIndex]];
    }
}

#pragma mark <UITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *input = [[textField.text stringByReplacingCharactersInRange:range withString:string] mutableCopy];
    if (input.length >= 8) {
        return NO;
    }
    NSString *expression = @"^[0-9]*((\\.|,)[0-9]{0,2})?$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:input options:0 range:NSMakeRange(0, input.length)];
    if (numberOfMatches != 0) {
        if ([input isEqualToString:@"."]) {
            [self _processInputWithString:@"0."];
        } else if ([input isEqualToString:@"00"]) {
            [self _processInputWithString:@"0"];
        } else {
            [self _processInputWithString:input];
        }
    }
    return NO;
}

#pragma mark <CurrencyVCDataSource>

- (NSDecimalNumber *)currencyVCConvertedValueTo:(CurrencyVC *)currencyVC {
    return [self.dataSource currencyPagerVC:self convertedValueForPageAtIndex:[self _indexOfPage:currencyVC]];
}

- (nullable NSDecimalNumber *)currencyVC:(CurrencyVC *)currencyVC conversionRateAgainstCurrency:(CurrencyType)otherCurrency {
    return [self.dataSource currencyPagerVC:self forPageAtIndex:[self _indexOfPage:currencyVC] conversionRateAgainstCurrency:otherCurrency];
}

- (nullable NSDecimalNumber *)currencyVCAvailableAmount:(CurrencyVC *)currencyVC {
    return [self.dataSource currencyPagerVC:self availableAmountForPageAtIndex:[self _indexOfPage:currencyVC]];
}

- (BOOL)currencyVCIsConvertibleValueFrom:(CurrencyVC *)currencyVC {
    return [self.dataSource currencyPagerVC:self isConvertibleValueFromPageAtIndex:[self _indexOfPage:currencyVC]];
}

- (CurrencyType)currencyVCCurrencyToConvertAgainst:(CurrencyVC *)currencyVC {
    return [self.dataSource currencyPagerVC:self currencyToConvertAgainstForPageAtIndex:[self _indexOfPage:currencyVC]];
}

@end
