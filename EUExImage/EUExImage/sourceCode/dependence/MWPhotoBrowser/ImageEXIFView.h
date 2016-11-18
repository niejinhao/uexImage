//
//  ImageEXIFView.h
//  EUExImage
//
//  Created by 黄锦 on 16/11/14.
//  Copyright © 2016年 AppCan. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ImageEXIFView : UIView

@property (nonatomic,strong)NSDictionary *exif;
@property (nonatomic ,strong)UIView *titView;
@property (nonatomic ,strong)UILabel *descLable;


- (id)initWithFrame:(CGRect )frame title:(NSString *)title desc:(NSString *)desc exif:(NSDictionary *)exif;

@end