//
//  uexImagePicker.m
//  EUExImage
//
//  Created by CeriNo on 15/9/29.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImagePicker.h"
#import "EUExImage.h"
#import "uexImageAlbumPickerController.h"
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import <Photos/Photos.h>
@interface uexImagePicker()<uexImagePhotoPickerDelegate>
//@property (nonatomic,strong)QBImagePickerController *picker;
@property uexImageAlbumPickerModel *model;
@property UINavigationController *picker;
@end

@implementation uexImagePicker
-(instancetype)initWithEUExImage:(EUExImage *)EUExImage{
    self=[super init];
    if(self){
        self.EUExImage=EUExImage;
        [self setDafaultConfig];
    }
    return self;
}

-(void)open{
    uexImageAlbumPickerModel *model =[[uexImageAlbumPickerModel alloc]init];
    self.model=model;
    self.model.delegate=self;
    _model.minimumSelectedNumber=self.min;
    _model.maximumSelectedNumber=self.max;
    uexImageAlbumPickerController *albumPickerController =[[uexImageAlbumPickerController alloc]initWithModel:self.model];
    self.picker=[[UINavigationController alloc]initWithRootViewController:albumPickerController];
    [self.EUExImage presentViewController:self.picker animated:YES];
    
}




-(void)clean{
    self.picker=nil;
    self.model=nil;
    [self setDafaultConfig];
}


-(void)setDafaultConfig{

    self.quality=0.5;
    self.usePng=NO;
    self.min=1;
    self.max=0;
    self.picker=nil;
    self.detailedInfo=NO;
}


#pragma mark - uexImagePhotoPickerDelegate
-(void)uexImageAlbumPickerModelDidCancelPickingAction:(uexImageAlbumPickerModel *)model{
    [self.EUExImage dismissViewController:self.picker Animated:YES completion:^{
        [self.EUExImage callbackJsonWithName:@"onPickerClosed" Object:@{cUexImageCallbackIsCancelledKey:@(YES)}];
        
        [self clean];
    }];
}

