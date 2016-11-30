//
//  ImageEXIFView.m
//  EUExImage
//
//  Created by 黄锦 on 16/11/14.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageEXIFView.h"


@implementation ImageEXIFView
static const CGFloat labelPadding = 10;

- (id)initWithFrame:(CGRect )frame title:(NSString *)title desc:(NSString *)desc exif:(NSDictionary *)exif{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blackColor];
    
    [self addExifViewTile:title desc:desc];
    
    if(exif){
//        NSArray *allKeys = exif.allKeys;
//        for (NSInteger i = 0; i < exif.allKeys.count; i ++) {
//            
//            NSString *key = allKeys[i];
//            NSString *val = [NSString stringWithFormat:@"%@",[exif objectForKey:key]];
//            [self addExifViewWith:i title:key desc:val];
//        }
        
        NSInteger index = 0;
        
        NSString *key = @"设备";
        if([exif objectForKey:key]){
            NSString *val = [NSString stringWithFormat:@"%@",[exif objectForKey:key]];
            [self addExifViewWith:index title:key desc:val];
            index ++;
        }
        
        key = @"镜头";
        if([exif objectForKey:key]){
            NSString *val = [NSString stringWithFormat:@"%@",[exif objectForKey:key]];
            [self addExifViewWith:index title:key desc:val];
            index ++;
        }
        
        key = @"光圈";
        if([exif objectForKey:key]){
            NSString *val = [NSString stringWithFormat:@"%@",[exif objectForKey:key]];
            [self addExifViewWith:index title:key desc:val];
            index ++;
        }
        
        key = @"快门";
        if([exif objectForKey:key]){
            NSString *val = [NSString stringWithFormat:@"%@",[exif objectForKey:key]];
            [self addExifViewWith:index title:key desc:val];
            index ++;
        }
        
        key = @"焦距";
        if([exif objectForKey:key]){
            NSString *val = [NSString stringWithFormat:@"%@",[exif objectForKey:key]];
            [self addExifViewWith:index title:key desc:val];
            index ++;
        }
        
        key = @"ISO";
        if([exif objectForKey:key]){
            NSString *val = [NSString stringWithFormat:@"%@",[exif objectForKey:key]];
            [self addExifViewWith:index title:key desc:val];
            index ++;
        }
        
        key = @"补偿";
        if([exif objectForKey:key]){
            NSString *val = [NSString stringWithFormat:@"%@",[exif objectForKey:key]];
            [self addExifViewWith:index title:key desc:val];
            index ++;
        }
        
        key = @"时间";
        if([exif objectForKey:key]){
            NSString *val = [NSString stringWithFormat:@"%@",[exif objectForKey:key]];
            [self addExifViewWith:index title:key desc:val];
            index ++;
        }
        
    }
    
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat maxHeight = 300;
    if (self.descLable.numberOfLines > 0) maxHeight = _descLable.font.leading*_descLable.numberOfLines;
    CGSize textSize = [_descLable.text boundingRectWithSize:CGSizeMake(size.width, maxHeight)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:_descLable.font}
                                                context:nil].size;
    return CGSizeMake(size.width, textSize.height);
}

- (void)addExifViewTile :(NSString *)title desc:(NSString *)desc{
    CGRect titViewCGRect = CGRectMake(labelPadding*3, labelPadding*7,
                                      self.bounds.size.width-labelPadding*6,
                                      labelPadding*10);
    _titView = [[UILabel alloc] initWithFrame:CGRectIntegral(titViewCGRect)];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, labelPadding*3.5,
                                                                                titViewCGRect.size.width,
                                                                                labelPadding*3)];
    titleLab.text = title ? title : @" ";
