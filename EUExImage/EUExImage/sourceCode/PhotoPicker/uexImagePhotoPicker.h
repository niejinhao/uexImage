//
//  uexImagePhotoPicker.h
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class uexImageAlbumPickerController;
@interface uexImagePhotoPicker : NSObject
@property (nonatomic,weak)uexImageAlbumPickerController *controller;
@property (nonatomic,strong)RACCommand *pickFinishCommand;
-(instancetype)initWithController:(uexImageAlbumPickerController *)controller;
-(void)openWithIndex:(NSInteger)index;


@end
