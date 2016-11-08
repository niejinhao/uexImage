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
@interface uexImageCropper : NSObject<EUExImageWidget>
@property (nonatomic,weak)EUExImage * EUExImage;
@property (nonatomic,assign)BOOL usePng;
@property (nonatomic,strong)UIImage *imageToBeCropped;
@property (nonatomic,assign)CGFloat quality;
@property (nonatomic,assign)RSKImageCropMode mode;
@end
