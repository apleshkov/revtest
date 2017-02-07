//
//  Style.h
//  Revoltest
//
//  Created by Andrew Pleshkov on 05/02/17.
//  Copyright © 2017 test. All rights reserved.
//

#pragma mark - COLOR

static inline UIColor *HEXAColor(uint32_t hex, CGFloat alpha) {
    CGFloat red = ((hex >> 16) & 0xFF) / 255.f;
    CGFloat green = ((hex >> 8) & 0xFF) / 255.f;
    CGFloat blue = (hex & 0xFF) / 255.f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#define StyleColorTextPrimary   ([UIColor blackColor])
#define StyleColorTextError     ([UIColor redColor])
#define StyleColorLightGray     (HEXAColor(0xeeeeee, 1))

#define StyleColorCurrencyTo    (HEXAColor(0x009933, 1))

#pragma mark - FONT

#define _StyleFontSized(__size, __weight) ([UIFont systemFontOfSize:(__size) weight:UIFontWeight##__weight])

#define StyleFontRegularSized(__size)   _StyleFontSized((__size), Regular)

#define StyleFontBoldSized(__size)      _StyleFontSized((__size), Bold)
