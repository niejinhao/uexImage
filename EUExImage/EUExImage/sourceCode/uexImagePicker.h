//
//  uexImagePicker.h
//  EUExImage
//
//  Created by CeriNo on 15/9/29.
//  Copyright © 2015年 AppCan. All rights reserved.
//
#import "EUExImage.h"
#import <Foundation/Foundation.h>


@interface uexImagePicker : NSObject<EUExImageWidget>

@property (nonatomic,weak)EUExImage * EUExImage;
@property (nonatomic,assign)CGFloat quality;
@property (nonatomic,assign)NSInteger min;
@property (nonatomic,assign)NSInteger max;
@property (nonatomic,assign)BOOL usePng;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,assign)BOOL detailedInfo;
@end
