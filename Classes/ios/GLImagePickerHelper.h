//
//  GLImagePickerHelper.h
//  Pods
//
//  Created by Nanba Takeo on 2015/04/07.
//
//

#import <Foundation/Foundation.h>

@interface GLImagePickerHelper : NSObject

@property (nonatomic) BOOL holeCropping;    //  default is YES

- (void)setup;
- (void)cleanup;
- (void)viewWillAppear;
- (NSDictionary *)didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)willShowViewController:(UIViewController *)viewController;

@end