-(void)uexImageAlbumPickerModel:(uexImageAlbumPickerModel *)model didFinishPickingAction:(NSArray<ALAsset *> *)assets{
    UEXIMAGE_ASYNC_DO_IN_GLOBAL_QUEUE(^{
        UEXIMAGE_ASYNC_DO_IN_MAIN_QUEUE(^{[MBProgressHUD showHUDAddedTo:self.picker.view animated:YES];});
        
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setValue:@(NO) forKey:cUexImageCallbackIsCancelledKey];
        NSMutableArray *dataArray =[NSMutableArray array];
        NSMutableArray *detailedInfoArray=nil;
        if(self.detailedInfo){
            detailedInfoArray=[NSMutableArray array];
        }
        
        for(ALAsset * asset in assets){
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSLog(@"---size-%lld",representation.size / 1024);
            
            //竖屏图片方向有时候有问题
//            UIImage * assetImage =[UIImage imageWithCGImage:[representation fullScreenImage] scale:representation.scale orientation:(UIImageOrientation)representation.orientation];
//            NSLog(@"---assetImage w-%f  h-%f",assetImage.size.width,assetImage.size.height);
            
            
            UIImage * assetImage =[UIImage imageWithCGImage:[representation fullResolutionImage] scale:representation.scale orientation:(UIImageOrientation)representation.orientation];
//            NSLog(@"---assetImage w-%f  h-%f",assetImage.size.width,assetImage.size.height);
            UIImage *originImage = assetImage;
            if(assetImage.size.width > 1920 || assetImage.size.height > 1920){
                CGFloat longer = assetImage.size.width > assetImage.size.height ? assetImage.size.width : assetImage.size.height;
                CGFloat scale = 1920/longer;
                CGSize originSize = CGSizeMake(assetImage.size.width * scale, assetImage.size.height * scale);
                originImage = [self OriginImage:assetImage scaleToSize:originSize];
            }
//            NSLog(@"---originImage w-%f  h-%f",originImage.size.width,originImage.size.height);
            
            NSString * imagePath =[self.EUExImage saveImage:originImage quality:self.quality usePng:self.usePng];
//            NSLog(@"----imagePath-%@",imagePath);
            if(imagePath){
                [dataArray addObject:imagePath];
                if(detailedInfoArray){
                    NSMutableDictionary *info=[NSMutableDictionary dictionary];
                    [info setValue:imagePath forKey:@"localPath"];
                    [info setValue:@((int)[[asset valueForProperty:ALAssetPropertyDate] timeIntervalSince1970]) forKey:@"timestamp"];
                    CLLocation *location=[asset valueForProperty:ALAssetPropertyLocation];
                    if(location){
                        [info setValue:@(location.coordinate.latitude) forKey:@"latitude"];
                        [info setValue:@(location.coordinate.longitude) forKey:@"longitude"];
                        [info setValue:@(location.altitude) forKey:@"altitude"];
                    }
                    
                    //不丢失exif
                    Byte *buffer = (Byte*)malloc(representation.size);
                    NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
                    NSData *imgData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                    CGImageSourceRef imgSource = CGImageSourceCreateWithData((CFDataRef)imgData, nil);
                    CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imgSource, 0, NULL);
//                    NSLog(@"--imageInfo:%@",imageInfo);
                    NSDictionary *imageInDict = CFBridgingRelease(imageInfo);
                    if([imageInDict objectForKey:@"{Exif}"]){
                        NSDictionary *Exif = [imageInDict objectForKey:@"{Exif}"];
                        
//                        [info setValue:[Exif objectForKey:@"LensMake"] forKey:@"make"];
//                        [info setValue:[Exif objectForKey:@"LensModel"] forKey:@"model"];
                        if([Exif objectForKey:@"LensMake"] || [Exif objectForKey:@"LensModel"]){
                            NSString *LensMake = @"";
                            if([Exif objectForKey:@"LensMake"]){
                                LensMake = [[Exif objectForKey:@"LensMake"] stringByAppendingString:@" "];
                            }
                            NSString *LensModel = @"";
                            if([Exif objectForKey:@"LensModel"]){
                                LensModel = [Exif objectForKey:@"LensModel"];
                            }
                            NSString *model = [LensMake stringByAppendingString:LensModel];
                            [info setValue:model forKey:@"model"];
                        }
                        [info setValue:[Exif objectForKey:@"ExposureTime"] forKey:@"exposureTime"];
                        [info setValue:[Exif objectForKey:@"ExposureBiasValue"] forKey:@"exposureBiasValue"];
                        [info setValue:[Exif objectForKey:@"FocalLength"] forKey:@"focalLength"];
                        [info setValue:[Exif objectForKey:@"WhiteBalance"] forKey:@"whiteBalance"];
                        //在相机上光圈是FNumber
//                        [info setValue:[Exif objectForKey:@"ApertureValue"] forKey:@"aperture"];
                        [info setValue:[Exif objectForKey:@"FNumber"] forKey:@"aperture"];
                        [info setValue:[Exif objectForKey:@"Flash"] forKey:@"flash"];
                        
//                        [info setValue:[Exif objectForKey:@"ISOSpeedRatings"] forKey:@"iso"];
                        NSArray *iso = [Exif objectForKey:@"ISOSpeedRatings"];
                        if(iso && [iso isKindOfClass:[NSArray class]]){
                            [info setValue:iso[0] forKey:@"iso"];
                        }
                    }
                    //make
                    if([imageInDict objectForKey:@"{TIFF}"]){
                        NSDictionary *TIFF = [imageInDict objectForKey:@"{TIFF}"];
                        
                        if([TIFF objectForKey:@"Make"] || [TIFF objectForKey:@"Model"]){
                            NSString *eqpMake = @"";
                            if([TIFF objectForKey:@"Make"]){
                                eqpMake = [[TIFF objectForKey:@"Make"] stringByAppendingString:@" "];
                            }
                            NSString *eqpModel = @"";
                            if([TIFF objectForKey:@"Model"]){
                                eqpModel = [TIFF objectForKey:@"Model"];
                            }
                            NSString *make = [eqpMake stringByAppendingString:eqpModel];
                            [info setValue:make forKey:@"make"];
                        }
                    }
                    
                    [detailedInfoArray addObject:info];
                }
                
                
                
            }
            
        }
        [dict setValue:dataArray forKey:cUexImageCallbackDataKey];
        if(detailedInfoArray){
            [dict setValue:detailedInfoArray forKey:@"detailedImageInfo"];
        }
        UEXIMAGE_ASYNC_DO_IN_MAIN_QUEUE(^{[MBProgressHUD hideHUDForView:self.picker.view animated:YES];});
        [self.EUExImage dismissViewController:self.picker Animated:YES completion:^{
            [self.EUExImage callbackJsonWithName:@"onPickerClosed" Object:dict];
            [self clean];
        }];
        
        
        
    });
}

-(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}
+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
