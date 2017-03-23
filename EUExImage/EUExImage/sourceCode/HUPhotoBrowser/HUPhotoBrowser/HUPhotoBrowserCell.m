//
//  HUPhotoBrowserCell.m
//  HUPhotoBrowser
//
//  Created by mac on 16/2/24.
//  Copyright (c) 2016年 jinhuadiqigan. All rights reserved.
//

#import "HUPhotoBrowserCell.h"
#import "const.h"
#import "HUWebImageDownloader.h"


@interface HUPhotoBrowserCell () <UIScrollViewDelegate>




@end

@implementation HUPhotoBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self setupView];
        
    }
    
    return self;
    
}

- (void)setupView {
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.maximumZoomScale = 2;
    scrollView.minimumZoomScale = 1;
    scrollView.delegate = self;
    

    [self.contentView addSubview:scrollView];
    
    _scrollView = scrollView;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    [scrollView addSubview:imageView];
    _imageView = imageView;
    
}

- (void)resetZoomingScale {
    
    if (self.scrollView.zoomScale !=1) {
        
        self.scrollView.zoomScale = 1;
    }
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
    
    self.imageView.frame = _scrollView.bounds;
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    
    [self.imageView setCenter:CGPointMake(xcenter, ycenter)];
    
    
    // 延中心点缩放
//    CGRect rect = self.imageView.frame;
//    
//    rect.origin.x = 0;
//    
//    rect.origin.y = 0;
//    
//
//    if (rect.size.width < self.mssWidth) {
//        
//        rect.origin.x = floorf((self.mssWidth - rect.size.width) / 2.0);
//        NSLog(@"aaaaaaaaaaaaa+++++++%f",rect.origin.x);
//       
//    }
//    
//    if (rect.size.height < self.mssHeight) {
//        
//        rect.origin.y = floorf((self.mssHeight - rect.size.height) / 2.0);
//        
//         NSLog(@"bbbbbbbbbbbbbb+++++++%f",rect.origin.x);
//    }
//    
//
//    self.imageView.frame = rect;
//    NSLog(@"ccccccccccc++++++++++++++++++++++++++++++++++++");
   
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPhotoCellDidZommingNotification object:_indexPath];
}

- (void)configureCellWithURLStrings:(NSString *)URLStrings {
    
    self.imageView.image = self.placeholderImage;
    
    NSURL *url = [NSURL URLWithString:URLStrings];
    
    [[HUWebImageDownloader sharedImageDownloader] downloadImageWithURL:url completed:^(UIImage *image, NSError *error, NSURL *imageUrl) {
        
        self.imageView.image = image;
        
        
    }];}

@end
