//
//  MSSBrowseBaseViewController.h
//  MSSBrowse
//
//  Created by 于威 on 16/4/26.
//  Copyright © 2016年 于威. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSBrowseCollectionViewCell.h"
#import "MSSBrowseModel.h"
#import "EUExImage.h"
#import "GYZActionSheet.h"

@interface MSSBrowseBaseViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIViewControllerTransitioningDelegate,GYZActionSheetDelegate>

@property (nonatomic,assign)BOOL isEqualRatio;// 大小图是否等比（默认为等比）

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,assign)BOOL isFirstOpen;
@property (nonatomic,assign)CGFloat screenWidth;
@property (nonatomic,assign)CGFloat screenHeight;
@property(nonatomic,strong)NSArray * bigImageArray;
@property(nonatomic,strong)NSString * AnimationTypeStr;

@property(nonatomic,strong)UIButton * button;

- (instancetype)initWithBrowseItemArray:(NSArray *)browseItemArray currentIndex:(NSInteger)currentIndex euexObjc:(EUExImage *)euexObjc Array:(NSArray*)array anType:(NSString*)type;
- (void)showBrowseViewController;

// 子类重写此方法
- (void)loadBrowseImageWithBrowseItem:(MSSBrowseModel *)browseItem Cell:(MSSBrowseCollectionViewCell *)cell bigImageRect:(CGRect)bigImageRect AnType: (NSString*)type;
- (void)showBrowseRemindViewWithText:(NSString *)text;
// 获取指定视图在window中的位置
- (CGRect)getFrameInWindow:(UIView *)view;


@end
