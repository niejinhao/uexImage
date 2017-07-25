//
//  EUExImage.m
//  EUExImage
//
//  Created by Cerino on 15/9/23.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "EUExImage.h"
#import "EUtility.h"
#import "JSON.h"
#import "uexImageWidgets.h"
//#import "MSSBrowseDefine.h"
//#import "MSSBrowseBaseViewController.h"
//#import "MSSBrowseCollectionViewCell.h"
#import "UexImageMySingleton.h"
#import "PhotoBrowerList.h"
#import "EBrowserView.h"

#import "HUPhotoBrowser.h"
#import "PhotoCell.h"
#import "UIImageView+HUWebImage.h"

#import <Photos/Photos.h>


//style 为1 类型；

//#import "TZImagePickerController.h"
//#import <Photos/Photos.h>
//#import "EUtility.h"
//#import <AssetsLibrary/AssetsLibrary.h>
//#import <MediaPlayer/MediaPlayer.h>
//#import "TZImageManager.h"
//
//#import <Photos/PhotosTypes.h>



NSString * const cUexImageCallbackIsCancelledKey = @"isCancelled";
NSString * const cUexImageCallbackDataKey      = @"data";
NSString * const cUexImageCallbackIsSuccessKey = @"isSuccess";

@interface EUExImage()

{
    NSMutableArray *_selectedAssets;
    BOOL _isSelectOriginalPhoto;
}
@property(nonatomic,strong)NSMutableArray* selectedPhotos;


@property (nonatomic,assign)UIStatusBarStyle initialStatusBarStyle;
@property (nonatomic,strong)UIPopoverController *iPadPop;
@property (nonatomic,assign)BOOL usingPop;

@property (nonatomic,strong)uexImageCropper *cropper;
@property (nonatomic,strong)uexImagePicker *picker;
@property (nonatomic,strong)uexImageBrowser *browser;
@property (nonatomic,assign)BOOL enableIpadPop;
@property(nonatomic,assign)BOOL usePicturePng;

@property(nonatomic,strong)NSString * qualityStr;

@property(nonatomic,strong)UIImage * imageddddd;

@property(nonatomic,strong)NSMutableArray* dataArray;
@property(nonatomic,strong)NSMutableArray* detailedInfoArray;

@property(nonatomic,strong)NSMutableArray * videoArray;

@end

@implementation EUExImage


#pragma mark - EUExBase Method
- (instancetype)initWithBrwView:(EBrowserView *)eInBrwView{
    
    self=[super initWithBrwView:eInBrwView];
    
    if(self){
        if([EUtility isIpad] && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
            
            self.usingPop=YES;
            
        }else{
            
            self.usingPop=NO;
            
        }
        
       
        self.initialStatusBarStyle=[UIApplication sharedApplication].statusBarStyle;
        UexImageMySingleton * myleton = [UexImageMySingleton shareMySingLeton];
        myleton.slectImage = self;
        NSLog(@"+++++%@",self.description);
        _usePicturePng = NO;
    }
    self.enableIpadPop=YES;
    return self;
}

#pragma mark - 照片权限判断
- (BOOL)judgePic
{
    self.isJudgePic = NO;
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    switch (authStatus) {
        case PHAuthorizationStatusNotDetermined://没有询问是否开启照片
        {
//            __weak EUExImage *weakSelf = self;
//            //第一次询问用户是否进行授权
//            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//                // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
//                if (status == PHAuthorizationStatusAuthorized) {
//                    // Photo enabled code
//                    weakSelf.isJudgePic = YES;
//                }
//                else {
//                    // Photo disabled code
//                    weakSelf.isJudgePic = NO;
//                }
//            }];
            self.isJudgePic = YES;
        }
            break;
        case PHAuthorizationStatusRestricted:
            //未授权，家长限制
            self.isJudgePic = NO;
            break;
        case PHAuthorizationStatusDenied:
            //用户未授权
            self.isJudgePic = NO;
            break;
        case PHAuthorizationStatusAuthorized:
            //用户授权
            self.isJudgePic = YES;
            break;
        default:
            break;
    }
    
    return self.isJudgePic;
}

#pragma mark -compressImage(图片压缩)；

