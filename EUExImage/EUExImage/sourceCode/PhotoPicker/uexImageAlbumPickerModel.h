//
//  uexImageAlbumPickerModel.h
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uexImagePhotoAsset.h"
@interface uexImageAlbumPickerModel : NSObject

@property (nonatomic,strong)RACCommand * cancelCommand;
@property (nonatomic,strong)RACCommand * comfirmCommand;

@property (nonatomic,assign)NSInteger minimumSelectedNumber;
@property (nonatomic,assign)NSInteger maximumSelectedNumber;
@property (nonatomic,assign)NSInteger currentSelectedNumber;


@property (nonatomic,strong)ALAssetsLibrary *assetsLibrary;
@end
