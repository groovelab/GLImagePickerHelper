//
//  UIView+GLImagePickerHelper.m
//  Pods
//
//  Created by Nanba Takeo on 2015/04/07.
//
//

#import "UIView+GLImagePickerHelper.h"

@implementation UIView (GLImagePickerHelper)

- (CAShapeLayer *)addCircleHoleLayer
{
    return [self addCircleHoleLayerWithRadius:CGRectGetWidth(self.frame) / 2. - 1.];
}

- (CAShapeLayer *)addCircleHoleLayerWithRadius:(CGFloat)radius
{
    return [self addCircleHoleLayerWithRadius:radius alpha:0.6 topMargin:0.];
}

- (CAShapeLayer *)addCircleHoleLayerWithRadius:(CGFloat)radius alpha:(CGFloat)alpha topMargin:(CGFloat)topMargin
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.frame cornerRadius:0.];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:(CGRect){
        .origin.x = CGRectGetWidth(self.frame) / 2. - radius,
        .origin.y = CGRectGetHeight(self.frame) / 2. - radius + topMargin,
        .size.width = radius * 2.,
        .size.height = radius * 2.
    } cornerRadius:radius];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = alpha;
    [self.layer addSublayer:fillLayer];
    return fillLayer;
}

- (UIView *)subviewAtIndex:(NSInteger)index
{
    if (self.subviews.count <= index) {
        return nil;
    }
    return self.subviews[index];
}

- (UIView *)subviewWithClassName:(NSString *)targetClassName
{
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) isEqualToString:targetClassName]) {
            return subview;
        }
        
        UIView *targetSubview = [subview subviewWithClassName:targetClassName];
        if (targetSubview) {
            return targetSubview;
        }
    }
    return nil;
}

@end
