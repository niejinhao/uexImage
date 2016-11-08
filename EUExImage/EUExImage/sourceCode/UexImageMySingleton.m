//
//  MySingleton.m
//  DEMO
//
//  Created by cc on 15/11/4.
//  Copyright © 2015年 hexc. All rights reserved.
//

#import "UexImageMySingleton.h"

@implementation UexImageMySingleton

@synthesize slectImage,indexDict,preframe,PicGrid,browerList,gridBackgroundColorStr,gridBrowserTitleStr,longImagePath,tapClick,scrollView,photoImageView,minCount;

+ (UexImageMySingleton *)shareMySingLeton
{
    static UexImageMySingleton *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        
        
    });
    return sharedAccountManagerInstance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        tapClick = NO;
    }
    
    return self;
    
}

@end
