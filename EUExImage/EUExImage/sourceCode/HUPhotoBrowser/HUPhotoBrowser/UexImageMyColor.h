//
//  MyColor.h
//  AppCanPlugin
//
//  Created by sdk-suit on 16/1/15.
//  Copyright © 2016年 zywx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UexImageMyColor : UIColor
+ (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
+ (UIColor*) colorWithHex:(NSInteger)hexValue;
+ (NSString *) hexFromUIColor: (UIColor*) color;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
@end
