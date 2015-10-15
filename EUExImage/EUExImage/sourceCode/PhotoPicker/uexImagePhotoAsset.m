//
//  uexImagePhotoAsset.m
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImagePhotoAsset.h"

@implementation uexImagePhotoAsset
-(instancetype)initWithAsset:(ALAsset *)photoAsset{
    self=[super init];
    if(self){
        self.assetURL=[photoAsset valueForProperty:ALAssetPropertyAssetURL];
        self.thumbImage=[UIImage imageWithCGImage:[photoAsset thumbnail]];
    }
    return self;
}


-(void)fetchOriginImageWithBlock:(uexImagePhotoAssetFetchImageBlock)completion{
    ALAssetsLibrary *assetsLibrary=[ALAssetsLibrary new];
    NSURL *assetURL=self.assetURL;
    [assetsLibrary assetForURL:assetURL
                   resultBlock:^(ALAsset *asset) {
                       if (asset) {
                           if(completion){
                               completion([asset uexImage_OriginImage]);
                           }
                       } else {
                           [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   if ([result.defaultRepresentation.url isEqual:assetURL]) {
                                       if(completion){
                                           completion([asset uexImage_OriginImage]);
                                       }
                                       *stop=YES;
                                   }
                               }];
                           } failureBlock:^(NSError *error) {
                               if(completion){
                                   completion(nil);
                               }
                               NSLog(@"Error: %@", [error localizedDescription]);
                           }];
                       }
                   } failureBlock:^(NSError *error) {
                       if(completion){
                           completion(nil);
                       }
                       NSLog(@"Error: %@", [error localizedDescription]);
                   }];
}

@end
