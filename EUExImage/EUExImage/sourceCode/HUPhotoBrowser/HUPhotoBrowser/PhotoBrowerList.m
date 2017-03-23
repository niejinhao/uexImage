//
//  MyTestView.m
//  EUExImage
//
//  Created by wiselink on 16/8/2.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import "PhotoBrowerList.h"
#import "PhotoCell.h"
#import "HUPhotoBrowser.h"
#import "UIImageView+HUWebImage.h"
#import "UexImageMySingleton.h"
#import "UexImageMyColor.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
@implementation PhotoBrowerList

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        self.backgroundColor = [UIColor clearColor];
       
        UIView * tabBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
        tabBarView.backgroundColor = [UexImageMyColor colorWithHexString:@"#2E3334"];
        [self addSubview:tabBarView];
        
        //返回按钮；
        UIImageView * backImage = [[UIImageView alloc]initWithFrame:CGRectMake(8, 25, 35, 30)];
        NSString *imageString = [[NSBundle mainBundle] pathForResource:@"uexImage/back" ofType:@"png"];
        backImage.image = [UIImage imageWithContentsOfFile:imageString];
        [tabBarView addSubview:backImage];
        
        UIButton *  backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(8, 25, 45, 30);
        [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
        [tabBarView addSubview:backBtn];
        
        UexImageMySingleton * imageSingShare = [UexImageMySingleton shareMySingLeton];
        
        imageSingShare.tapClick = YES;
        
        //title
        UILabel * titleNameL = [[UILabel alloc]init];
        
        UIFont * font =  [UIFont fontWithName:@"HelveticaNeue" size:22.0f];
        
        titleNameL.font = font;
        
        titleNameL.text =imageSingShare.gridBrowserTitleStr;

        CGSize size = [titleNameL.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
        
        // 名字的W
        CGFloat nameW = size.width;
        
        titleNameL.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-nameW/2, 23, nameW, 35);
        
        titleNameL.textAlignment = NSTextAlignmentCenter;
        
        titleNameL.textColor = [UIColor whiteColor];
        [tabBarView addSubview:titleNameL];
        
        UICollectionViewFlowLayout * colLayout = [[UICollectionViewFlowLayout alloc]init];
        colLayout.minimumLineSpacing = 0;
        colLayout.sectionInset = UIEdgeInsetsMake(0, 0,0, 0);
        colLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width/4, [UIScreen mainScreen].bounds.size.width/4);
        
        // 每行内部cell item的间距
        colLayout.minimumInteritemSpacing = 0;
        
        self.myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) collectionViewLayout:colLayout];
        
        self.myCollectionView.backgroundColor = [UexImageMyColor colorWithHexString:imageSingShare.gridBackgroundColorStr];
        
        [self.myCollectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];
        
        self.myCollectionView.showsVerticalScrollIndicator = NO;
        
        self.myCollectionView.delegate = self;
        
        self.myCollectionView.dataSource = self;
        
        [self addSubview:self.myCollectionView];
        
    }
    
    return self;
    
}


#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    cell.imageView.frame = cell.contentView.frame;
    
    if ([self.imageArr[indexPath.row] rangeOfString:@"http"].location != NSNotFound)
    {
        //网络照片；
        [cell.imageView hu_setImageWithURL:[NSURL URLWithString:self.imageArr[indexPath.row]]];
        
        
    } else {
        
        cell.imageView.image = [UIImage imageWithContentsOfFile:self.imageArr[indexPath.row]];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [HUPhotoBrowser showFromImageView:cell.imageView withImages:self.imageArr placeholderImage:nil atIndex:indexPath.row dismiss:nil];
    
}

-(void)clickBackBtn
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UexImageMySingleton * backLetons = [UexImageMySingleton shareMySingLeton];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            self.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
            
            backLetons.tapClick = NO;
        }];

    }];
    
}

@end
