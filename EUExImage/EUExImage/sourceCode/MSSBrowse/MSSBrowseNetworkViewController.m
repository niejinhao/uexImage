//
//  MSSBrowseNetworkViewController.m
//  MSSBrowse
//
//  Created by 于威 on 16/4/26.
//  Copyright © 2016年 于威. All rights reserved.
//

#import "MSSBrowseNetworkViewController.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "UIView+MSSLayout.h"
#import "UIImage+MSSScale.h"

@implementation MSSBrowseNetworkViewController

- (void)loadBrowseImageWithBrowseItem:(MSSBrowseModel *)browseItem Cell:(MSSBrowseCollectionViewCell *)cell bigImageRect:(CGRect)bigImageRect AnType:(NSString *)type
{
    // 停止加载
    [cell.loadingView stopAnimation];
    // 判断大图是否存在
    if([[SDImageCache sharedImageCache]diskImageExistsWithKey:browseItem.bigImageUrl])
    {
        // 显示大图
        [self showBigImage:cell.zoomScrollView.zoomImageView browseItem:browseItem rect:bigImageRect AnType:type];
    }
    // 如果大图不存在
    else
    {
        self.isFirstOpen = NO;
        // 加载大图
        [self loadBigImageWithBrowseItem:browseItem cell:cell rect:bigImageRect anType:type];
    }
}

- (void)showBigImage:(UIImageView *)imageView browseItem:(MSSBrowseModel *)browseItem rect:(CGRect)rect AnType:(NSString*)type
{
    // 取消当前请求防止复用问题
    [imageView sd_cancelCurrentImageLoad];
    // 如果存在直接显示图片
    imageView.image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:browseItem.bigImageUrl];
   
    // 第一次打开浏览页需要加载动画
    if(self.isFirstOpen)
    {
         CGRect bigRect = [self getBigImageRectIfIsEmptyRect:rect bigImage:imageView.image];
        if ([type isEqualToString:@"1"])
        {
            // 当大图frame为空时，需要大图加载完成后重新计算坐标
           
            self.isFirstOpen = NO;
            imageView.frame = [self getFrameInWindow:browseItem.smallImageView];
            
            imageView.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0);
            [UIView animateWithDuration:1 animations:^{
                
                imageView.frame = bigRect;
                
            } completion:^(BOOL finished) {
                
                
            }];
            
        }
        else if ([type isEqualToString:@"2"])//  翻页动画效果；
        {
            imageView.frame = [self getFrameInWindow:browseItem.smallImageView];
            
            imageView.frame = bigRect;
            [self animationWithView:imageView WithAnimationTransition:UIViewAnimationTransitionFlipFromLeft];
        }

    }
    else
    {
        
        // 当大图frame为空时，需要大图加载完成后重新计算坐标
        CGRect bigRect = [self getBigImageRectIfIsEmptyRect:rect bigImage:imageView.image];
        
        if ([type isEqualToString:@"1"]) {
            imageView.frame = [self getFrameInWindow:browseItem.smallImageView];
            
            imageView.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0);
            [UIView animateWithDuration:1 animations:^{
                
                imageView.frame = bigRect;
                
            } completion:^(BOOL finished) {
                
                
            }];

        }else if ([type isEqualToString:@"2"])//  翻页动画效果；
        {
            imageView.frame = [self getFrameInWindow:browseItem.smallImageView];

            imageView.frame = bigRect;
            
            [self animationWithView:imageView WithAnimationTransition:UIViewAnimationTransitionFlipFromLeft];
        }
        
    }
}

#pragma UIView实现动画
- (void) animationWithView : (UIView *)view WithAnimationTransition : (UIViewAnimationTransition) transition
{
    [UIView animateWithDuration:1 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationTransition:transition forView:view cache:YES];
    }];
}

// 加载大图
- (void)loadBigImageWithBrowseItem:(MSSBrowseModel *)browseItem cell:(MSSBrowseCollectionViewCell *)cell rect:(CGRect)rect anType:(NSString*)typeStr
{
    UIImageView *imageView = cell.zoomScrollView.zoomImageView;
    // 加载圆圈显示
    [cell.loadingView startAnimation];
    // 默认为屏幕中间
    [imageView mss_setFrameInSuperViewCenterWithSize:CGSizeMake(browseItem.smallImageView.mssWidth, browseItem.smallImageView.mssHeight)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:browseItem.bigImageUrl] placeholderImage:browseItem.smallImageView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        // 关闭图片浏览view的时候，不需要继续执行小图加载大图动画
        if(self.collectionView.userInteractionEnabled)
        {
            // 停止加载
            [cell.loadingView stopAnimation];
            if(error)
            {
                [self showBrowseRemindViewWithText:@"图片加载失败"];
            }
            else
            {
                // 1 : 图片动画从中心点出来
                if ([typeStr isEqualToString:@"1"])
                {
                    // 当大图frame为空时，需要大图加载完成后重新计算坐标
                    CGRect bigRect = [self getBigImageRectIfIsEmptyRect:rect bigImage:image];
                    // 图片加载成功
                    imageView.frame = [self getFrameInWindow:browseItem.smallImageView];
                    
                    imageView.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0);
                    [UIView animateWithDuration:1 animations:^{
                        
                        imageView.frame = bigRect;
                        
                    } completion:^(BOOL finished) {
                        
                        
                    }];

                }
                else if ([typeStr isEqualToString:@"2"])//  翻页动画效果；
                {
                    // 当大图frame为空时，需要大图加载完成后重新计算坐标
                    CGRect bigRect = [self getBigImageRectIfIsEmptyRect:rect bigImage:image];
                     imageView.frame = bigRect;
                    [self animationWithView:imageView WithAnimationTransition:UIViewAnimationTransitionFlipFromLeft];
                }
                
            }
        }
    }];
}

// 当大图frame为空时，需要大图加载完成后重新计算坐标
- (CGRect)getBigImageRectIfIsEmptyRect:(CGRect)rect bigImage:(UIImage *)bigImage
{
    if(CGRectIsEmpty(rect))
    {
        return [bigImage mss_getBigImageRectSizeWithScreenWidth:self.screenWidth screenHeight:self.screenHeight];
    }
    return rect;
}

@end
