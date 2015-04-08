//
//  GLImagePickerHelper.m
//  Pods
//
//  Created by Nanba Takeo on 2015/04/07.
//
//

#import "GLImagePickerHelper.h"

#import "UIView+GLImagePickerHelper.h"
#import "UIImage+GLImagePickerHelper.h"

static const CGFloat kCropViewTopMarginGap = 10.;
static const CGFloat kScrollViewTopMarginGap = 36.;

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

- (void)viewWillAppear
{
    [self.fillLayer removeFromSuperlayer];
    self.cameraViewController = nil;
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
    if (self.holeCropping) {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (image) {
            NSMutableDictionary *mutableInfo = info.mutableCopy;
            mutableInfo[UIImagePickerControllerEditedImage] = [image makeCircle];
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
            .origin.y = CGRectGetMinY(cropView.frame) + ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) ? kCropViewTopMarginGap : 0.),
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
                    .origin.y = CGRectGetMinY(scrollView.frame) - kScrollViewTopMarginGap,
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