-(void)compressImage:(NSMutableArray*)array{
    
    NSString * compressStr = [array objectAtIndex:0];
    
    NSDictionary * compressDict = [compressStr JSONValue];
    
    NSString * imagePath = [self absPath:[compressDict objectForKey:@"srcPath"]];
    
    UIImage * image = [UIImage imageWithContentsOfFile:imagePath];
    
    //图像压缩
    UIImage *images = [self scaleFromImage:image];
    
    NSInteger imageLength = [[compressDict objectForKey:@"desLength"] intValue];
    
    // 原始数据
    NSData *imgData = UIImageJPEGRepresentation(images, 1.0);
    // 原始图片
    
    NSLog(@"++imgData++++++++%lu",imgData.length/1024);
    UIImage *result = [UIImage imageWithData:imgData];
    
    if  (imgData.length > imageLength) {
        
        imgData = UIImageJPEGRepresentation(result,0.5);
        
        CGFloat dataSize = imgData.length/1024;
        
        NSLog(@"++++++++++%f",dataSize);
        
        result = [UIImage imageWithData:imgData];
        
    }
    
    if(imgData){
        
        NSFileManager *fmanager = [NSFileManager defaultManager];
        
        NSString *uexImageSaveDir=[self getSaveDirPath];
        
        if (![fmanager fileExistsAtPath:uexImageSaveDir]) {
            
            [fmanager createDirectoryAtPath:uexImageSaveDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *timeStr = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSinceReferenceDate]];
        
        NSString *imgName = [NSString stringWithFormat:@"%@.jpg",[timeStr substringFromIndex:([timeStr length]-6)]];
        NSString *imgTmpPath = [uexImageSaveDir stringByAppendingPathComponent:imgName];
        if ([fmanager fileExistsAtPath:imgTmpPath]) {
            
            [fmanager removeItemAtPath:imgTmpPath error:nil];
        }
        
        [imgData writeToFile:imgTmpPath atomically:YES];
        
        NSMutableDictionary * dicct = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"OK",@"status",imgTmpPath,@"filePath", nil];
        NSString * compressImageStr = [dicct JSONFragment];
        
        NSString *jsString = [NSString stringWithFormat:@"uexImage.cbCompressImage('%@');",compressImageStr];
        
        [self.meBrwView stringByEvaluatingJavaScriptFromString:jsString];
    }
    
}

// 图像压缩
//==========================
- (UIImage *)scaleFromImage:(UIImage *)image
{
    if (!image)
    {
        return nil;
    }
    
    NSData *data =UIImagePNGRepresentation(image);
    CGFloat dataSize = data.length/1024;
    CGFloat width  = image.size.width;
    CGFloat height = image.size.height;
    CGSize size;
    
    if (dataSize<=30)//小于50k
    {
        return image;
    }
    else if (dataSize<=100)//小于100k
    {
        size = CGSizeMake(width/2.f, height/2.f);
    }
    else if (dataSize<=200)//小于200k
    {
        size = CGSizeMake(width/3.f, height/3.f);
    }
    else if (dataSize<=500)//小于500k
    {
        size = CGSizeMake(width/3.f, height/3.f);
    }
    else if (dataSize<=1000)//小于1M
    {
        size = CGSizeMake(width/3.f, height/3.f);
    }
    else if (dataSize<=2000)//小于2M
    {
        size = CGSizeMake(width/3.f, height/3.f);
    }
    else//大于2M
    {
        size = CGSizeMake(width/20.f, height/20.f);
    }
    NSLog(@"%f,%f",size.width,size.height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!newImage)
    {
        return image;
    }
    return newImage;
}


#pragma mark - APIs

