//
//  UIView+GLImagePickerHelper.h
//  Pods
//
//  Created by Nanba Takeo on 2015/04/07.
//
//

#import <UIKit/UIKit.h>

@interface UIView (GLImagePickerHelper)

- (CAShapeLayer *)addCircleHoleLayer;
- (CAShapeLayer *)addCircleHoleLayerWithRadius:(CGFloat)radius;
- (CAShapeLayer *)addCircleHoleLayerWithRadius:(CGFloat)radius alpha:(CGFloat)alpha topMargin:(CGFloat)topMargin;

- (UIView *)subviewAtIndex:(NSInteger)index;
- (UIView *)subviewWithClassName:(NSString *)targetClassName;

@end
