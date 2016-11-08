//
//  ViewController.h
//  HUPhotoBrowser Demo
//
//  Created by mac on 16/2/25.
//  Copyright (c) 2016年 hujewelz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HUPhotoViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UICollectionView*collectionViewd;
@property(nonatomic,assign)CGRect CGframe;
-(void)initHUPhoto:(CGRect)frame array:(NSArray*)arr;



@end

