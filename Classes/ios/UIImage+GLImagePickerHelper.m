//
//  UIImage+GLImagePickerHelper.m
//  Pods
//
//  Created by Nanba Takeo on 2015/04/07.
//
//

#import "UIImage+GLImagePickerHelper.h"

@implementation UIImage (GLImagePickerHelper)

- (UIImage *)makeCornerRound:(CGFloat)cornerRadius
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = (CGRect){
        .origin = CGPointZero,
        .size = self.size,
    };
    imageLayer.contents = (id)self.CGImage;
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = cornerRadius;
    
    UIGraphicsBeginImageContext(imageLayer.frame.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return roundedImage;
}

@end
