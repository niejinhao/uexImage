//
//  uexImageBrowser.m
//  EUExImage
//
//  Created by CeriNo on 15/10/8.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImageBrowser.h"
#import "MWPhotoBrowser.h"

@interface uexImageBrowser()<MWPhotoBrowserDelegate>
@property (nonatomic,strong)MWPhotoBrowser * photoBrowser;
@property (nonatomic,strong)UINavigationController *navBrowser;
@property (nonatomic,strong)NSMutableArray<MWPhoto *> * photos;
@property (nonatomic,strong)NSMutableDictionary<NSString *,MWPhoto *> * thumbs;

@end

@implementation uexImageBrowser



-(instancetype)initWithEUExImage:(EUExImage *)EUExImage{
    self=[super init];
    if(self) {
        self.EUExImage=EUExImage;
        self.photos=[NSMutableArray array];
        self.thumbs=[NSMutableDictionary dictionary];
    }
    return self;
}




-(void)open{
    if(!self.dataDict){
        return;
    }
    UEXIMAGE_ASYNC_DO_IN_GLOBAL_QUEUE(^{
        if([self setupBrowser]){
            [self.EUExImage presentViewController:self.navBrowser animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                if([self.dataDict objectForKey:@"startIndex"]){
                    [self.photoBrowser setCurrentPhotoIndex:[[self.dataDict objectForKey:@"startIndex"] integerValue]];
                }
            });


        }
    });
}


-(void)clean{
    self.dataDict=nil;
    [self.photos removeAllObjects];
    [self.thumbs removeAllObjects];
}






-(BOOL)setupBrowser{
    MWPhotoBrowser * browser =[[MWPhotoBrowser alloc]initWithDelegate:self];
    browser.displayActionButton =NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid =YES;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = NO;
    //browser.autoPlayOnAppear = NO;
    [browser setCurrentPhotoIndex:0];
    
    if([self.dataDict objectForKey:@"data"]&&[[self.dataDict objectForKey:@"data"]isKindOfClass:[NSArray class]]){
        [self parsePhoto:[self.dataDict objectForKey:@"data"]];
    }
    if([self.dataDict objectForKey:@"displayActionButton"]){
        browser.displayActionButton=[[self.dataDict objectForKey:@"displayActionButton"] boolValue];
    }
    if([self.dataDict objectForKey:@"displayNavArrows"]){
        browser.displayNavArrows=[[self.dataDict objectForKey:@"displayNavArrows"] boolValue];
    }
    if([self.dataDict objectForKey:@"enableGrid"]){
        browser.enableGrid=[[self.dataDict objectForKey:@"enableGrid"] boolValue];
    }
    if([self.dataDict objectForKey:@"startOnGrid"]){
        browser.startOnGrid=[[self.dataDict objectForKey:@"startOnGrid"] boolValue];
    }
    if([self.dataDict objectForKey:@"isShowDetail"] && [[self.dataDict objectForKey:@"isShowDetail"] isEqual:@(YES)]){
        browser.isShowDetail = YES;
    }

    self.photoBrowser=browser;
    self.navBrowser=[[UINavigationController alloc]initWithRootViewController:self.photoBrowser];
    
    return YES;
}



-(void)parsePhoto:(NSArray *)photoArray{
    for(id photoInfo in photoArray){
        if([photoInfo isKindOfClass:[NSString class]]){
            MWPhoto *photo =[self photoFromString:photoInfo];
            if(photo){
                [self.photos addObject:photo];
            }
        }else if([photoInfo isKindOfClass:[NSDictionary class]]){
            MWPhoto *photo =[self photoFromString:photoInfo[@"src"]];
            if(photo){
                if([photoInfo objectForKey:@"thumb"]){
                    MWPhoto *thumb =[self photoFromString:[photoInfo objectForKey:@"thumb"]];
                    [self.thumbs setValue:thumb forKey:[@(self.photos.count) stringValue]];
                    
                }
                if([photoInfo objectForKey:@"desc"]&&[[photoInfo objectForKey:@"desc"] isKindOfClass:[NSString class]]){
                    photo.caption=[photoInfo objectForKey:@"desc"];
                }
                if([photoInfo objectForKey:@"title"]&&[[photoInfo objectForKey:@"title"] isKindOfClass:[NSString class]]){
                    photo.title=[photoInfo objectForKey:@"title"];
                }
                if([photoInfo objectForKey:@"detailInfo"]&&[[photoInfo objectForKey:@"detailInfo"] isKindOfClass:[NSDictionary class]]){
                    photo.exif=[photoInfo objectForKey:@"detailInfo"];
                }
                [self.photos addObject:photo];
                
            }
        }
    }
    
    
}

-(MWPhoto *)photoFromString:(NSString *)photoStr{
    if(!photoStr||[photoStr length]==0){
        return nil;
    }
    NSString *clearPath=[photoStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    MWPhoto *photo=nil;
    if([[clearPath lowercaseString] hasPrefix:@"http"]){
        photo =[[MWPhoto alloc]initWithURL:[NSURL URLWithString:clearPath]];
        if(!photo){
            return nil;
        }

    }else{
        UIImage *image=[UIImage imageWithContentsOfFile:[self.EUExImage absPath:clearPath]];
        if(image){
           photo =[[MWPhoto alloc]initWithImage:image];
        }
        
    }
    return photo;
}


#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return self.photos.count;
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    return (MWPhoto *)self.photos[index];

}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index{
    if([self.thumbs objectForKey:[@(index) stringValue]]){
        return (MWPhoto *)self.thumbs[[@(index) stringValue]];
    }
    return (MWPhoto *)self.photos[index];
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser{
    [self.EUExImage dismissViewController:self.navBrowser Animated:YES completion:^{
        [self clean];
        [self.EUExImage callbackJsonWithName:@"onBrowserClosed" Object:nil];
    }];



}

/* 
 @optional
 
 - (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
 - (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
 - (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
 - (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
 - (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
 - (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
 - (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
 - (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser;
 */
@end
