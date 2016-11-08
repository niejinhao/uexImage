//
//  MSSBrowseBaseViewController.m
//  MSSBrowse
//
//  Created by 于威 on 16/4/26.
//  Copyright © 2016年 于威. All rights reserved.
//

#import "MSSBrowseBaseViewController.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "UIImage+MSSScale.h"
#import "MSSBrowseRemindView.h"
#import "MSSBrowseActionSheet.h"
#import "MSSBrowseDefine.h"
#import "ViewController.h"
#import "EUtility.h"
#import "UIImage+MSSScale.h"
#import "GYZActionSheet.h"
#import "EUtility.h"
#import "UexImageMySingleton.h"
#import "EBrowserView.h"

@interface MSSBrowseBaseViewController ()

@property (nonatomic,strong)NSArray *browseItemArray;
@property (nonatomic,assign)NSInteger currentIndex;
@property (nonatomic,assign)BOOL isRotate;// 判断是否正在切换横竖屏
@property (nonatomic,strong)UILabel *countLabel;// 当前图片位置
@property (nonatomic,strong)UIView *snapshotView;
@property (nonatomic,strong)NSMutableArray *verticalBigRectArray;
@property (nonatomic,strong)NSMutableArray *horizontalBigRectArray;
@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,assign)UIDeviceOrientation currentOrientation;
@property (nonatomic,strong)MSSBrowseActionSheet *browseActionSheet;
@property (nonatomic,strong)MSSBrowseRemindView *browseRemindView;
@property (nonatomic,strong)EUExImage *euexObjc;
@end

@implementation MSSBrowseBaseViewController

- (instancetype)initWithBrowseItemArray:(NSArray *)browseItemArray currentIndex:(NSInteger)currentIndex euexObjc:(EUExImage *)euexObjc Array:(NSArray *)array anType:(NSString *)type
{
    self = [super init];
    if(self)
    {
        
        self.AnimationTypeStr = type;
        self.bigImageArray = array;
        self.euexObjc = euexObjc;
        _browseItemArray = browseItemArray;
        _currentIndex = currentIndex-1;
        _isEqualRatio = YES;
        _isFirstOpen = YES;
        _screenWidth = MSS_SCREEN_WIDTH;
        _screenHeight = MSS_SCREEN_HEIGHT;
        _currentOrientation = UIDeviceOrientationPortrait;
        _verticalBigRectArray = [[NSMutableArray alloc]init];
        _horizontalBigRectArray = [[NSMutableArray alloc]init];
        
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-60,  self.view.frame.size.height-50, 60, 60)];
        view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:view];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = CGRectMake(self.view.frame.size.width-50, self.view.frame.size.height-38, 30, 30);
        NSString *string = [[NSBundle mainBundle] pathForResource:@"MWPhotoBrowser.bundle/UIBarButtonItemGrid" ofType:@"png"];
        
        [self.button setImage:[UIImage imageWithContentsOfFile:string] forState:UIControlStateNormal];
        [self.button addTarget:self action:@selector(tapClicks) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.button];
        
        
    }
    return self;
}

-(void)tapClicks
{
    ViewController * VController = [[ViewController alloc]init];
    VController.imageArray =self.bigImageArray;
    VController.TypeStr = self.AnimationTypeStr;
    
   // [self.view addSubview:VController.view];
    [self presentViewController:VController animated:YES completion:^{
        NSLog(@"跳转++");
    }];
    
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)showBrowseViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0)
    {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    else
    {
        _snapshotView = [rootViewController.view snapshotViewAfterScreenUpdates:NO];
    }
    [rootViewController presentViewController:self animated:NO completion:^{
        
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    if (self.button)
    {
        [self.button setHidden:NO];
    }
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:10.0f];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self createBrowseView];
    
    //[self performSelector:@selector(delayMethod) withObject:nil afterDelay:10.0f];
    
}
-(void)delayMethod
{
    [self.button setHidden:YES];
}

