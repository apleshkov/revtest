//
//  Globals.h
//  Revoltest
//
//  Created by Andrew Pleshkov on 06/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#define TST_UNAVAILABLE(TEXT) __attribute__((unavailable(TEXT)))

#define TST_UNAVAILABLE_INITIALIZER TST_UNAVAILABLE("Unavailable initializer")

#define TST_UNAVAILABLE_INITIALIZER_IMP() GMFail()

#define TST_UNAVAILABLE_INIT_AND_NEW \
    + (nonnull instancetype)new TST_UNAVAILABLE(); \
    - (nonnull instancetype)init TST_UNAVAILABLE_INITIALIZER;

#define TST_UNAVAILABLE_VC_INITIALIZERS \
    TST_UNAVAILABLE_INIT_AND_NEW \
    - (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil TST_UNAVAILABLE_INITIALIZER; \
    TST_UNAVAILABLE_CODER_INITIALIZER

#define TST_UNAVAILABLE_CODER_INITIALIZER \
    - (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder TST_UNAVAILABLE_INITIALIZER;

#define TST_UNAVAILABLE_VIEW_INITIALIZERS \
    TST_UNAVAILABLE_INIT_AND_NEW \
    - (nonnull instancetype)initWithFrame:(CGRect)frame TST_UNAVAILABLE_INITIALIZER; \
    TST_UNAVAILABLE_CODER_INITIALIZER
