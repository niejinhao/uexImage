//
//  uexImageCropper.m
//  EUExImage
//
//  Created by CeriNo on 15/9/29.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImageCropper.h"

@interface uexImageCropper()<RSKImageCropViewControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic,strong)RSKImageCropViewController *cropper;

@end


@implementation uexImageCropper
-(instancetype)initWithEUExImage:(EUExImage *)EUExImage{
    self=[super init];
    if(self) {
        self.EUExImage=EUExImage;
        self.imageToBeCropped=nil;
        self.quality=0.5;
        self.mode=RSKImageCropModeSquare;
    }
    return self;
}


-(void)open{
    if(self.imageToBeCropped){
        [self openCropper];
    }else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker setDelegate:self];
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.mediaTypes = @[@"public.image"];

        [self.EUExImage presentViewController:picker animated:NO];
        
    }

}
-(void)clean{
    self.imageToBeCropped=nil;
    self.quality=0.5;
    self.mode=RSKImageCropModeSquare;
    self.cropper=nil;
}


-(void)openCropper{

    RSKImageCropViewController * cropper=[[RSKImageCropViewController alloc]initWithImage:self.imageToBeCropped cropMode:self.mode];
    cropper.delegate=self;
    
    self.cropper=cropper;
    
    [self.EUExImage presentViewController:cropper animated:YES];


}




#pragma mark - RSKImageCropViewControllerDelegate;
/**
 Tells the delegate that crop image has been canceled.
 */
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller{
    [self.EUExImage dismissViewController:controller Animated:YES completion:^{
            [self.EUExImage callbackJsonWithName:@"onCropperClosed" Object:@{cUexImageCallbackIsCancelledKey:@(YES)}];
    }];

}


/**
 Tells the delegate that the original image has been cropped. Additionally provides a crop rect and a rotation angle used to produce image.
 */
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle{
    UEXIMAGE_ASYNC_DO_IN_GLOBAL_QUEUE(^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@(NO) forKey:cUexImageCallbackIsCancelledKey];
        [dict setValue:[self.EUExImage saveImage:croppedImage quality:self.quality usePng:self.usePng] forKey:cUexImageCallbackDataKey];
        [self.EUExImage dismissViewController:controller Animated:YES completion:^{
            
            [self.EUExImage callbackJsonWithName:@"onCropperClosed" Object:dict];
            [self clean];
        }];
    });
    
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UEXIMAGE_ASYNC_DO_IN_GLOBAL_QUEUE(^{
        UIImage *checkImg= [info objectForKey:UIImagePickerControllerOriginalImage];
        self.imageToBeCropped=checkImg;
        [self.EUExImage dismissViewController:picker Animated:YES completion:^{
            
            [self openCropper];
        }];
    });
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.EUExImage dismissViewController:picker Animated:YES completion:^{
        [self.EUExImage callbackJsonWithName:@"onCropperClosed" Object:@{cUexImageCallbackIsCancelledKey:@(YES)}];
        [self clean];
    }];


}
@end