- (void)openPicker:(NSMutableArray *)inArguments{
    
    //照片权限检测
    BOOL isPicOK = [self judgePic];
    if (!isPicOK) {
        NSDictionary *dicResult = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"errCode",@"获取照片失败，请在 设置-隐私-照片 中开启权限",@"info", nil];
        NSString *dataStr = [dicResult JSONFragment];
        NSString *jsStr = [NSString stringWithFormat:@"if(uexImage.onPermissionDenied){uexImage.onPermissionDenied(%@)}",dataStr];
        //回调给当前网页
        [EUtility brwView:self.meBrwView evaluateScript:jsStr];
        return;
    }
    
    if(!self.picker){
        
        self.picker=[[uexImagePicker alloc]initWithEUExImage:self];
    }
    
    [self.picker clean];
    
    if([inArguments count] >0){
        
        id info = [inArguments[0] JSONValue];
        
        if([info isKindOfClass:[NSDictionary class]]){
            
//            if ([[NSString stringWithFormat:@"%@",[info objectForKey:@"style"]]isEqualToString:@"1"]&& [[info allKeys]containsObject:@"style"]) {
//                
//                UexImageMySingleton * ImageLeton = [UexImageMySingleton shareMySingLeton];
//                
//                NSString *  jsonStr = [inArguments objectAtIndex:0];
//                
//                NSDictionary * pickerDcit = [jsonStr JSONValue];
//                
//                NSString * mincountStr= [NSString stringWithFormat:@"%@",[pickerDcit objectForKey:@"min"]];
//                
//                _qualityStr = [NSString stringWithFormat:@"%@",[pickerDcit objectForKey:@"quality"]];
//                
//                ImageLeton.minCount = mincountStr.integerValue;
//                
//                [self pushImagePickerController:pickerDcit];
//                
//                
//            } else {
            
                if([info objectForKey:@"min"]){
                    
                    self.picker.min=[[info objectForKey:@"min"] integerValue];
                }
                if([info objectForKey:@"max"]){
                    
                    self.picker.max=[[info objectForKey:@"max"] integerValue];
                }
                if([info objectForKey:@"quality"]){
                    
                    self.picker.quality=[[info objectForKey:@"quality"] floatValue];
                }
                if([info objectForKey:@"usePng"]){
                    
                    self.picker.usePng=[[info objectForKey:@"usePng"] boolValue];
                    
                }
                if([info objectForKey:@"title"]){
                    
                    self.picker.title=[info objectForKey:@"title"];
                }
                if([info objectForKey:@"detailedInfo"]){
                    
                    self.picker.detailedInfo=[[info objectForKey:@"detailedInfo"] boolValue];
                }
                
                [self.picker open];
//            }
            
        }
    }
    
    
    
}

