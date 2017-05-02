//
//  uexImagePhotoPicker.h
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
@class uexImageAlbumPickerController;
@interface uexImagePhotoPicker : NSObject
@property (nonatomic,weak)uexImageAlbumPickerController *controller;
@property (nonatomic,assign)BOOL needToShowCannotFinishToast;

- (instancetype)initWithController:(uexImageAlbumPickerController *)controller;
- (BOOL)openWithIndex:(NSInteger)index;




- (RACCommand *)pickFinishCommand;
@end
