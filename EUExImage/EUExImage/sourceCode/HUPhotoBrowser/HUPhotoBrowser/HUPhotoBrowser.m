//
//  HUPhotoBrowser.m
//  HUPhotoBrowser
//
//  Created by mac on 16/2/24.
//  Copyright (c) 2016年 jinhuadiqigan. All rights reserved.
//

#import "HUPhotoBrowser.h"
#import "HUPhotoBrowserCell.h"
#import "const.h"
#import "UexImageMySingleton.h"
#import "UexphotoView.h"
#import "PhotoBrowerList.h"

//#import "JSON.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface HUPhotoBrowser () <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate> {
    
    CGRect _endTempFrame;
    NSInteger _currentPage;
    NSIndexPath *_zoomingIndexPath;
    
    
}


@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *URLStrings;
@property (nonatomic) NSInteger index;
@property (nonatomic, copy) DismissBlock dismissDlock;
@property (nonatomic, strong) NSArray *images;





@end

@implementation HUPhotoBrowser

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)showFromImageView:(UIImageView *)imageView withURLStrings:(NSArray *)URLStrings placeholderImage:(UIImage *)image atIndex:(NSInteger)index dismiss:(DismissBlock)block {
    
    NSLog(@"111111111");
    UexImageMySingleton * leton = [UexImageMySingleton shareMySingLeton];
    HUPhotoBrowser *browser = [[HUPhotoBrowser alloc] initWithFrame:leton.preframe];
    browser.imageView = imageView;
    browser.URLStrings = URLStrings;
    [browser configureBrowser];
    
    if (imageView) {
        
        [browser animateImageViewAtIndex:index];
    }
    
    browser.placeholderImage = image;
    browser.dismissDlock = block;
    
    return browser;
}

+ (instancetype)showFromImageView:(UIImageView *)imageView withImages:(NSArray *)images placeholderImage:(UIImage *)image atIndex:(NSInteger)index dismiss:(DismissBlock)block {
    
    NSLog(@"2222222");
    
    UexImageMySingleton * leton = [UexImageMySingleton shareMySingLeton];

    HUPhotoBrowser *browser = [[HUPhotoBrowser alloc] initWithFrame:leton.preframe];
    
    browser.imageView = imageView;
    
    browser.images = images;
    
    [browser configureBrowser];
    
    if (imageView) {
        
        [browser animateImageViewAtIndex:index];
    }
    
    for (int i = 0 ; i<leton.placeholderArray.count ; i++)
    {
        browser.placeholderImage = [UIImage imageWithContentsOfFile:leton.placeholderArray[i]];
    }
    
    browser.dismissDlock = block;
    NSLog(@"333333");
    return browser;
}

+ (instancetype)showFromImageView:(UIImageView *)imageView withURLStrings:(NSArray *)URLStrings atIndex:(NSInteger)index {
    
    return [self showFromImageView:imageView withURLStrings:URLStrings placeholderImage:nil atIndex:index dismiss:nil];
}

+ (instancetype)showFromImageView:(UIImageView *)imageView withImages:(NSArray *)images atIndex:(NSInteger)index {
    
    NSLog(@"uexImageBrower++showFromImageView___接口++++");
    return [self showFromImageView:imageView withImages:images placeholderImage:nil atIndex:index dismiss:nil];
}

#pragma mark - private

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:layout];
        
        collectionView.hidden = YES;
        
        collectionView.pagingEnabled = YES;
        
        collectionView.showsHorizontalScrollIndicator = NO;
        
        _collectionView = collectionView;
        
        [_collectionView reloadData];
        
        [self addSubview:collectionView];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadForScreenRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoCellDidZooming:) name:kPhotoCellDidZommingNotification object:nil];
        
    }
    return self;
}

- (void)configureBrowser {
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[HUPhotoBrowserCell class] forCellWithReuseIdentifier:kPhotoBrowserCellID];
        
