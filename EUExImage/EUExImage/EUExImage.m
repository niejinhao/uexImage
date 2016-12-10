//
//  EUExImage.m
//  EUExImage
//
//  Created by Cerino on 15/9/23.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "EUExImage.h"

#import "uexImageWidgets.h"
#import <AssetsLibrary/AssetsLibrary.h>

NSString * const cUexImageCallbackIsCancelledKey    = @"isCancelled";
NSString * const cUexImageCallbackDataKey           = @"data";
NSString * const cUexImageCallbackIsSuccessKey      = @"isSuccess";
@interface EUExImage()

@property (nonatomic,assign)UIStatusBarStyle initialStatusBarStyle;
@property (nonatomic,strong)UIPopoverController *iPadPop;
@property (nonatomic,assign)BOOL usingPop;

@property (nonatomic,strong)uexImageCropper *cropper;
@property (nonatomic,strong)uexImagePicker *picker;
@property (nonatomic,strong)uexImageBrowser *browser;
@property (nonatomic,assign)BOOL enableIpadPop;
@end
@implementation EUExImage


#pragma mark - EUExBase Method



- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine
{
    self = [super initWithWebViewEngine:engine];
    if (self) {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
            _usingPop = YES;
        }else{
            _usingPop = NO;
        }
        _initialStatusBarStyle=[UIApplication sharedApplication].statusBarStyle;
        _enableIpadPop = YES;
    }
    return self;
}


#pragma mark - APIs


- (void)openPicker:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cb) = inArguments;
    
    
    if(!self.picker){
        self.picker = [[uexImagePicker alloc]initWithEUExImage:self];
    }
    [self.picker clean];
    self.picker.cb = cb;
    if(info){
        if([info objectForKey:@"min"]){
            self.picker.min = [[info objectForKey:@"min"] integerValue];
        }
        if([info objectForKey:@"max"]){
            self.picker.max = [[info objectForKey:@"max"] integerValue];
        }
        if([info objectForKey:@"quality"]){
            self.picker.quality = [[info objectForKey:@"quality"] floatValue];
        }
        if([info objectForKey:@"usePng"]){
            self.picker.usePng = [[info objectForKey:@"usePng"] boolValue];
        }
        if([info objectForKey:@"title"]){
            self.picker.title = [info objectForKey:@"title"];
        }
        if([info objectForKey:@"detailedInfo"]){
            self.picker.detailedInfo = [[info objectForKey:@"detailedInfo"] boolValue];
        }
    }
    [self.picker open];
    
}



- (void)openCropper:(NSMutableArray *)inArguments{
    if(!self.cropper){
        self.cropper = [[uexImageCropper alloc]initWithEUExImage:self];
    }
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cb) = inArguments;
    [self.cropper clean];
    if(info){
        if([info objectForKey:@"quality"]){
            self.cropper.quality = [[info objectForKey:@"quality"] floatValue];
        }
        if([info objectForKey:@"uesPng"]){
            self.cropper.usePng = [[info objectForKey:@"usePng"] floatValue];
        }
        if([info objectForKey:@"mode"]){
            self.cropper.shape = [[info objectForKey:@"mode"] integerValue];
        }
        if([info objectForKey:@"src"]){
            UIImage *imageToBeCropped = [UIImage imageWithContentsOfFile:[self absPath:[info objectForKey:@"src"]]];
            self.cropper.imageToBeCropped = imageToBeCropped;
        }
    }
    self.cropper.cb = cb;
    [self.cropper open];
}




- (void)openBrowser:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cb) = inArguments;
    if(!self.browser){
        self.browser=[[uexImageBrowser alloc]initWithEUExImage:self];
    }
    [self.browser clean];
    self.browser.cb = cb;
    [self.browser setDataDict:info];
    [self.browser open];
}





- (void)saveToPhotoAlbum:(NSMutableArray *)inArguments{

    ACArgsUnpack(NSDictionary *info,ACJSFunctionRef *cb) = inArguments;
    NSString *path = stringArg(info[@"localPath"]);
    NSString *extra = stringArg(info[@"extraInfo"]);
    UIImage *image = [UIImage imageWithContentsOfFile:[self absPath:path]];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:extra forKey:@"extraInfo"];
        UEX_ERROR err = kUexNoError;
        if(error){
            err = uexErrorMake(1,[error localizedDescription]);
            [dict setValue:@(NO) forKey:cUexImageCallbackIsSuccessKey];
            [dict setValue:[error localizedDescription] forKey:@"errorStr"];
        }else{
            [dict setValue:@(YES) forKey:cUexImageCallbackIsSuccessKey];
        }
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexImage.cbSaveToPhotoAlbum" arguments:ACArgsPack(dict.ac_JSONFragment)];
        [cb executeWithArguments:ACArgsPack(err,error.localizedDescription)];
    }];

}



- (UEX_BOOL)clearOutputImages:(NSMutableArray *)inArguments{
    BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:[self saveDirPath] error:NULL];
    return ret ? UEX_TRUE : UEX_FALSE;
}

- (void)setIpadPopEnable:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return;
    }
    self.enableIpadPop=[inArguments[0] boolValue];
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
            [popover presentPopoverFromRect:CGRectMake(0, 0, 300, 300) inView:self.webViewEngine.webView permittedArrowDirections:UIPopoverArrowDirectionAny animated:flag];
        }else{
            [[self.webViewEngine viewController]presentViewController:vc animated:flag completion:nil];

        }
    });
    
}

- (void)dismissViewController:(UIViewController *)vc
                    animated:(BOOL)flag
                  completion:(void (^)(void))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.usingPop && self.enableIpadPop){
            [self.iPadPop dismissPopoverAnimated:flag];
            if(completion){
                completion();
            }
            self.iPadPop=nil;
        }else{
            [vc dismissViewControllerAnimated:flag completion:completion];
        }
        [self restoreStatusBar];
    });
}




- (NSString *)saveDirPath{
    NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/apps"];
    NSString *wgtTempPath=[tempPath stringByAppendingPathComponent:[[self.webViewEngine widget] widgetId]];
    return [wgtTempPath stringByAppendingPathComponent:@"uexImage"];
}

// save to Disk
- (NSString *)saveImage:(UIImage *)image quality:(CGFloat)quality usePng:(BOOL)usePng{
    NSData *imageData;
    NSString *imageSuffix;

    if(usePng){
        imageData = UIImagePNGRepresentation(image);
        imageSuffix = @"png";
    }else{
        imageData = UIImageJPEGRepresentation(image, quality);
        imageSuffix = @"jpg";
    }
    
    if(!imageData){
       return nil;
    }
    
    NSFileManager *fmanager = [NSFileManager defaultManager];

    NSString *uexImageSaveDir = [self saveDirPath];
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
    }else{
        return nil;
    }
    
}



@end