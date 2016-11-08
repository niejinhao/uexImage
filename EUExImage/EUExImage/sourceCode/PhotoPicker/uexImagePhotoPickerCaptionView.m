//
//  uexImagePhotoPickerCaptionView.m
//  EUExImage
//
//  Created by CeriNo on 15/10/16.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "uexImagePhotoPickerCaptionView.h"
static const CGFloat labelPadding = 10;

@implementation uexImagePhotoPickerCaptionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)init{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        self.userInteractionEnabled = NO;

        self.barStyle = UIBarStyleBlackTranslucent;
        self.tintColor = nil;
        self.barTintColor = nil;
        self.barStyle = UIBarStyleBlack;
        [self setTranslucent:YES];
        [self setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self setupCaption];
        [self setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat maxHeight = 9999;
    if (_textLabel.numberOfLines > 0) maxHeight = _textLabel.font.leading*_textLabel.numberOfLines;
    CGSize textSize = [_textLabel.text boundingRectWithSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:_textLabel.font}
                                                context:nil].size;
    return CGSizeMake(size.width, textSize.height + labelPadding * 2);
}

- (void)setupCaption {
    _textLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding, 0,
                                                                      self.bounds.size.width-labelPadding*2,
                                                                      self.bounds.size.height))];
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _textLabel.opaque = NO;
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    _textLabel.numberOfLines = 0;
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.font = [UIFont systemFontOfSize:17];
    _textLabel.text=@"";


    [self addSubview:_textLabel];
}

@end
