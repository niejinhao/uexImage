//
//  MyTestView.h
//  EUExImage
//
//  Created by wiselink on 16/8/2.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UexImageMyColor.h"

@interface PhotoBrowerList : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)NSArray * imageArr;

@property(nonatomic,strong)NSMutableArray * photoArray;

@property(nonatomic,strong)UICollectionView * myCollectionView;

-(instancetype)initWithFrame:(CGRect)frame;
@end
