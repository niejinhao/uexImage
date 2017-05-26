//
//  uexImageBrowser.h
//  EUExImage
//
//  Created by CeriNo on 15/10/8.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EUExImage.h"



@interface uexImageBrowser : NSObject<EUExImageWidget>
@property (nonatomic,weak)EUExImage * EUExImage;
@property (nonatomic,strong)NSDictionary *dataDict;
@property (nonatomic,strong)ACJSFunctionRef *cb;

@end
