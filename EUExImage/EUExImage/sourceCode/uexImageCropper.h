//
//  uexImageCropper.h
//  EUExImage
//
//  Created by CeriNo on 15/9/29.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EUExImage.h"
#import <RSKImageCropper/RSKImageCropper.h>



typedef NS_ENUM(NSInteger,uexImageCropShape){
    uexImageCropShapeSquare     = 0,
    uexImageCropShapeCircle     = 1,
    uexImageCropShapeRect4x3    = 3,
    uexImageCropShapeRect16x9   = 4
};


@interface uexImageCropper : NSObject<EUExImageWidget>
@property (nonatomic,weak)EUExImage * EUExImage;
@property (nonatomic,assign)BOOL usePng;
@property (nonatomic,strong)UIImage *imageToBeCropped;
@property (nonatomic,assign)CGFloat quality;
@property (nonatomic,assign)uexImageCropShape shape;
@property (nonatomic,strong)ACJSFunctionRef *cb;
@end
