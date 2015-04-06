//
//  GLImagePickerHelper.m
//  Pods
//
//  Created by Nanba Takeo on 2015/04/07.
//
//

#import "GLImagePickerHelper.h"

@interface GLImagePickerHelper ()

@property (nonatomic) UIViewController *cameraViewController;
@property (nonatomic) CALayer *fillLayer;

@end

@implementation GLImagePickerHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.holeCropping = YES;
    }
    return self;
}

- (void)dealloc
{
    [self cleanup];
}

#pragma mark - Public Methods

- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didUIImagePickerControllerUserDidCaptureItem:)
                                                 name:@"_UIImagePickerControllerUserDidCaptureItem"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didUIImagePickerControllerUserDidRejectItem:)
                                                 name:@"_UIImagePickerControllerUserDidRejectItem"
                                               object:nil];
}

- (void)cleanup
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willShowViewController:(UIViewController *)viewController
{
    NSString *className = NSStringFromClass([viewController class]);
    
    if ([className isEqualToString:@"PLUICameraViewController"]) {
        self.cameraViewController = viewController;
    } else if ([className isEqualToString:@"PUUIImageViewController"] ||
               [className isEqualToString:@"PLUIImageViewController"]) {
        if (self.holeCropping) {
            UIView *cropView = [self _cropView:viewController];
            [cropView addCircleHoleLayer];
        }
        [self _adjustZoomScaleInView:viewController.view isCamera:NO];
    }
}

- (NSDictionary *)didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.fillLayer removeFromSuperlayer];
    self.cameraViewController = nil;
    
    if (self.holeCropping) {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (image) {
            NSMutableDictionary *mutableInfo = info.mutableCopy;
            mutableInfo[UIImagePickerControllerEditedImage] = [image makeCornerRound:image.size.width / 2.];
            info = mutableInfo;
        }
    }
    return info;
}

#pragma mark - Private Methods

- (UIView *)_cropView:(UIViewController *)viewController
{
    UIView *cropView;
    NSString *className = NSStringFromClass([viewController class]);
    if ([className isEqualToString:@"PLUICameraViewController"]) {
        cropView = [viewController.view subviewWithClassName:@"PLCropOverlayCropView"];
        
    } else if ([className isEqualToString:@"PUUIImageViewController"] ||
               [className isEqualToString:@"PLUIImageViewController"]) {
        cropView = [viewController.view subviewWithClassName:@"PLCropOverlayCropView"];
        cropView.frame = (CGRect) {
            .origin.x = CGRectGetMinX(cropView.frame),
            .origin.y = CGRectGetMinY(cropView.frame) + ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) ? 10. : 0.),
            .size = cropView.frame.size
        };
    }
    return cropView;
}

- (void)_adjustZoomScaleInView:(UIView *)view isCamera:(BOOL)isCamera
{
    UIView *targetView = [view subviewWithClassName:@"PLImageScrollView"];
    if ([targetView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)targetView;
        CGFloat ratio = CGRectGetWidth(view.frame) / scrollView.contentSize.height;
        if (ratio > 1.) {
            [scrollView setZoomScale:scrollView.zoomScale * ratio animated:YES];
            
            if (isCamera && NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
                scrollView.frame = (CGRect) {
                    .origin.x = CGRectGetMinX(scrollView.frame),
                    .origin.y = CGRectGetMinY(scrollView.frame) - 36.,
                    .size = scrollView.frame.size
                };
            }
        }
    }
}

- (void)_didUIImagePickerControllerUserDidCaptureItem:(NSNotification *)notification
{
    if (!self.cameraViewController) {
        return;
    }
    
    if (self.holeCropping) {
        UIView *cropView = [self _cropView:self.cameraViewController];
        self.fillLayer = [cropView addCircleHoleLayer];
    }
    [self _adjustZoomScaleInView:self.cameraViewController.view isCamera:YES];
}

- (void)_didUIImagePickerControllerUserDidRejectItem:(NSNotification *)notification
{
    [self.fillLayer removeFromSuperlayer];
}

@end

@implementation UIView (layer)

- (CAShapeLayer *)addCircleHoleLayer
{
    return [self addCircleHoleLayerWithRadius:CGRectGetWidth(self.frame) / 2. - 1.];
}

- (CAShapeLayer *)addCircleHoleLayerWithRadius:(CGFloat)radius
{
    return [self addCircleHoleLayerWithRadius:radius topMargin:0.];
}

- (CAShapeLayer *)addCircleHoleLayerWithRadius:(CGFloat)radius topMargin:(CGFloat)topMargin
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
    fillLayer.opacity = 0.6;
    [self.layer addSublayer:fillLayer];
    return fillLayer;
}

@end

@implementation UIView (subview)

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

@implementation UIImage (transform)

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
