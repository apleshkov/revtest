//
//  UIStackView+Test.m
//  Revoltest
//
//  Created by Andrew Pleshkov on 05/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "UIStackView+Test.h"

@implementation UIStackView (Test)

+ (instancetype)tst_stackViewWithViews:(NSArray<UIView *> *)views axis:(UILayoutConstraintAxis)axis spacing:(CGFloat)spacing distribution:(UIStackViewDistribution)distribution alignment:(UIStackViewAlignment)alignment {
    UIStackView *view = [[UIStackView alloc] initWithArrangedSubviews:views];
    view.axis = axis;
    view.spacing = spacing;
    view.distribution = distribution;
    view.alignment = alignment;
    return view;
}

@end