- (void)initData
{
    for (MSSBrowseModel *browseItem in _browseItemArray)
    {
        CGRect verticalRect = CGRectZero;
        CGRect horizontalRect = CGRectZero;
        
        UIImage *image = [UIImage imageWithContentsOfFile:[self.euexObjc absPath:browseItem.smallImagePath]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        browseItem.smallImageView = imageView;
        
        // 等比可根据小图宽高计算大图宽高
        if(_isEqualRatio)
        {
            if(browseItem.smallImageView)
            {
                verticalRect = [browseItem.smallImageView.image mss_getBigImageRectSizeWithScreenWidth:MSS_SCREEN_WIDTH screenHeight:MSS_SCREEN_HEIGHT];
                horizontalRect = [browseItem.smallImageView.image mss_getBigImageRectSizeWithScreenWidth:MSS_SCREEN_HEIGHT screenHeight:MSS_SCREEN_WIDTH];
            }
        }
        NSValue *verticalValue = [NSValue valueWithCGRect:verticalRect];
        [_verticalBigRectArray addObject:verticalValue];
        NSValue *horizontalValue = [NSValue valueWithCGRect:horizontalRect];
        [_horizontalBigRectArray addObject:horizontalValue];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

// 获取指定视图在window中的位置
- (CGRect)getFrameInWindow:(UIView *)view
{
    // 改用[UIApplication sharedApplication].keyWindow.rootViewController.view，防止present新viewController坐标转换不准问题
    return [view.superview convertRect:view.frame toView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
}

- (void)createBrowseView
{
    self.view.backgroundColor = [UIColor blackColor];
    
    if(_snapshotView)
    {
        _snapshotView.hidden = YES;
        [self.view addSubview:_snapshotView];
    }
    
    _bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    _bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bgView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    // 布局方式改为从上至下，默认从左到右
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // Section Inset就是某个section中cell的边界范围
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // 每行内部cell item的间距
    flowLayout.minimumInteritemSpacing = 0;
    // 每行的间距
    flowLayout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, _screenWidth + kBrowseSpace, _screenHeight) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor blackColor];
    [_collectionView registerClass:[MSSBrowseCollectionViewCell class] forCellWithReuseIdentifier:@"MSSBrowserCell"];
    _collectionView.contentOffset = CGPointMake(_currentIndex * (_screenWidth + kBrowseSpace), 0);
    [_bgView addSubview:_collectionView];
    
    _countLabel = [[UILabel alloc]init];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.frame = CGRectMake(0, _screenHeight - 50, _screenWidth, 50);
    _countLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)_currentIndex + 1,(long)_browseItemArray.count];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    [_bgView addSubview:_countLabel];
    
    _browseRemindView = [[MSSBrowseRemindView alloc]initWithFrame:_bgView.bounds];
    
    [_bgView addSubview:_browseRemindView];
}
- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        UexImageMySingleton * leton = [UexImageMySingleton shareMySingLeton];
        
        NSLog(@"cell长按+++++");
        NSString *jsStr = [NSString stringWithFormat:@"if(uexImage.cbLongpress!=null){uexImage.cbLongpress('%@');}", @"0"];
        [leton.slectImage.meBrwView stringByEvaluatingJavaScriptFromString:jsStr];
    }
    
}

