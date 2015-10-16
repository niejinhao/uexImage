//
//  uexImagePhotoAssetGroup.h
//  EUExImage
//
//  Created by CeriNo on 15/10/16.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uexImagePhotoAsset.h"
@class uexImageAlbumPickerModel;

@interface uexImagePhotoAssetGroup : NSObject


@property (nonatomic,assign)NSNumber *type;
@property (nonatomic,strong)NSMutableArray * assets;

@property (nonatomic,copy)NSString *name;
@property (nonatomic,weak)uexImageAlbumPickerModel *inModel;




-(instancetype)initWithAssetsGroup:(ALAssetsGroup *)group inModel:(uexImageAlbumPickerModel *)model;
@end