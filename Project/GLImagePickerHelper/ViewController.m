//
//  ViewController.m
//  GLImagePickerHelper
//
//  Created by Nanba Takeo on 2015/04/07.
//  Copyright (c) 2015年 GrooveLab. All rights reserved.
//

#import "ViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <GLImagePickerHelper/GLImagePickerHelper.h>

@interface ViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic) GLImagePickerHelper *helper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.helper = [GLImagePickerHelper new];
    [self.helper setup];
}

- (IBAction)_didTouchButton:(id)sender
{
    self.helper.holeCropping = NO;
    [self _showActionSheet];
}

- (IBAction)_didTouchButton2:(id)sender
{
    self.helper.holeCropping = YES;
    [self _showActionSheet];
}

- (void)_showActionSheet
{
    if (NSClassFromString(@"UIAlertController")){
        [self showAlertControllerActionSheet];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    
    NSInteger index = 0;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:@"camera"];
        index++;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:@"library"];
        index++;
    }
    
    [actionSheet addButtonWithTitle:@"cancel"];
    actionSheet.cancelButtonIndex = index;
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"camera"]) {
        [self showImagePickerControllerSourceTypeCamera];
        return;
    }
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"library"]) {
        [self showImagePickerControllerSourceTypePhotoLibrary];
        return;
    }
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
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"please authorize" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)showAlertControllerActionSheet
{
    UIAlertController * actionController = [UIAlertController alertControllerWithTitle:nil
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionController addAction:[UIAlertAction actionWithTitle:@"camera"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [self showImagePickerControllerSourceTypeCamera];
                                                           }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionController addAction:[UIAlertAction actionWithTitle:@"library"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [self showImagePickerControllerSourceTypePhotoLibrary];
                                                           }]];
    }
    [actionController addAction:[UIAlertAction actionWithTitle:@"cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil]];
    [self presentViewController:actionController animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    info = [self.helper didFinishPickingMediaWithInfo:info];
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    CGRect rect = CGRectMake(0, 0, 250, 250);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = resizedImage;
        [picker dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    [self.helper willShowViewController:viewController];
}

@end
