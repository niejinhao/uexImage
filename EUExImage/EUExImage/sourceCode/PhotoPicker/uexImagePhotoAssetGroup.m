//
//  uexImagePhotoAssetGroup.m
//  EUExImage
//
//  Created by CeriNo on 15/10/16.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImagePhotoAssetGroup.h"
#import "uexImageAlbumPickerModel.h"
@implementation uexImagePhotoAssetGroup


-(instancetype)initWithAssetsGroup:(ALAssetsGroup *)group inModel:(uexImageAlbumPickerModel *)model{
    self=[super init];
    if(self){
        self.type=[group valueForProperty:ALAssetsGroupPropertyType];
        self.assets=[NSMutableArray array];
        self.name=[group valueForProperty:ALAssetsGroupPropertyName];
        self.inModel=model;
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result){
                uexImagePhotoAsset *asset=[[uexImagePhotoAsset alloc]initWithAsset:result observer:self.inModel];
                [self.assets addObject:asset];

            }

        }];
    }
    return self;
}
@end
