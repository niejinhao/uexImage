//
//  uexImagePhotoAsset.m
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImagePhotoAsset.h"

@implementation uexImagePhotoAsset
-(instancetype)initWithAsset:(ALAsset *)photoAsset
                    observer:(id<uexImagePhotoAssetObserver>)observer{
    self=[super init];
    if(self){
        self.assetURL=[photoAsset valueForProperty:ALAssetPropertyAssetURL];
        self.thumbImage=[UIImage imageWithCGImage:[photoAsset thumbnail]];
        self.observer=observer;
        [self refreshSelectStatus];
    }
    return self;
}


-(void)doSelect{
    if(![_observer.selectedURLs containsObject:self.assetURL]){
        [_observer.selectedURLs addObject:self.assetURL];
        _observer.currentSelectedNumber++;
        [self refreshSelectStatus];
    }

}
-(void)doUnselect{
    if([_observer.selectedURLs containsObject:self.assetURL]){
        [_observer.selectedURLs removeObject:self.assetURL];
        _observer.currentSelectedNumber--;
        [self refreshSelectStatus];
    }

}

-(void)refreshSelectStatus{
    self.selected=[_observer.selectedURLs containsObject:self.assetURL];
}

-(UIImage *)fetchOriginImage{
    ALAssetsLibrary *assetsLibrary=self.observer.assetsLibrary;
    NSURL *assetURL=self.assetURL;
    __block UIImage *originImage=nil;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    UEXIMAGE_ASYNC_DO_IN_GLOBAL_QUEUE(^{
        [assetsLibrary assetForURL:assetURL
                       resultBlock:^(ALAsset *asset) {
                           if (asset) {
                               originImage=[asset uexImage_OriginImage];
                               dispatch_semaphore_signal(sema);
                           } else {
                               [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                   [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                       if ([result.defaultRepresentation.url isEqual:assetURL]) {
                                           originImage=[asset uexImage_OriginImage];
                                           *stop=YES;
                                           dispatch_semaphore_signal(sema);
                                       }
                                   }];
                               } failureBlock:^(NSError *error) {
                                   NSLog(@"Error: %@", [error localizedDescription]);
                                   dispatch_semaphore_signal(sema);
                               }];
                           }
                       } failureBlock:^(NSError *error) {
                           NSLog(@"Error: %@", [error localizedDescription]);
                           dispatch_semaphore_signal(sema);
                       }];
        
        
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    return originImage;
}

@end