/**
#pragma mark-----type 为 1 的 delegate方法；

- (void)pushImagePickerController: (NSDictionary*)dict {
    
    _selectedAssets = [NSMutableArray arrayWithCapacity:3];
    
    if ([NSString stringWithFormat:@"%@",[dict objectForKey:@"min"]].integerValue <= 0) {
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:[NSString stringWithFormat:@"%@",[dict objectForKey:@"max"]].integerValue columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    
    
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = YES;
    
    if ([NSString stringWithFormat:@"%@",[dict objectForKey:@"max"]].integerValue > 1) {
        // 1.设置目前已经选中的图片数组
        imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    }
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    [EUtility brwView:meBrwView presentModalViewController:imagePickerVc animated:YES];
    //    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    NSLog(@"cancel");
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    //[_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
    
    // 1.打印图片名字
    [self printAssetsName:assets];
}

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    
    NSString * imagePath =[self saveImage:coverImage quality:[_qualityStr floatValue] usePng:NO];
    
    self.videoArray = [NSMutableArray arrayWithCapacity:10];
    NSMutableDictionary *dicttt=[NSMutableDictionary dictionary];
    [self.videoArray addObject:imagePath];
    
    [dicttt setValue:self.videoArray forKey:cUexImageCallbackDataKey];
    [dicttt setObject:@(NO) forKey:cUexImageCallbackIsCancelledKey];
    NSLog(@"%@",dicttt);
    
    NSLog(@"++字典++++++++%@",dicttt);
    
    NSString * strings = [dicttt JSONFragment];
    
    NSString const * pluginName=@"uexImage";
    
    NSString const * name=@"onPickerClosed";
    
    NSString *jsStr = [NSString stringWithFormat:@"if(%@.%@ != null){%@.%@('%@');}",pluginName,name,pluginName,name,strings];
    
    [EUtility brwView:self.meBrwView evaluateScript:jsStr];
    
      
//以下是选择视频的路径；

//    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
//    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
//    NSLog(@"%@",_selectedAssets);
//    // open this code to send video / 打开这段代码发送视频
//     [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
//     NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
//         
//         
//         
//         NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
//         PHAssetResource *resource;
//         
//         for (PHAssetResource *assetRes in assetResources) {
//             if (assetRes.type == PHAssetResourceTypePairedVideo ||
//                 assetRes.type == PHAssetResourceTypeVideo) {
//                 resource = assetRes;
//             }
//         }
//         NSString *fileName = @"tempAssetVideo.mov";
//         if (resource.originalFilename) {
//             fileName = resource.originalFilename;
//         }
//         
//        
////         if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
////             
//             PHVideoRequestOptions * options = [[PHVideoRequestOptions alloc] init];
//         
//             options.version = PHImageRequestOptionsVersionCurrent;
//         
//             options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//             
//             NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
//         
//             [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
//         
//             [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
//                                                                         toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE]
//                                                                        options:nil
//                                                              completionHandler:^(NSError * _Nullable error) {
//                                                                  
//                                                                  if (error) {
//                                                                      
////                                                                      result(nil, nil);
//                                                                      
//                                                                  } else {
//                                                                      
//                                                                      NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:PATH_MOVIE_FILE]];
////                                                                      result(data, fileName);
////                                                                      NSLog(@"+++++++++++%@",PATH_MOVIE_FILE);
//                                                                      
//                                                                      [data writeToFile:outputPath atomically:YES];
//                                                                  }
//                                                                  [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE  error:nil];
//                                                              }];
//         } else {
//             result(nil, nil);
//         }
////
         
         
    // Export completed, send video here, send by outputPath or NSData
    // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    
//     }];
  
}

#pragma mark - Private

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    
    //    for(ALAsset * asset in assets){
    //
    //        ALAssetRepresentation *representation = [asset defaultRepresentation];
    //
    //
    //    }
    
    BOOL original = YES;
    
    self.dataArray = [NSMutableArray arrayWithCapacity:10];
    self.detailedInfoArray = [NSMutableArray arrayWithCapacity:10];
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:3];
    
    NSString *fileName;
    for (id asset in assets) {
        
        if ([asset isKindOfClass:[PHAsset class]]) {
            
            PHAsset *phAsset = (PHAsset *)asset;
            
            fileName = [phAsset valueForKey:@"filename"];
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            // 同步获得图片, 只会返回1张图片
            options.synchronous = YES;
            
            CGSize size = original ? CGSizeMake(phAsset.pixelWidth, phAsset.pixelHeight) : CGSizeZero;
            
            [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                _imageddddd = result;
                
            }];
            
            NSString * imagePath =[self saveImage:_imageddddd quality:[_qualityStr floatValue] usePng:NO];
            
            if(imagePath){
                
                [self.dataArray addObject:imagePath];
                
                if(self.detailedInfoArray){
                    
                    NSMutableDictionary *info=[NSMutableDictionary dictionary];
                    
                    [info setValue:imagePath forKey:@"localPath"];
                    
                    [info setValue:[NSString stringWithFormat:@"%@",phAsset.creationDate] forKey:@"timestamp"];
                    
                    CLLocation *location= phAsset.location;
                   
                    if(location){
                        
                        NSLog(@"%f",location.coordinate.latitude);
                        NSLog(@"%f",location.coordinate.longitude);
                        
                        [info setValue:@(location.coordinate.latitude) forKey:@"latitude"];
                        [info setValue:@(location.coordinate.longitude) forKey:@"longitude"];
                        [info setValue:@(location.altitude) forKey:@"altitude"];
                    }
                    
                    [self.detailedInfoArray addObject:info];
                    
                   
                }
                
                
            }

            
            
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            
            ALAsset *alAsset = (ALAsset *)asset;
            
            fileName = alAsset.defaultRepresentation.filename;
            
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            
            UIImage * assetImage =[UIImage imageWithCGImage:[representation fullResolutionImage] scale:representation.scale orientation:(UIImageOrientation)representation.orientation];
            
            NSString * imagePath =[self saveImage:assetImage quality:[_qualityStr floatValue] usePng:NO];
            
            NSLog(@"%@",imagePath);
            
            if(imagePath){
                
                [self.dataArray addObject:imagePath];
                
                if(self.detailedInfoArray){
                    
                    NSMutableDictionary *info=[NSMutableDictionary dictionary];
                    [info setValue:imagePath forKey:@"localPath"];
                    [info setValue:@((int)[[asset valueForProperty:ALAssetPropertyDate] timeIntervalSince1970]) forKey:@"timestamp"];
                    CLLocation *location=[asset valueForProperty:ALAssetPropertyLocation];
                   
                    
                    if(location){
                        
                        [info setValue:@(location.coordinate.latitude) forKey:@"latitude"];
                        [info setValue:@(location.coordinate.longitude) forKey:@"longitude"];
                        [info setValue:@(location.altitude) forKey:@"altitude"];
                    }
                    
                    [self.detailedInfoArray addObject:info];
                }
                
                
            }
            
            
        }
        
    }
    
    [dict setValue:self.dataArray forKey:cUexImageCallbackDataKey];
    [dict setObject:@(NO) forKey:cUexImageCallbackIsCancelledKey];
    NSLog(@"%@",self.dataArray);
    NSLog(@"%@",dict);
    
    if(self.detailedInfoArray){
        
        [dict setValue:self.detailedInfoArray forKey:@"detailedImageInfo"];

    }
    
    NSLog(@"++数组++++++++%@",self.detailedInfoArray);
    NSLog(@"++字典++++++++%@",dict);
    
    NSString * strings = [dict JSONFragment];
    
    NSString const * pluginName=@"uexImage";
    
    NSString const * name=@"onPickerClosed";
    
    NSString *jsStr = [NSString stringWithFormat:@"if(%@.%@ != null){%@.%@('%@');}",pluginName,name,pluginName,name,strings];
    
    [EUtility brwView:self.meBrwView evaluateScript:jsStr];

    
}


*/

