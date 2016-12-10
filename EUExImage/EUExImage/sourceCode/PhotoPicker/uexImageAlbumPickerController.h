//
//  uexImageAlbumPickerController.h
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "uexImagePhotoAssetGroup.h"
#import "uexImageAlbumPickerModel.h"
@class uexImagePhotoPicker;


@interface uexImageAlbumPickerController : UIViewController
@property (nonatomic,strong)uexImageAlbumPickerModel *model;
@property (nonatomic,strong)uexImagePhotoPicker *photoPicker;

- (instancetype)initWithModel:(uexImageAlbumPickerModel *)model;


@end
