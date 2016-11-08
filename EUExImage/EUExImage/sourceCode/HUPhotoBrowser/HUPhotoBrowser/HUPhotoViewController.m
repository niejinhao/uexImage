//
//  ViewController.m
//  HUPhotoBrowser Demo
//
//  Created by mac on 16/2/25.
//  Copyright (c) 2016年 hujewelz. All rights reserved.
//

#import "HUPhotoViewController.h"
#import "PhotoCell.h"
#import "HUPhotoBrowser.h"
#import "UIImageView+HUWebImage.h"

@interface HUPhotoViewController ()


@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableArray *URLStrings;

@end

@implementation HUPhotoViewController

-(void)initHUPhoto:(CGRect)frame array:(NSArray *)arr
{
    self.images = arr;
    self.view.frame = frame;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0,0, 0);
    flowLayout.itemSize = CGSizeMake(MSS_SCREEN_WIDTH/4, MSS_SCREEN_WIDTH-64);
//    flowLayout.minimumLineSpacing = 0;
    
    
    // 每行内部cell item的间距
    flowLayout.minimumInteritemSpacing = 0;
    NSLog(@"%f",frame.size.height);
    self.collectionViewd = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:flowLayout];
    
    [self.collectionViewd registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    //self.collectionViewd.backgroundColor = [UIColor whiteColor];
    self.collectionViewd.showsVerticalScrollIndicator = NO;
    self.collectionViewd.dataSource = self;
    self.collectionViewd.delegate = self;
    [self.view addSubview:self.collectionViewd];
    [self.collectionViewd reloadData];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    _URLStrings = [NSMutableArray array];
    self.view.backgroundColor = [UIColor redColor];
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.images.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    //本地照片；
     cell.imageView.image = [UIImage imageNamed:self.images[indexPath.row]];
    
    //网络照片；
    //[cell.imageView hu_setImageWithURL:[NSURL URLWithString:_images[indexPath.row]]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [HUPhotoBrowser showFromImageView:cell.imageView withImages:self.images placeholderImage:nil atIndex:indexPath.row dismiss:nil];
    
       // [HUPhotoBrowser showFromImageView:cell.imageView withURLStrings:self.images atIndex:indexPath.row];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return CGSizeMake(320, 10);
    }else{
        return CGSizeMake(320, 15);
    }
}

@end