- (void)openCropper:(NSMutableArray *)inArguments{
    
    if(!self.cropper){
        
        self.cropper=[[uexImageCropper alloc]initWithEUExImage:self];
    }
    
    [self.cropper clean];
    
    if([inArguments count] >0){
        id info = [inArguments[0] JSONValue];
        if([info isKindOfClass:[NSDictionary class]]){
            
            if([info objectForKey:@"quality"]){
                
                self.cropper.quality=[[info objectForKey:@"quality"] floatValue];
                
            }
            if([info objectForKey:@"uesPng"]){
                
                self.cropper.usePng=[[info objectForKey:@"usePng"] floatValue];
                
            }
            if([info objectForKey:@"mode"]){
                
                switch ([[info objectForKey:@"mode"] integerValue]) {
                        
                    case 1:
                        self.cropper.mode=RSKImageCropModeSquare;
                        break;
                    case 2:
                        self.cropper.mode=RSKImageCropModeCircle;
                        break;
                        
                    default:
                        break;
                        
                }
                
            }
            
            if([info objectForKey:@"src"]){
                
                UIImage *imageToBeCropped = [UIImage imageWithContentsOfFile:[self absPath:[info objectForKey:@"src"]]];
                self.cropper.imageToBeCropped=imageToBeCropped;
            }
        }
    }
    
    [self.cropper open];
    
}

- (void)openBrowser:(NSMutableArray *)inArguments{
    
    if([inArguments count] < 1){
        
        return;
        
    }
    
    id info = [inArguments[0] JSONValue];
    
    if ([[NSString stringWithFormat:@"%@",[info objectForKey:@"style"]]isEqualToString:@"0"])
    {
        if(!info || ![info isKindOfClass:[NSDictionary class]]){
            return;
        }
        
        if(!self.browser){
            
            self.browser=[[uexImageBrowser alloc]initWithEUExImage:self];
        }
        
        [self.browser clean];
        [self.browser setDataDict:info];
        [self.browser open];
        
    } else {
        
        [self imageBrowser:inArguments];
        
    }
    
}


- (void)saveToPhotoAlbum:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]||![info objectForKey:@"localPath"]){
        return;
    }
    
    //照片权限检测
    BOOL isPicOK = [self judgePic];
    if (!isPicOK) {
        NSDictionary *dicResult = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"errCode",@"获取照片失败，请在 设置-隐私-照片 中开启权限",@"info", nil];
        NSString *dataStr = [dicResult JSONFragment];
        NSString *jsStr = [NSString stringWithFormat:@"if(uexImage.onPermissionDenied){uexImage.onPermissionDenied(%@)}",dataStr];
        //回调给当前网页
        [EUtility brwView:self.meBrwView evaluateScript:jsStr];
        return;
    }
    
    UIImage *image=[UIImage imageWithContentsOfFile:[self absPath:[info objectForKey:@"localPath"]]];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge_retained void * _Nullable)([info objectForKey:@"extraInfo"]));
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    
    id extraInfo =CFBridgingRelease(contextInfo);
    
    if([extraInfo isKindOfClass:[NSString class]]){
        [dict setValue:extraInfo forKey:@"extraInfo"];
    }
    
    if(error){
        [dict setValue:@(NO) forKey:cUexImageCallbackIsSuccessKey];
        [dict setValue:[error localizedDescription] forKey:@"errorStr"];
    }else{
        [dict setValue:@(YES) forKey:cUexImageCallbackIsSuccessKey];
    }
    [self callbackJsonWithName:@"cbSaveToPhotoAlbum" Object:dict];
}