//    UITapGestureRecognizer * singleGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
//    
//    singleGes.numberOfTouchesRequired=1;
//    [self.collectionView addGestureRecognizer:singleGes];
    
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    
    [self.collectionView addGestureRecognizer:longPressGesture];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-60, [UIScreen mainScreen].bounds.size.height-50, 60, 50)];
    view.backgroundColor = [UIColor clearColor];
    
    [self addSubview:view];
    
    UexImageMySingleton * backLenton = [UexImageMySingleton shareMySingLeton];
    
    if (backLenton.tapClick==NO)
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-55, [UIScreen mainScreen].bounds.size.height-43, 40, 28);
        NSString *string = [[NSBundle mainBundle] pathForResource:@"MWPhotoBrowser.bundle/uiimage" ofType:@"png"];
        [button setImage:[UIImage imageWithContentsOfFile:string] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tapBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
    } else {
    
        NSLog(@"tapClick==YES");
    }
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    tap.numberOfTapsRequired=1;//单击
    tap.numberOfTouchesRequired=1;//单点触碰
    [self.collectionView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired=2;//避免单击与双击冲突
    [tap requireGestureRecognizerToFail:doubleTap];
    [self.collectionView addGestureRecognizer:doubleTap];
    
}


-(void)doubleTap:(UITapGestureRecognizer *)tap
{
//    scrollView.zoomScale=2.0;//双击放大到两倍
    NSLog(@"双击++++++++++++++++++++++++++++++++++++++");
     UexImageMySingleton * leton = [UexImageMySingleton shareMySingLeton];
    CGPoint tapPoint = [tap locationInView:leton.scrollView];
    
    [self zoomDoubleTapWithPoint:tapPoint];

}
- (void)zoomDoubleTapWithPoint:(CGPoint)touchPoint
{
    UexImageMySingleton * leton = [UexImageMySingleton shareMySingLeton];
    
    if(leton.scrollView.zoomScale > leton.scrollView.minimumZoomScale)
    {
        [leton.scrollView setZoomScale:leton.scrollView.minimumZoomScale animated:YES];
        
        leton.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        
    } else  {
        
        
        CGFloat width = self.bounds.size.width / leton.scrollView.maximumZoomScale;
        
        CGFloat height = self.bounds.size.height / leton.scrollView.maximumZoomScale;
        
       
        // UIViewContentModeScaleToFill    UIViewContentModeScaleAspectFill
        leton.photoImageView.contentMode = UIViewContentModeScaleAspectFill;

         [leton.scrollView zoomToRect:CGRectMake(touchPoint.x - width / 2, touchPoint.y - height / 2, width, height) animated:YES];
    
        
    }
}

#pragma mark ---获取图片列表

-(void)tapBtn
{
   
    UexImageMySingleton * ImageLeton = [UexImageMySingleton shareMySingLeton];
    
    PhotoBrowerList * test = [[PhotoBrowerList alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height,  ImageLeton.PicGrid.size.width,  ImageLeton.PicGrid.size.height)];
    
    test.imageArr = self.images;
    
    ImageLeton.PhotoBrowse = self;
    
    [[UIApplication sharedApplication].keyWindow addSubview:test];
    
    [UIView animateWithDuration:0 animations:^{
        
        // 设置view弹出来的位置
        
        test.frame =ImageLeton.PicGrid;
    }];
    
    [self removeFromSuperview];
    
}
- (void)animateImageViewAtIndex:(NSInteger)index {
    
    _index = index;
    
    CGRect startFrame = [self.imageView.superview convertRect:self.imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    
    if (CGRectEqualToRect(startFrame, CGRectZero)) {
        
        startFrame = CGRectMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2,0, 0);
        NSLog(@"chenjian+++++");
    }
    
    CGRect endFrame = kScreenRect;
    
    //        self.imageView.hidden = YES;
    
    if (self.imageView.image) {
        
        NSLog(@"uexImage++++存在++++");
        
        UIImage *image = self.imageView.image;
        
        CGFloat ratio = image.size.width / image.size.height;
        
        
        if (ratio > kScreenRatio) {
            
            endFrame.size.height = kScreenWidth / ratio;
            
        } else {
            
            endFrame.size.height = kScreenHeight * ratio;
        }
        
        endFrame.origin.x = (kScreenWidth - endFrame.size.width) / 2;
        
        endFrame.origin.y = (kScreenHeight - endFrame.size.height) / 2;
        
    }
    
    _endTempFrame = endFrame;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:startFrame];
    
    tempImageView.image = self.imageView.image;
    
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [[UIApplication sharedApplication].keyWindow addSubview:tempImageView];
    
    UexImageMySingleton * ImageLeton = [UexImageMySingleton shareMySingLeton];
    
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        if (!self.imageView.image) {
            
            
            
            self.frame = ImageLeton.preframe;
            
        } else {
            
            tempImageView.frame = ImageLeton.preframe;
            NSLog(@"chenjian+++++存在+++++");
            
        }
        
        _currentPage = index;
        
        [self.collectionView setContentOffset:CGPointMake(kScreenWidth * index,0) animated:NO];
        
    } completion:^(BOOL finished) {
        
        [tempImageView removeFromSuperview];
        
        self.collectionView.hidden = NO;
        
        NSLog(@"chengjian+++++完成++++++");
    }];
    
    
    
}