#pragma mark UIColectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSSBrowseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSSBrowserCell" forIndexPath:indexPath];
    if(cell)
    {
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
        [cell.contentView addGestureRecognizer:longPressGesture];
        
        MSSBrowseModel *browseItem = [_browseItemArray objectAtIndex:indexPath.row];
        // 还原初始缩放比例
        cell.zoomScrollView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
        cell.zoomScrollView.zoomScale = 1.0f;
        // 将scrollview的contentSize还原成缩放前
        cell.zoomScrollView.contentSize = CGSizeMake(_screenWidth, _screenHeight);
        cell.zoomScrollView.zoomImageView.contentMode = browseItem.smallImageView.contentMode;
        cell.zoomScrollView.zoomImageView.clipsToBounds = browseItem.smallImageView.clipsToBounds;
        
        [cell.loadingView mss_setFrameInSuperViewCenterWithSize:CGSizeMake(30, 30)];
        CGRect bigImageRect = [_verticalBigRectArray[indexPath.row] CGRectValue];
        if(_currentOrientation != UIDeviceOrientationPortrait)
        {
            bigImageRect = [_horizontalBigRectArray[indexPath.row] CGRectValue];
        }
        //网络加载
        if ([browseItem.bigImageUrl hasPrefix:@"http"])
        {
            [self loadBrowseImageWithBrowseItem:browseItem Cell:cell bigImageRect:CGRectMake(_screenWidth/2, _screenHeight/2, 0, 0)AnType:self.AnimationTypeStr]; //demo中 bigImageRect
        }else{//本地加载
            
            if ([self.AnimationTypeStr isEqualToString:@"1"])
            {
                
                UIImageView * imageV =  cell.zoomScrollView.zoomImageView;
                imageV.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0);
                
                [UIView animateWithDuration:1 animations:^{
                    
                    imageV.frame = [[UIImage imageWithContentsOfFile:browseItem.bigImageUrl]
                                    mss_getBigImageRectSizeWithScreenWidth:self.screenWidth screenHeight:self.screenHeight];
                    
                } completion:^(BOOL finished) {
                    
                    
                }];
                
                imageV.image = [UIImage imageWithContentsOfFile:browseItem.bigImageUrl];
                
            } else if ([self.AnimationTypeStr isEqualToString:@"2"])
            {
                UIImageView * imageV1 =  cell.zoomScrollView.zoomImageView;
                
                imageV1.frame = [[UIImage imageWithContentsOfFile:browseItem.bigImageUrl]
                                 mss_getBigImageRectSizeWithScreenWidth:self.screenWidth screenHeight:self.screenHeight];
                
                imageV1.image = [UIImage imageWithContentsOfFile:browseItem.bigImageUrl];
                
                [self animationWithView:imageV1 WithAnimationTransition:UIViewAnimationTransitionFlipFromLeft];
                
            }
        }
        
        __weak __typeof(self)weakSelf = self;
        [cell tapClick:^(MSSBrowseCollectionViewCell *browseCell) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf tap:browseCell];
        }];
        
        //        [cell longPress:^(MSSBrowseCollectionViewCell *browseCell) {
        //            __strong __typeof(weakSelf)strongSelf = weakSelf;
        //            if([[SDImageCache sharedImageCache]diskImageExistsWithKey:browseItem.bigImageUrl])
        //            {
        //                [strongSelf longPress:browseCell];
        //            }
        //        }];
    }
    return cell;
    
}

#pragma mark UIView实现动画
- (void)animationWithView:(UIView *)view WithAnimationTransition:(UIViewAnimationTransition) transition
{
    [UIView animateWithDuration:1 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationTransition:transition forView:view cache:YES];
    }];
}
// 子类重写此方法
- (void)loadBrowseImageWithBrowseItem:(MSSBrowseModel *)browseItem Cell:(MSSBrowseCollectionViewCell *)cell bigImageRect:(CGRect)bigImageRect AnType:(NSString *)type
{
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _browseItemArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(_screenWidth + kBrowseSpace, _screenHeight);
}

#pragma mark UIScrollViewDeletate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!_isRotate)
    {
        _currentIndex = scrollView.contentOffset.x / (_screenWidth + kBrowseSpace);
        _countLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)_currentIndex + 1,(long)_browseItemArray.count];
    }
    _isRotate = NO;
}

