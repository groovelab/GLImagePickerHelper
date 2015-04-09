GLImagePickerHelper
==================

GLImagePickerHelper is helper of UIImagePickerController.

If allowsEditing property of UIImagePickerController is YES, zoom scale of crop view is not correct with landscape image.

![not correct zoom scale](https://raw.github.com/groovelab/GLImagePickerHelper/master/SampleImages/not_correct_zoom.png)

GLImagePickerHelper helps to correct zoom scale of crop view.

![correct zoom scale](https://raw.github.com/groovelab/GLImagePickerHelper/master/SampleImages/correct_zoom.png)

Furthermore GLImagePickerHelper can clip out the image in a circle.

![correct zoom scale](https://raw.github.com/groovelab/GLImagePickerHelper/master/SampleImages/hole_crop.png)

Installation
----------

There are two ways to use this in your project:

- Copy `Classes/ios/*.{h.m}` into your project
- Install with CocoaPods to write Podfile
```ruby
platform :ios
pod 'GLImagePickerHelper'
```

Usage
----------

### Setup

As first, call setup method.

```objc
- (void)setup;
```

### Show hole cropping view

Show hole cropping view or not show hole crop view.
Default is holeCropping is YES.

```objc
@property (nonatomic) BOOL holeCropping;
```

### Adjust zoom scale of crop view

For to correct zoom scale of crop view, call willShowViewController method in navigationController:willShowViewController:animated: method (UINavigationControllerDelegate).

```objc
- (void)willShowViewController:(UIViewController *)viewController;
```

### After picking image

For next time, need to call didFinishPickingMediaWithInfo: method in imagePickerController:didFinishPickingMediaWithInfo: method (UIImagePickerControllerDelegate).

```objc
- (NSDictionary *)didFinishPickingMediaWithInfo:(NSDictionary *)info;
```

Example
----------


### UIViewController

```objc

#import "GLImagePickerHelper.h"

@interface ExampleViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) GLImagePickerHelper *helper;

@end

@implementation ExampleViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];

    self.helper = [GLImagePickerHelper new];
    [self.helper setup];
    //  self.helper.holeCropping = NO;  //  if you don't use hole cropping
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.helper viewWillAppear];
}

- (void)showImagePickerControllerSourceTypeCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)showImagePickerControllerSourceTypePhotoLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    info = [self.helper didFinishPickingMediaWithInfo:info];
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
        [picker dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.helper willShowViewController:viewController];
}

@end
```

### License

GLImagePickerHelper is available under the MIT license.
