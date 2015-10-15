//
//  uexIAPC_PhotoItem.m
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexIAPC_PhotoItem.h"
#import "ALAsset+uexIAPC_Origin_Image.h"
@implementation uexIAPC_PhotoItem


-(instancetype)initWithPhoto:(ALAsset *)photoAsset{
    self=[super init];
    if(self){
        self.assetURL=[photoAsset valueForProperty:ALAssetPropertyAssetURL];
        self.thumbImage=[UIImage imageWithCGImage:[photoAsset thumbnail]];
    }
    return self;
}


-(void)getOriginImageWithBlock:(uexIAPC_PhotoItemGetOriginImageBlock)completion{
    ALAssetsLibrary *assetsLibrary=[ALAssetsLibrary new];
    NSURL *assetURL=self.assetURL;
    [assetsLibrary assetForURL:assetURL
                   resultBlock:^(ALAsset *asset) {
                       if (asset) {
                           if(completion){
                               completion([asset uexIAPC_getOriginImage]);
                           }
                       } else {
                           [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   if ([result.defaultRepresentation.url isEqual:assetURL]) {
                                       if(completion){
                                           completion([asset uexIAPC_getOriginImage]);
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