#pragma mark Tap Method
- (void)tap:(MSSBrowseCollectionViewCell *)browseCell
{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    if(_snapshotView)
    {
        _snapshotView.hidden = NO;
    }
    else
    {
        self.view.backgroundColor = [UIColor clearColor];
    }
    // 集合视图背景色设置为透明
    _collectionView.backgroundColor = [UIColor clearColor];
    // 动画结束前不可点击透明背景后的内容
    _collectionView.userInteractionEnabled = NO;
    // 显示状态栏
    [self setNeedsStatusBarAppearanceUpdate];
    // 停止加载
    NSArray *cellArray = _collectionView.visibleCells;
    for (MSSBrowseCollectionViewCell *cell in cellArray)
    {
        [cell.loadingView stopAnimation];
    }
    [_countLabel removeFromSuperview];
    _countLabel = nil;
    
    NSIndexPath *indexPath = [_collectionView indexPathForCell:browseCell];
    browseCell.zoomScrollView.zoomScale = 1.0f;
    MSSBrowseModel *browseItem = _browseItemArray[indexPath.row];
    
    /*
     建议小图列表的collectionView尽量不要复用，因为当小图的列表collectionview复用时，传进来的BrowseItem数组只有当前显示cell的smallImageView，在当前屏幕外的cell上的小图由于复用关系实际是没有的，所以只能有简单的渐变动画
     */
    if(browseItem.smallImageView)
    {
        CGRect rect = [self getFrameInWindow:browseItem.smallImageView];
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        if(_currentOrientation == UIDeviceOrientationLandscapeLeft)
        {
            transform = CGAffineTransformMakeRotation(- M_PI / 2);
            rect = CGRectMake(rect.origin.y, MSS_SCREEN_WIDTH - rect.size.width - rect.origin.x, rect.size.height, rect.size.width);
        }
        else if(_currentOrientation == UIDeviceOrientationLandscapeRight)
        {
            transform = CGAffineTransformMakeRotation(M_PI / 2);
            rect = CGRectMake(MSS_SCREEN_HEIGHT - rect.size.height - rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
        }
        
        //不同类型的关闭动画；
        //        if ([self.AnimationTypeStr isEqualToString:@"1"])
        //        {
        [UIView animateWithDuration:1 animations:^{
            browseCell.zoomScrollView.zoomImageView.transform = transform;
            browseCell.zoomScrollView.zoomImageView.frame = rect;
            
            browseCell.zoomScrollView.zoomImageView.frame = CGRectMake(MSS_SCREEN_WIDTH/2, MSS_SCREEN_HEIGHT/2, 0, 0 );
            
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:^{
                
            }];
            
//            [self.view removeFromSuperview];
//            [_bgView removeFromSuperview];
            
        }];
        //
        //        }
        
    }
    else
    {
        //        if ([self.AnimationTypeStr isEqualToString:@"1"])
        //        {
        
        [UIView animateWithDuration:0.1 animations:^{
            self.view.alpha = 0.0;
            
//            [self.view removeFromSuperview];
//            [_bgView removeFromSuperview];

            
            [self dismissViewControllerAnimated:NO completion:^{
                
            }];
        } completion:^(BOOL finished) {
            
        }];
        
        //        }
    }
}
//-(void)chooseFunction:(MSSBrowseCollectionViewCell *)browseCell Array:(NSArray *)array
//{
////    UexImageMySingleton * dddd = [UexImageMySingleton shareMySingLeton];
////    NSLog(@"%@",dddd.slectImage);
////    GYZActionSheet *actionSheet = [[GYZActionSheet alloc] initSheetWithTitle:nil style:GYZSheetStyleWeiChat itemTitles:array euex:dddd.slectImage];
////    actionSheet.cancleTitle = @"取消";
////    actionSheet.delegate  = self;
//    
//    
//}

#pragma GYZActionSheetDelegate
-(void)sheetViewDidSelectIndex:(NSInteger)index title:(NSString *)title {
    NSLog(@"第%ld行,%@",index, title);
}

