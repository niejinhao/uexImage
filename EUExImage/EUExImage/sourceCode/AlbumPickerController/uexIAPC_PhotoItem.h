//
//  uexIAPC_PhotoItem.h
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


typedef void ^(uexIAPC_PhotoItemGetOriginImageBlock) (UIImage *);

@interface uexIAPC_PhotoItem : NSObject
@property (nonatomic,strong)NSURL *assetURL;
@property (nonatomic,strong)UIImage *thumbImage;


-(instancetype)initWithPhoto:(ALAsset *)photoAsset;
-(void)getOriginImageWithBlock:(uexIAPC_PhotoItemGetOriginImageBlock)completion;

@end
