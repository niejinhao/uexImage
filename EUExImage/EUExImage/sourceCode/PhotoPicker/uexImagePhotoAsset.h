//
//  uexImagePhotoAsset.h
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALAsset+OriginImage.h"

@protocol uexImagePhotoAssetObserver;


typedef NS_ENUM(NSInteger,uexImagePhotoAssetFetchImageType) {
    uexImagePhotoAssetFetchOriginalImage,
    uexImagePhotoAssetFetchFullScreenImage,
};



@interface uexImagePhotoAsset : NSObject




@property (nonatomic,strong)NSURL *assetURL;
@property (nonatomic,strong)UIImage *thumbImage;
@property (nonatomic,weak)id<uexImagePhotoAssetObserver> observer;
@property (nonatomic,assign)BOOL selected;


-(instancetype)initWithAsset:(ALAsset *)photoAsset
                    observer:(id<uexImagePhotoAssetObserver>)observer;





-(UIImage *)syncFetchImage:(uexImagePhotoAssetFetchImageType)type;

-(void)doSelect;
-(void)doUnselect;
-(void)removeSelect;
-(void)refreshSelectStatus;

@end



@protocol uexImagePhotoAssetObserver<NSObject>
@property (nonatomic,strong)NSMutableOrderedSet *selectedURLs;
@property (nonatomic,assign)NSInteger currentSelectedNumber;
@property (nonatomic,strong)ALAssetsLibrary *assetsLibrary;
@end
