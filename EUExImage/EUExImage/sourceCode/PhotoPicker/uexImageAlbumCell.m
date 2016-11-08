//
//  uexImageAlbumCell.m
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImageAlbumCell.h"

#define imageOffset 2
#define imageStartX 15
#define imageStartY 15
#define firstImageLength 60
#define imageBorderWidth (1.0/[[UIScreen mainScreen] scale])

@interface uexImageAlbumCell()
@property (nonatomic,assign)BOOL isInitialized;

@end
@implementation uexImageAlbumCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)setupFrame{
    if (self.isInitialized) {
        return;
    }
    self.thumbImage1=[[UIImageView alloc]initWithFrame:CGRectMake(imageStartX ,imageStartY,firstImageLength,firstImageLength)];
    _thumbImage1.layer.borderWidth =imageBorderWidth;
    _thumbImage1.layer.borderColor =[UIColor whiteColor].CGColor;
    
    
    self.thumbImage2=[[UIImageView alloc]initWithFrame:CGRectMake(imageStartX+imageOffset ,imageStartY-imageOffset,firstImageLength-2*imageOffset,firstImageLength-2*imageOffset)];
    _thumbImage2.layer.borderWidth =imageBorderWidth;
    _thumbImage2.layer.borderColor =[UIColor whiteColor].CGColor;
    
    
    self.thumbImage3=[[UIImageView alloc]initWithFrame:CGRectMake(imageStartX+2*imageOffset,imageStartY-2*imageOffset,firstImageLength-4*imageOffset,firstImageLength-4*imageOffset)];
    
    _thumbImage3.layer.borderWidth =imageBorderWidth;
    _thumbImage3.layer.borderColor =[UIColor whiteColor].CGColor;
    
    
    
    [self.contentView addSubview:_thumbImage3];
    [self.contentView addSubview:_thumbImage2];
    [self.contentView addSubview:_thumbImage1];
    
    self.nameLabel =[[UILabel alloc]initWithFrame:CGRectMake(100, 25, 200, 30)];
    [self.nameLabel setFont:[UIFont systemFontOfSize:18]];
    [self.contentView addSubview:self.nameLabel];
    
    self.countLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 55, 200, 20)];
    [self.countLabel setFont:[UIFont systemFontOfSize:14]];
    [self.contentView addSubview:self.countLabel];
    self.isInitialized = YES;
}
@end