- (void)clearOutputImages:(NSMutableArray *)inArguments{
    [[NSFileManager defaultManager] removeItemAtPath:[self getSaveDirPath] error:NULL];
}

- (void)setIpadPopEnable:(NSMutableArray *)inArguments{
    
    if([inArguments count] < 1){
        return;
    }
    
    self.enableIpadPop=[inArguments[0] boolValue];
}

- (void)imageBrowser:(NSMutableArray *)inArguments
{
    if (inArguments.count < 1) {
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]){
        
        return;
    }
    int index = [[info objectForKey:@"startIndex"] intValue];
    
    UexImageMySingleton * uexImageshare = [UexImageMySingleton shareMySingLeton];
    
    if ([[info allKeys] containsObject:@"gridBackgroundColor"])
    {
        NSString * gridBackGroundColorStr = [info objectForKey:@"gridBackgroundColor"];
        
        uexImageshare.gridBackgroundColorStr = gridBackGroundColorStr;
        
    } else {
        
        uexImageshare.gridBackgroundColorStr = @"#000000";
        
    }
    
    if ([[info allKeys] containsObject:@"gridTitle"])
    {
        NSString * gridTitleStr = [info objectForKey:@"gridTitle"];
        
        uexImageshare.gridBrowserTitleStr = gridTitleStr;
        
    } else {
        
        uexImageshare.gridBrowserTitleStr = UEXIMAGE_LOCALIZEDSTRING(@"ImageBrowse");
        
    }
    
    NSMutableArray * dataArray = [info objectForKey:@"data"];
    
    NSMutableArray * smallImagePathArray = [NSMutableArray arrayWithCapacity:3];
    
    NSMutableArray * bigImageURLArray    = [NSMutableArray arrayWithCapacity:3];
    
    NSMutableArray * imagePathArray = [NSMutableArray arrayWithCapacity:3];
    
    for (int i = 0; i < dataArray.count; i ++) {
        
        id  dic = dataArray[i];
        
        if([dic isKindOfClass:[NSString class]]){
            
            if ([dic hasPrefix:@"http"])
            {
                //长按回调使用数组；
                [bigImageURLArray addObject:dic];
                
                [imagePathArray addObject:dic];
                
            } else {
                
                //长按回调使用数组；
                [imagePathArray addObject:dic];
                
                NSString * bigImagepath = [self absPath:dic];
                
                [bigImageURLArray addObject:bigImagepath];
                
            }
            
            
        }else if ([dic isKindOfClass:[NSDictionary class]])
        {
            
            if([[dic allKeys] containsObject:@"thumb"])
            {
                if ([dic objectForKey:@"thumb"]) {
                    
                    NSString *smallImage = [NSString stringWithFormat:@"%@",[dic objectForKey:@"thumb"]];
                    
                    NSString * smallImagePath = [self absPath:smallImage];
                    
                    [smallImagePathArray addObject:smallImagePath];
                    
                } else {
                    
                    [smallImagePathArray addObject:@"123"];
                }
                
            }
            
            if ([dic objectForKey:@"src"]) {
                
                NSString *bigImage = [NSString stringWithFormat:@"%@",[dic objectForKey:@"src"]];
                
                if ([bigImage hasPrefix:@"http"])
                {
                    //长按回调使用数组；
                    [imagePathArray addObject:bigImage];
                    
                    [bigImageURLArray addObject:bigImage];
                    
                } else {
                    
                    //长按回调使用数组；
                    [imagePathArray addObject:bigImage];
                    
                    NSString * bigImagepath = [self absPath:bigImage];
                    
                    [bigImageURLArray addObject:bigImagepath];
                    
                }
                
            }
            
            
        }
        
        
    }
    
    UexImageMySingleton * EUExsingleton = [UexImageMySingleton shareMySingLeton];
    
    EUExsingleton.longImagePath = imagePathArray;
    
    EUExsingleton.placeholderArray = smallImagePathArray;
    
    if ([[info allKeys] containsObject:@"viewFramePicPreview"])
    {
        NSDictionary * PreviewDict = [info objectForKey:@"viewFramePicPreview"];
        
        CGRect frame = CGRectMake([[PreviewDict objectForKey:@"x"] intValue], [[PreviewDict objectForKey:@"y"] intValue], [[PreviewDict objectForKey:@"w"] intValue], [[PreviewDict objectForKey:@"h"] intValue]);
        UexImageMySingleton * preImagesLeton = [UexImageMySingleton shareMySingLeton];
        preImagesLeton.preframe = frame;
        
    } else {
        
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height);
        UexImageMySingleton * preImagesLeton = [UexImageMySingleton shareMySingLeton];
        preImagesLeton.preframe = frame;
        
    }
    
    if ([[info allKeys]containsObject:@"viewFramePicGrid"]) {
        
        NSDictionary * PicGridDict = [info objectForKey:@"viewFramePicGrid"];
        CGRect cgframe  = CGRectMake([[PicGridDict objectForKey:@"x"] intValue], [[PicGridDict objectForKey:@"y"] intValue], [[PicGridDict objectForKey:@"w"] intValue], [[PicGridDict objectForKey:@"h"] intValue]);
        UexImageMySingleton * preImagesLeton = [UexImageMySingleton shareMySingLeton];
        preImagesLeton.PicGrid = cgframe;
        
    } else {
        
        CGRect cgframe = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height);
        UexImageMySingleton * preImagesLeton = [UexImageMySingleton shareMySingLeton];
        preImagesLeton.PicGrid = cgframe;
        
    }
    
    UIImageView * imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, 375, 667)];
    [HUPhotoBrowser showFromImageView:imageview withImages:bigImageURLArray atIndex:index];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //    NSMutableArray *broweitemArray = [NSMutableArray arrayWithCapacity:3];
    //    for (int i = 0; i < smallImagePathArray.count; i ++) {
    //        MSSBrowseModel *browseItem = [[MSSBrowseModel alloc]init];
    //        browseItem.bigImageUrl = bigImageURLArray[i];
    //        browseItem.smallImagePath = smallImagePathArray[i];
    //        [broweitemArray addObject:browseItem];
    //    }
    //
    //    MSSBrowseNetworkViewController *bvc = [[MSSBrowseNetworkViewController alloc]initWithBrowseItemArray:broweitemArray currentIndex:index euexObjc:self Array:bigImageURLArray anType:AnimationTypeStr];
    //    bvc.isEqualRatio = NO;
    //    [EUtility brwView:self.meBrwView presentModalViewController:bvc animated:NO];
    
}

