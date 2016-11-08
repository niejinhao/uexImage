//
//  UexImageView.h
//  EUExImage
//
//  Created by cc on 16/7/29.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UexphotoView : UIView  <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)NSArray * array;
@property(nonatomic,strong)UICollectionView *collectionViewd;

-(UIView*)initUexphotoview:(CGRect)frame array:(NSArray *)arr;

@end
