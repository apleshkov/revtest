//
//  UIStackView+Test.h
//  Revoltest
//
//  Created by Andrew Pleshkov on 05/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStackView (Test)

+ (nonnull instancetype)tst_stackViewWithViews:(nonnull NSArray<UIView *> *)views axis:(UILayoutConstraintAxis)axis spacing:(CGFloat)spacing distribution:(UIStackViewDistribution)distribution alignment:(UIStackViewAlignment)alignment;

@end
