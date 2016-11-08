//
//  ViewController.m
//  MSSBrowse
//
//  Created by 于威 on 15/12/5.
//  Copyright © 2015年 于威. All rights reserved.
//

#import "ViewController.h"
#import "MSSBrowseDefine.h"
#import "UIImageView+WebCache.h"
#import "MSSCollectionViewCell.h"
#import "EUtility.h"
#import "MSSBrowseNetworkViewController.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIViewControllerTransitioningDelegate>

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSArray *smallUrlArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    UIView * naView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    naView.backgroundColor = [UIColor blackColor] ;
    [self.view addSubview:naView];
    
    NSString *string = [[NSBundle mainBundle] pathForResource:@"MWPhotoBrowser.bundle/back" ofType:@"png"];
    
    
    UIImageView * backImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 23, 25, 20)];
    backImageView.image = [UIImage imageWithContentsOfFile:string];
    [naView addSubview:backImageView];
    
    UILabel * backTitle = [[UILabel alloc]init];
    backTitle.frame = CGRectMake(33, 25, 35, 20);
    [backTitle setFont:[UIFont fontWithName:@"Marion" size:17]];
    backTitle.textColor = [UIColor whiteColor];
    backTitle.text = @"返回";
    [naView addSubview:backTitle];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 25, 60, 25);
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(tapBakcB) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    _smallUrlArray = self.imageArray;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0,0, 0);
    flowLayout.itemSize = CGSizeMake(MSS_SCREEN_WIDTH/3, MSS_SCREEN_WIDTH/3);
    flowLayout.minimumLineSpacing = 0;
    // 每行内部cell item的间距
    flowLayout.minimumInteritemSpacing = 0;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 44+20, MSS_SCREEN_WIDTH, MSS_SCREEN_HEIGHT - 64) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    //cell注册
    [_collectionView registerClass:[MSSCollectionViewCell class] forCellWithReuseIdentifier:@"MSSCollectionViewCell"];
    [self.view addSubview:_collectionView];
    
}

-(void)tapBakcB
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"返回+++");
        
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_smallUrlArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MSSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MSSCollectionViewCell" forIndexPath:indexPath];
    if (cell)
    {
        if ([[NSString stringWithFormat:@"%@",_smallUrlArray[indexPath.row]]hasPrefix:@"http"])
        {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_smallUrlArray[indexPath.row]]];
            cell.imageView.tag = indexPath.row + 100;
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.clipsToBounds = YES;
        }
        
        else//本地图片显示；
        {
            NSString * pathFile = [NSString stringWithFormat:@"%@",_smallUrlArray[indexPath.row]];
            UIImageView * imageVC= cell.imageView ;
            //            imageVC.backgroundColor = [UIColor redColor];
            imageVC.image = [UIImage imageWithContentsOfFile:pathFile];
            cell.imageView.tag = indexPath.row + 100;
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.clipsToBounds = YES;
        }
        
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *bigUrlArray = _smallUrlArray;
    // 加载网络图片
    NSMutableArray *browseItemArray = [[NSMutableArray alloc]init];
    int i = 0;
    for(i = 0;i < [_smallUrlArray count];i++)
    {
        UIImageView *imageView = [self.view viewWithTag:i + 100];
        MSSBrowseModel *browseItem = [[MSSBrowseModel alloc]init];
        browseItem.bigImageUrl = bigUrlArray[i];// 加载网络图片大图地址
        browseItem.smallImageView = imageView;// 小图
        [browseItemArray addObject:browseItem];
    }
    MSSCollectionViewCell *cell = (MSSCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    MSSBrowseNetworkViewController *bvc = [[MSSBrowseNetworkViewController alloc]initWithBrowseItemArray:browseItemArray currentIndex:cell.imageView.tag - 99 euexObjc:nil Array:_smallUrlArray anType:self.TypeStr];
    bvc.isEqualRatio = NO;// 大图小图不等比时需要设置这个属性（建议等比）
    [self presentViewController:bvc animated:NO completion:^{
        
    }];
    
    
// 加载本地图片
//        NSMutableArray *browseItemArray = [[NSMutableArray alloc]init];
//        int i = 0;
//        for(i = 0;i < [_smallUrlArray count];i++)
//        {
//            UIImageView *imageView = [self.view viewWithTag:i + 100];
//            MSSBrowseModel *browseItem = [[MSSBrowseModel alloc]init];
//    //        browseItem.bigImageLocalPath 建议传本地图片的路径来减少内存使用
//            browseItem.bigImage = imageView.image;// 大图赋值
//            browseItem.smallImageView = imageView;// 小图
//            [browseItemArray addObject:browseItem];
//        }
//        MSSCollectionViewCell *cell = (MSSCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
//        MSSBrowseLocalViewController *bvc = [[MSSBrowseLocalViewController alloc]initWithBrowseItemArray:browseItemArray currentIndex:cell.imageView.tag - 100];
//        [bvc showBrowseViewController];
    
}


- (void)btnClick
{
    [[SDImageCache sharedImageCache]clearMemory];
    [[SDImageCache sharedImageCache]clearDiskOnCompletion:^{
        [_collectionView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
