//
//  ALAsset+uexIAPC_Origin_Image.m
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "ALAsset+uexIAPC_Origin_Image.h"

@implementation ALAsset (uexIAPC_Origin_Image)
-(UIImage *)uexIAPC_getOriginImage{
    ALAssetRepresentation *representation = [self defaultRepresentation];
    UIImage * originImage =[UIImage imageWithCGImage:[representation fullResolutionImage] scale:representation.scale orientation:(UIImageOrientation)representation.orientation];
    return originImage;
}
@end