#pragma mark - Tools
//restore initial StatusBar

- (void)restoreStatusBar{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setStatusBarStyle:self.initialStatusBarStyle];
        NSNumber *statusBarHidden = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIStatusBarHidden"];
        if ([statusBarHidden boolValue] == YES) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        }
        
    });
    
}

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)flag{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.usingPop && self.enableIpadPop){
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:vc];
            self.iPadPop = popover;
            [EUtility brwView:meBrwView presentPopover:self.iPadPop FromRect:CGRectMake(0, 0, 300, 300) permittedArrowDirections:UIPopoverArrowDirectionAny animated:flag];
            
        }else{
            [EUtility brwView:meBrwView presentModalViewController:vc animated:flag];
        }
    });
    
}

- (void)dismissViewController:(UIViewController *)vc
                     Animated:(BOOL)flag
                   completion:(void (^)(void))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.usingPop && self.enableIpadPop){
            [self.iPadPop dismissPopoverAnimated:flag];
            if(completion){
                completion();
            }
            self.iPadPop=nil;
        }else{
            if([vc respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
                [vc dismissViewControllerAnimated:flag completion:completion];
            }
        }
        [self restoreStatusBar];
    });
    
}

// js call back
- (void)callbackJsonWithName:(NSString *)name Object:(id)obj{
    
    //    NSMutableArray * PickerImageArray = [[NSMutableArray alloc]initWithCapacity:3];
    //    NSMutableDictionary * PickerDict = [NSMutableDictionary dictionaryWithCapacity:3];
    NSString *result=nil;
    
    if([obj isKindOfClass:[NSString class]]){
        
        result=(NSString *)obj;
        
    } else {
        
        //        NSMutableDictionary * dictdd = (NSMutableDictionary*) obj;
        //
        //        if([[dictdd allKeys] containsObject:@"data"]) {
        //            NSDictionary * dict = (NSDictionary*)obj;
        //
        //            NSArray * imageArray = [dict objectForKey:@"data"];
        //
        //            for (int i = 0; i<imageArray.count; i++)
        //            {
        //                UIImage * pickerImage = [UIImage imageWithContentsOfFile:[imageArray objectAtIndex:i]];
        //
        //                CGSize Pickerside = pickerImage.size;
        //
        //                PickerDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",Pickerside.width],@"width", [NSString stringWithFormat:@"%f",Pickerside.height],@"height", nil];
        //
        //                [PickerImageArray addObject:PickerDict];
        //            }
        //
        //            [dictdd setObject:PickerImageArray forKey:@"imageSize"];
        //
        //            result = [dictdd JSONFragment];
        //
        //             NSLog(@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++%@",result);
        //
        //        }else{
        
        result = [obj JSONFragment];
        
        //        }
        
    }
    
    NSString const * pluginName=@"uexImage";
    
    NSString *jsStr = [NSString stringWithFormat:@"if(%@.%@ != null){%@.%@('%@');}",pluginName,name,pluginName,name,result];
    
    [EUtility brwView:self.meBrwView evaluateScript:jsStr];
    
}

