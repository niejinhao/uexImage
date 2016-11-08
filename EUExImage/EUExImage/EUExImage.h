//
//  EUExImage.h
//  EUExImage
//
//  Created by Cerino on 15/9/23.
//  Copyright © 2015年 AppCan. All rights reserved.
//



#import "EUExBase.h"
#import <Foundation/Foundation.h>

@class EBrowserView;
extern NSString * const cUexImageCallbackIsCancelledKey;
extern NSString * const cUexImageCallbackDataKey;
extern NSString * const cUexImageCallbackIsSuccessKey;




@interface EUExImage : EUExBase


//-(void)longPress:(NSString *)string;
-(void)presentViewController:(UIViewController *)vc animated:(BOOL)flag;
-(void)dismissViewController:(UIViewController *)vc
                    Animated:(BOOL)flag
                  completion:(void (^)(void))completion;
-(void)callbackJsonWithName:(NSString *)name Object:(id)obj;
-(NSString *)saveImage:(UIImage *)image quality:(CGFloat)quality usePng:(BOOL)usePng;
@end



@protocol EUExImageWidget <NSObject>

@required
-(instancetype)initWithEUExImage:(EUExImage*)EUExImage;

-(void)open;

-(void)clean;

@optional

@end
