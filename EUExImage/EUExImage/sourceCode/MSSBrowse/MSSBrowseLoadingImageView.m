//
//  MSSBrowseLoadingImageView.m
//  MSSBrowse
//
//  Created by 于威 on 16/4/29.
//  Copyright © 2016年 于威. All rights reserved.
//

#import "MSSBrowseLoadingImageView.h"

@interface MSSBrowseLoadingImageView ()

@property (nonatomic,strong)CABasicAnimation *rotationAnimation;
@property (nonatomic,strong)UIActivityIndicatorView  *activity;
@end

@implementation MSSBrowseLoadingImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self createImageView];
    }
    return self;
}

- (void)createImageView
{
    _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self addSubview:_activity];
    
//    UIImage *image = [UIImage imageNamed:@"mss_browseLoading"];
//    self.image = image;
//    self.image = [UIImage imageNamed:@"mss_browseLoading"];
    _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    _rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    _rotationAnimation.duration = 0.6f;
    _rotationAnimation.repeatCount = FLT_MAX;
    
}

- (void)startAnimation
{
    self.hidden = NO;
//    [self.layer addAnimation:_rotationAnimation
//                      forKey:@"rotateAnimation"];
    [self.activity startAnimating];
}

- (void)stopAnimation
{
    self.hidden = YES;
//    [self.layer removeAnimationForKey:@"rotateAnimation"];
    [self.activity stopAnimating];
}


@end
