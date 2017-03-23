//
//  MySingleton.h
//  DEMO
//
//  Created by cc on 15/11/4.
//  Copyright © 2015年 hexc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EUExImage.h"
#import "HUPhotoBrowser.h"
#import "PhotoBrowerList.h"


@interface UexImageMySingleton : NSObject
@property(nonatomic,strong)EUExImage* slectImage;
@property(nonatomic,assign)NSDictionary * indexDict;
@property(nonatomic,assign)CGRect preframe;
@property(nonatomic,assign)CGRect PicGrid;
@property(nonatomic,strong)NSMutableArray * placeholderArray;
@property(nonatomic,retain)PhotoBrowerList * browerList;
@property(nonatomic,retain)HUPhotoBrowser * PhotoBrowse;

@property(nonatomic,strong)NSString *  gridBackgroundColorStr;
@property(nonatomic,strong)NSString * gridBrowserTitleStr;
@property(nonatomic,strong)NSMutableArray * longImagePath;

@property(nonatomic,assign)BOOL tapClick;

@property(nonatomic,strong)UIScrollView * scrollView ;

@property(nonatomic,strong)UIImageView * photoImageView;

@property(nonatomic,assign)NSInteger minCount;
@property (nonatomic,strong)ACJSFunctionRef *cb;

+(UexImageMySingleton*)shareMySingLeton;

@end
