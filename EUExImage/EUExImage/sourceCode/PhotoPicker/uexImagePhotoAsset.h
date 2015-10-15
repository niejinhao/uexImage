//
//  uexImagePhotoAsset.h
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAsset+OriginImage.h"
@interface uexImagePhotoAsset : NSObject

typedef void (^uexImagePhotoAssetFetchImageBlock)(UIImage *);


@property (nonatomic,strong)NSURL *assetURL;
@property (nonatomic,strong)UIImage *thumbImage;


-(instancetype)initWithAsset:(ALAsset *)photoAsset;
-(void)fetchOriginImageWithBlock:(uexImagePhotoAssetFetchImageBlock)completion;
@end