//长安手势方法；
- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture
{
    UEX_ERROR errs ;
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        UexImageMySingleton * leton = [UexImageMySingleton shareMySingLeton];
        
        CGPoint point = [gesture locationInView:_collectionView];
        
        NSIndexPath * indexPath = [_collectionView indexPathForItemAtPoint:point];
        
        NSString * indexImagePath = [leton.longImagePath objectAtIndex:indexPath.row];
         
        NSLog(@"+++++++%ld+++++++%@",(long)indexPath.row,leton.longImagePath);
        
        NSMutableDictionary * longDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:indexImagePath,@"imagePath",nil];
        
        //NSString * longImagePathStr = [longDict ac_JSONFragment];
        
//        NSString *jsStr = [NSString stringWithFormat:@"if(uexImage.onImageLongClicked!=null){uexImage.onImageLongClicked('%@');}", longImagePathStr];
        
        [leton.slectImage.webViewEngine callbackWithFunctionKeyPath:@"uexImage.onImageLongClicked" arguments:ACArgsPack(errs,longDict.ac_JSONFragment)];
        
        errs = kUexNoError;
        
        [leton.cb executeWithArguments:ACArgsPack(errs,longDict.ac_JSONFragment)];
        
        NSLog(@"++长按回调++++++%@+%@****%@",leton.slectImage.webViewEngine,longDict.ac_JSONFragment,leton.cb);
        
    }
    
}

- (void)dismiss {
    
    NSLog(@"单击++++++++++++++++++++++++++++++++++++++");
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    if (self.dismissDlock) {
        
        HUPhotoBrowserCell *cell = (HUPhotoBrowserCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage inSection:0]];
        
        self.dismissDlock(cell.imageView.image, _currentPage);
    }
    
    if (_currentPage != _index) {
        
        [self removeFromSuperview];
        
        return;
    }
    
    CGRect endFrame = [self.imageView.superview convertRect:self.imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:_endTempFrame];
    
    tempImageView.image = self.imageView.image;
    
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.collectionView.hidden = YES;
    
    [[UIApplication sharedApplication].keyWindow addSubview:tempImageView];
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        tempImageView.frame = endFrame;
        
        [self removeFromSuperview];
        
    } completion:^(BOOL finished) {
        
        [tempImageView removeFromSuperview];
        
    }];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HUPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoBrowserCellID forIndexPath:indexPath];
    
    cell.indexPath = indexPath;
    
    cell.placeholderImage = self.placeholderImage;
    
    [cell resetZoomingScale];
    
     UexImageMySingleton * leton = [UexImageMySingleton shareMySingLeton];
    if ([self.images[indexPath.row] rangeOfString:@"http"].location != NSNotFound)
    {
        [cell configureCellWithURLStrings:self.images[indexPath.row]];
        
    } else {
        
        
        cell.imageView.image = [UIImage imageWithContentsOfFile:self.images[indexPath.row]];
        
//        self.ssss = [UIImage imageWithContentsOfFile:self.images[indexPath.row]].size;
    }
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
   
    leton.scrollView = cell.scrollView;
    
    leton.photoImageView = cell.imageView;
    
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return kScreenRect.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    _currentPage = scrollView.contentOffset.x/kScreenWidth + 0.5;
    
    if (_zoomingIndexPath) {
        
        [self.collectionView reloadItemsAtIndexPaths:@[_zoomingIndexPath]];
        
        _zoomingIndexPath = nil;
    }
    
}

- (void)reloadForScreenRotate {
    
    _collectionView.frame = kScreenRect;
    
    [_collectionView reloadData];
    
    _collectionView.contentOffset = CGPointMake(kScreenWidth * _currentPage,0);
    
}

- (void)photoCellDidZooming:(NSNotification *)nofit {
    
    NSIndexPath *indexPath = nofit.object;
    
    _zoomingIndexPath = indexPath;
    
}

@end