//- (void)longPress:(MSSBrowseCollectionViewCell *)browseCell
//{
//    [self.euexObjc longPress:@"1"];
//    NSString *jsStr = [NSString stringWithFormat:@"if(uexImage.cbLongpress!=null){uexImage.cbLongpress('%@');}", @"0"];
//    [self.euexObjc.meBrwView stringByEvaluatingJavaScriptFromString:jsStr];
//    [_browseActionSheet removeFromSuperview];
//    _browseActionSheet = nil;
//    __weak __typeof(self)weakSelf = self;
//    _browseActionSheet = [[MSSBrowseActionSheet alloc]initWithTitleArray:@[@"保存图片",@"复制图片地址"] cancelButtonTitle:@"取消" didSelectedBlock:^(NSInteger index) {
//        __strong __typeof(weakSelf)strongSelf = weakSelf;
//        [strongSelf browseActionSheetDidSelectedAtIndex:index currentCell:browseCell];
//    }];
//    [_browseActionSheet showInView:_bgView];
//}

#pragma mark StatusBar Method
- (BOOL)prefersStatusBarHidden
{
    if(!_collectionView.userInteractionEnabled)
    {
        return NO;
    }
    return YES;
}

#pragma mark Orientation Method
- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        _isRotate = YES;
        _currentOrientation = orientation;
        if(_currentOrientation == UIDeviceOrientationPortrait)
        {
            _screenWidth = MSS_SCREEN_WIDTH;
            _screenHeight = MSS_SCREEN_HEIGHT;
            [UIView animateWithDuration:0.5 animations:^{
                _bgView.transform = CGAffineTransformMakeRotation(0);
            }];
        }
        else
        {
            _screenWidth = MSS_SCREEN_HEIGHT;
            _screenHeight = MSS_SCREEN_WIDTH;
            if(_currentOrientation == UIDeviceOrientationLandscapeLeft)
            {
                [UIView animateWithDuration:0.5 animations:^{
                    _bgView.transform = CGAffineTransformMakeRotation(M_PI / 2);
                }];
            }
            else
            {
                [UIView animateWithDuration:0.5 animations:^{
                    _bgView.transform = CGAffineTransformMakeRotation(- M_PI / 2);
                }];
            }
        }
        _bgView.frame = CGRectMake(0, 0, MSS_SCREEN_WIDTH, MSS_SCREEN_HEIGHT);
        _browseRemindView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
        if(_browseActionSheet)
        {
            [_browseActionSheet updateFrame];
        }
        _countLabel.frame = CGRectMake(0, _screenHeight - 50, _screenWidth, 50);
        [_collectionView.collectionViewLayout invalidateLayout];
        _collectionView.frame = CGRectMake(0, 0, _screenWidth + kBrowseSpace, _screenHeight);
        _collectionView.contentOffset = CGPointMake((_screenWidth + kBrowseSpace) * _currentIndex, 0);
        [_collectionView reloadData];
    }
}

#pragma mark MSSActionSheetClick
- (void)browseActionSheetDidSelectedAtIndex:(NSInteger)index currentCell:(MSSBrowseCollectionViewCell *)currentCell
{    // 保存图片
    if(index == 0)
    {
        UIImageWriteToSavedPhotosAlbum(currentCell.zoomScrollView.zoomImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    // 复制图片地址
    else if(index == 1)
    {
        MSSBrowseModel *currentBwowseItem = _browseItemArray[_currentIndex];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = currentBwowseItem.bigImageUrl;
        [self showBrowseRemindViewWithText:@"复制图片地址成功"];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *text = nil;
    if(error)
    {
        text = @"保存图片失败";
    }
    else
    {
        text = @"保存图片成功";
    }
    [self showBrowseRemindViewWithText:text];
}

#pragma mark RemindView Method
- (void)showBrowseRemindViewWithText:(NSString *)text
{
    [_browseRemindView showRemindViewWithText:text];
    _bgView.userInteractionEnabled = NO;
    [self performSelector:@selector(hideRemindView) withObject:nil afterDelay:0.7];
}

- (void)hideRemindView
{
    [_browseRemindView hideRemindView];
    _bgView.userInteractionEnabled = YES;
}

@end
