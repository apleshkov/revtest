//
//  RootVC.m
//  Revoltest
//
//  Created by Andrew Pleshkov on 07/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#import "RootVC.h"
#import "CurrencyExchangerVC.h"
#import "Extensions.h"

@implementation RootVC

- (void)loadView {
    [super loadView];
    
    CurrencyExchangerVC *exchangerVC = [CurrencyExchangerVC new];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:exchangerVC];
    [self addChildViewController:navVC];
    [self.view addSubview:navVC.view];
    [navVC.view autoPinEdgesToSuperviewEdges];
    [navVC didMoveToParentViewController:self];
}

@end
