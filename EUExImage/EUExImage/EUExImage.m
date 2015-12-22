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

NSString * const cUexImageCallbackIsCancelledKey = @"isCancelled";
NSString * const cUexImageCallbackDataKey      = @"data";
NSString * const cUexImageCallbackIsSuccessKey = @"isSuccess";
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
- (instancetype)initWithBrwView:(EBrowserView *)eInBrwView{
    self=[super initWithBrwView:eInBrwView];
    if(self){
        if(!320 == [UIScreen mainScreen].bounds.size.width || [EUtility isIpad]){
        self.usingPop=YES;
    }else{
        self.usingPop=NO;
    }
        self.initialStatusBarStyle=[UIApplication sharedApplication].statusBarStyle;

    }
    self.enableIpadPop=YES;
    return self;
}




#pragma mark - APIs


- (void)openPicker:(NSMutableArray *)inArguments{
    
    if(!self.picker){
        self.picker=[[uexImagePicker alloc]initWithEUExImage:self];
    }
    [self.picker clean];
    if([inArguments count] >0){
        id info = [inArguments[0] JSONValue];
        if([info isKindOfClass:[NSDictionary class]]){
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
        }
    }
    
    [self.picker open];
    
}



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
    if(!info || ![info isKindOfClass:[NSDictionary class]]){
        return;
    }
    if(!self.browser){
        self.browser=[[uexImageBrowser alloc]initWithEUExImage:self];
    }
    [self.browser clean];
    [self.browser setDataDict:info];
    [self.browser open];
}





- (void)saveToPhotoAlbum:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]||![info objectForKey:@"localPath"]){
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
        if(self.usingPop){
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
    NSString *result=nil;
    if([obj isKindOfClass:[NSString class]]){
        result=(NSString *)obj;
    }else{
        result=[obj JSONFragment];
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
    
    
    if(usePng){
        imageData=UIImagePNGRepresentation(image);
        imageSuffix=@"png";
    }else{
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
    }else{
        return nil;
    }
    
}



@end
