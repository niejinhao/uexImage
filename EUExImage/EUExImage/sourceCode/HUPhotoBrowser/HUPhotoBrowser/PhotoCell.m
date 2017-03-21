//
//  PhotoCell.m
//  HUPhotoBrowser Demo
//
//  Created by mac on 16/2/25.
//  Copyright (c) 2016年 hujewelz. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createImageView];
        
    }
    return self;
}
-(void)createImageView
{
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/4, 100)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
}

@end