- (NSString *)getSaveDirPath{
    
    NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/apps"];
    
    NSString *wgtTempPath=[tempPath stringByAppendingPathComponent:[EUtility brwViewWidgetId:meBrwView]];
    
    return [wgtTempPath stringByAppendingPathComponent:@"uexImage"];
}

// save to Disk
- (NSString *)saveImage:(UIImage *)image quality:(CGFloat)quality usePng:(BOOL)usePng{
    
    NSData *imageData;
    NSString *imageSuffix;
    
    if (image.imageOrientation==UIImageOrientationUp)
    {
        
    } else if(image.imageOrientation==UIImageOrientationRight) {
        
        image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationRight];
        
        image = [self fixOrientation:image];
    }
    
    
    if(usePng){
        
        imageData=UIImagePNGRepresentation(image);
        imageSuffix=@"png";
        
    } else {
        
        imageData=UIImageJPEGRepresentation(image, quality);
        imageSuffix=@"jpg";
        
    }
    
    if(!imageData) return nil;
    
    NSFileManager *fmanager = [NSFileManager defaultManager];
    
    NSString *uexImageSaveDir=[self getSaveDirPath];
    
    if (![fmanager fileExistsAtPath:uexImageSaveDir]) {
        
        [fmanager createDirectoryAtPath:uexImageSaveDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *timeStr = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSinceReferenceDate]];
    
    NSString *imgName = [NSString stringWithFormat:@"%@.%@",[timeStr substringFromIndex:([timeStr length]-6)],imageSuffix];
    
    NSString *imgTmpPath = [uexImageSaveDir stringByAppendingPathComponent:imgName];
    
    if ([fmanager fileExistsAtPath:imgTmpPath]) {
        
        [fmanager removeItemAtPath:imgTmpPath error:nil];
    }
    
    if([imageData writeToFile:imgTmpPath atomically:YES]){
        
        
        return imgTmpPath;
        
    } else {
        
        return nil;
    }
    
}

#pragma mark ---图片方向强转；
- (UIImage *)fixOrientation:(UIImage *)oImage {
    
    // No-op if the orientation is already correct
    if (oImage.imageOrientation == UIImageOrientationUp) return oImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (oImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, oImage.size.width, oImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, oImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, oImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:break;
    }
    
    switch (oImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, oImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, oImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, oImage.size.width, oImage.size.height,
                                             CGImageGetBitsPerComponent(oImage.CGImage), 0,
                                             CGImageGetColorSpace(oImage.CGImage),
                                             CGImageGetBitmapInfo(oImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (oImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,oImage.size.height,oImage.size.width), oImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,oImage.size.width,oImage.size.height), oImage.CGImage);
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
