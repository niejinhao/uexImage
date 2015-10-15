//
//  ALAsset+OriginImage.m
//  EUExImage
//
//  Created by CeriNo on 15/10/15.
//  Copyright © 2015年 AppCan. All rights reserved.
//

#import "ALAsset+OriginImage.h"

@implementation ALAsset (OriginImage)


-(UIImage *)uexImage_OriginImage{
    ALAssetRepresentation *representation = [self defaultRepresentation];
    UIImage * originImage =[UIImage imageWithCGImage:[representation fullResolutionImage] scale:representation.scale orientation:(UIImageOrientation)representation.orientation];
    return originImage;
}




@end

