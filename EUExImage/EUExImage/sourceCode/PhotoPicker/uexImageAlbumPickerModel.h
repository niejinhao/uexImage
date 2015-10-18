//
//  uexImageAlbumPickerModel.h
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uexImagePhotoAsset.h"

@protocol uexImagePhotoPickerDelegate;

typedef NS_ENUM(NSInteger,uexImagePickLimitStatus){
    uexImagePickWithNoLimit,
    uexImagePickWithMaximumLimit,
    uexImagePickWithMinimumLimit,
    uexImagePickWithBothMaxAndMinLimit
};

@interface uexImageAlbumPickerModel : NSObject<uexImagePhotoAssetObserver>


@property (nonatomic,weak)id<uexImagePhotoPickerDelegate> delegate;

@property (nonatomic,strong)RACCommand * cancelCommand;
@property (nonatomic,strong)RACCommand * confirmCommand;


@property (nonatomic,assign)NSInteger minimumSelectedNumber;
@property (nonatomic,assign)NSInteger maximumSelectedNumber;
@property (nonatomic,assign)uexImagePickLimitStatus limitStatus;

@property (nonatomic,copy)NSString *selectInfoString;



@property (nonatomic,assign)BOOL needReloadData;

@property (nonatomic,strong)ALAssetsLibrary *assetsLibrary;
@property (nonatomic,strong)NSMutableArray *assetsGroups;


@property (nonatomic,strong)NSMutableOrderedSet *selectedURLs;
@property (nonatomic,assign)NSInteger currentSelectedNumber;



-(BOOL)checkIfSelectedNumbersValid:(NSInteger)selectedNumbers;
-(void)finishPick;
-(RACSignal *)comfirmValidSignal;
@end


@protocol uexImagePhotoPickerDelegate<NSObject>
@optional
-(void)uexImageAlbumPickerModelDidCancelPickingAction:(uexImageAlbumPickerModel*)model;

-(void)uexImageAlbumPickerModel:(uexImageAlbumPickerModel *)model didFinishPickingAction:(NSArray *)assets;//assets 是ALAssets构成的数组
@end