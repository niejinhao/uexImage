//
//  UexImageView.m
//  EUExImage
//
//  Created by cc on 16/7/29.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import "UexphotoView.h"
#import "PhotoCell.h"
#import "UIImageView+HUWebImage.h"
#import "HUPhotoBrowser.h"

@implementation UexphotoView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */



-(UIView*)initUexphotoview:(CGRect)frame array:(NSArray *)arr
{
    self.array = arr;
    UexphotoView * ima = [[UexphotoView alloc]initWithFrame:frame];
    ima.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    self.collectionViewd = [[UICollectionView alloc]initWithFrame:ima.bounds collectionViewLayout:layout];
    [self.collectionViewd registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    self.collectionViewd.backgroundColor = [UIColor whiteColor];
    self.collectionViewd.showsHorizontalScrollIndicator = NO;
    self.collectionViewd.dataSource = self;
    self.collectionViewd.delegate = self;
    [ima addSubview:self.collectionViewd];
    [self.collectionViewd reloadData];

    return ima;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    //本地照片；
    UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 375, 500)];
    image.image =  [UIImage imageWithContentsOfFile:self.array[indexPath.row]];
    [cell.contentView addSubview:image];
    // cell.imageView.image = [UIImage imageWithContentsOfFile:self.array[indexPath.row]];
    
    //网络照片；
    //[cell.imageView hu_setImageWithURL:[NSURL URLWithString:self.array[indexPath.row]]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    //[HUPhotoBrowser showFromImageView:cell.imageView withImages:self.images placeholderImage:nil atIndex:indexPath.row dismiss:nil];
    [HUPhotoBrowser showFromImageView:cell.imageView withURLStrings:self.array atIndex:indexPath.row];
}

@end