//    titleLab.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    titleLab.opaque = NO;
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLab.numberOfLines = 1;
    titleLab.textColor = [UIColor whiteColor];
    titleLab.font = [UIFont systemFontOfSize:23];
    [_titView addSubview:titleLab];
    
    if(desc){
        _descLable = [[UILabel alloc] init];
        _descLable.text = desc;
//        _descLable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _descLable.opaque = NO;
        _descLable.backgroundColor = [UIColor clearColor];
        _descLable.textAlignment = NSTextAlignmentLeft;
        _descLable.lineBreakMode = NSLineBreakByTruncatingTail;
        _descLable.numberOfLines = 0;
        _descLable.textColor = [UIColor grayColor];
        _descLable.font = [UIFont systemFontOfSize:13];
        CGSize descSize = [self sizeThatFits:_titView.frame.size];
        _descLable.frame = CGRectMake(0, labelPadding*7, descSize.width, descSize.height);
        [_titView addSubview:_descLable];
        
        titViewCGRect = CGRectMake(labelPadding*3, labelPadding*7,
                                   self.bounds.size.width-labelPadding*6,
                                   labelPadding*10 + descSize.height);
        _titView.frame = titViewCGRect;
    }
    
    
    
    
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, titViewCGRect.size.width, 1)];
    horizontalLine.backgroundColor = [UIColor grayColor];
    [_titView addSubview:horizontalLine];
    
    UIView *horizontalLine2 = [[UIView alloc]initWithFrame:CGRectMake(0, titViewCGRect.size.height-1, titViewCGRect.size.width, 1)];
    horizontalLine2.backgroundColor = [UIColor grayColor];
    [_titView addSubview:horizontalLine2];
    
    [self addSubview:_titView];
}

//- (void)addExifViewWith :(NSInteger ) index title:(NSString *)title desc:(NSString *)desc{
//    
//    CGFloat labY = labelPadding*2.3*index + _titView.frame.origin.y + _titView.frame.size.height + labelPadding*3;
//    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding*3, labY,
//                                                                             self.bounds.size.width-labelPadding*2,
//                                                                             labelPadding*2))];
//    lab1.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    lab1.opaque = NO;
//    lab1.backgroundColor = [UIColor clearColor];
//    lab1.textAlignment = NSTextAlignmentLeft;
//    lab1.lineBreakMode = NSLineBreakByWordWrapping;
//    
//    lab1.numberOfLines = 0;
//    lab1.textColor = [UIColor whiteColor];
//    lab1.font = [UIFont systemFontOfSize:13];
//    lab1.text = [NSString stringWithFormat:@"%@: %@",title,desc];
//    
//    [self addSubview:lab1];
//}


- (void)addExifViewWith :(NSInteger ) index title:(NSString *)title desc:(NSString *)desc{
    CGFloat labY = labelPadding*2.3*index + _titView.frame.origin.y + _titView.frame.size.height + labelPadding*3;
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding*3, labY,
                                                                             self.bounds.size.width-labelPadding*2,
                                                                             labelPadding*2))];
    lab1.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    lab1.opaque = NO;
    lab1.backgroundColor = [UIColor clearColor];
    lab1.textAlignment = NSTextAlignmentLeft;
    lab1.lineBreakMode = NSLineBreakByTruncatingTail;

    lab1.numberOfLines = 0;
    lab1.textColor = [UIColor grayColor];
    lab1.font = [UIFont systemFontOfSize:13];
    lab1.text = title;

    [self addSubview:lab1];

    
    CGFloat lab2X = [lab1.text boundingRectWithSize:lab1.frame.size
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:lab1.font}
                                            context:nil].size.width + 4*labelPadding;
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(lab2X, labY,
                                                                             self.bounds.size.width-labelPadding*6,
                                                                             labelPadding*2))];
    lab2.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    lab2.opaque = NO;
    lab2.backgroundColor = [UIColor clearColor];
    lab2.textAlignment = NSTextAlignmentLeft;
    lab2.lineBreakMode = NSLineBreakByTruncatingTail;

    lab2.numberOfLines = 0;
    lab2.textColor = [UIColor whiteColor];
    lab2.font = [UIFont systemFontOfSize:13];
    lab2.text = desc;

    [self addSubview:lab2];
}
@end