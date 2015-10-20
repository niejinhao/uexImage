//
//  uexImagePhotoPicker.m
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImagePhotoPicker.h"
#import "uexImageAlbumPickerController.h"
#import "MWPhotoBrowser.h"
#import "uexImagePhotoPickerCaptionView.h"
#import "MBProgressHUD.h"
@interface uexImagePhotoPicker()<MWPhotoBrowserDelegate>
@property (nonatomic,strong)uexImagePhotoAssetGroup *dataSource;
@property (nonatomic,strong)MWPhotoBrowser *photoPicker;
@property (nonatomic,strong)UINavigationController *nav;
@property (nonatomic,strong)NSMutableArray<MWPhoto *> *thumbs;

@property (nonatomic,assign)NSInteger alreadySelectedCount;
@property (nonatomic,assign)NSInteger numberOfSelectedAssetsInOtherGroup;

@property (nonatomic,strong)uexImagePhotoPickerCaptionView *captionViewEven;
@property (nonatomic,strong)uexImagePhotoPickerCaptionView *captionViewOdd;
@property (nonatomic,strong)RACCommand *pickFinishCommand;
@end


@implementation uexImagePhotoPicker
-(instancetype)initWithController:(uexImageAlbumPickerController *)controller{
    self=[super init];
    if(self){
        self.controller=controller;
        self.thumbs=[NSMutableArray array];
        self.needToShowCannotFinishToast=NO;

    }
    return self;
}


-(RACCommand *)pickFinishCommand{
    if(!_pickFinishCommand){
        _pickFinishCommand=[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
            return [self.controller.model materializedCheckIfSelectedAssetsValidSignal];
        }];
        [[_pickFinishCommand executionSignals] subscribeNext:^(RACSignal *execution){
            [[execution dematerialize] subscribeError:^(NSError *error) {
                self.needToShowCannotFinishToast=YES;
            } completed:^{

                _controller.view.hidden=NO;
                _controller.navigationController.navigationBar.hidden=NO;
                [self.nav dismissViewControllerAnimated:YES completion:^{
                    
                    _photoPicker=nil;
                    [self doClearThings];
                    [self.controller.model finishPick];
                    
                }];

            }];

        }];
    }
    return _pickFinishCommand;
}

-(BOOL)openWithIndex:(NSInteger)index{



    _dataSource=_controller.model.assetsGroups[index];
    if([_dataSource.assets count]==0){
        return NO;
    }
    _captionViewEven=[[uexImagePhotoPickerCaptionView alloc]init];
    _captionViewOdd=[[uexImagePhotoPickerCaptionView alloc]init];
    for(uexImagePhotoAsset *asset in _dataSource.assets){
        [asset refreshSelectStatus];
        if(asset.selected){
            _alreadySelectedCount++;
        }
        [self.thumbs addObject:[MWPhoto photoWithImage:asset.thumbImage]];


    }
    _numberOfSelectedAssetsInOtherGroup=_controller.model.currentSelectedNumber-_alreadySelectedCount;

    _photoPicker = [[MWPhotoBrowser alloc]initWithDelegate:self];
    _photoPicker.displaySelectionButtons=YES;
    _photoPicker.startOnGrid=YES;
    _photoPicker.enableGrid=YES;
    _photoPicker.zoomPhotosToFill=YES;
    _photoPicker.displayActionButton=NO;
    _photoPicker.alwaysShowControls=YES;
    
    [_photoPicker combineWithPhotoPicker:self];
    self.nav=[[UINavigationController alloc]initWithRootViewController:_photoPicker];

        [_controller presentViewController:self.nav animated:YES completion:^{
            _controller.view.hidden=YES;
            _controller.navigationController.navigationBar.hidden=YES;
            [self updateCaptionInfo];
        }];
    return YES;
    //[_controller.navigationController pushViewController:_photoPicker animated:YES];
    



}

-(void)doClearThings{
    [self.thumbs removeAllObjects];
    _alreadySelectedCount=0;
    self.dataSource=nil;
    self.photoPicker=nil;
    self.numberOfSelectedAssetsInOtherGroup=0;
    self.captionViewEven=nil;
    self.captionViewOdd=nil;
    self.nav=nil;

}

-(void)updateCaptionInfo{
    NSString *text =[NSString stringWithFormat:@"当前相册已选择%ld张照片,总共选择%ld张照片",(long)self.alreadySelectedCount,(long)self.controller.model.currentSelectedNumber];
    [self.captionViewEven.textLabel setText:text];
    [self.captionViewOdd.textLabel setText:text];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return [_dataSource.assets count];
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    
    uexImagePhotoAsset *asset=self.dataSource.assets[index];
    UIImage * image=[asset syncFetchImage:uexImagePhotoAssetFetchFullScreenImage];

    MWPhoto *photo=[MWPhoto photoWithImage:image];
    
    return photo;
     

}



- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index{
    return _thumbs[index];
}
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index{
    [self updateCaptionInfo];
    if(index & 1){
        return self.captionViewOdd;
    }else{
        return self.captionViewEven;
    }

}
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index{
    return _dataSource.name;
}
//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index{
    uexImagePhotoAsset *asset =_dataSource.assets[index];
    return asset.selected;
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected{
    uexImagePhotoAsset *asset =_dataSource.assets[index];
    if(selected){
        [asset doSelect];
        _alreadySelectedCount++;
    }else{
        [asset doUnselect];
        _alreadySelectedCount--;
    }
    [self updateCaptionInfo];
}
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser{
    _controller.view.hidden=NO;
    _controller.navigationController.navigationBar.hidden=NO;
    [self.nav dismissViewControllerAnimated:YES completion:^{

        _photoPicker=nil;
        [self doClearThings];

    }];

}


@end
