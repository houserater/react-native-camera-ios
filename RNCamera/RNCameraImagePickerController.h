//
// Created by Hank Brekke on 7/11/17.
// Copyright (c) 2017 Hank Brekke. All rights reserved.
//

#import <UIKit/UIKit.h>

#if TARGET_IPHONE_SIMULATOR
@interface RNCameraImagePickerController : UIViewController

@property (nonatomic, retain) UIView *cameraOverlayView;
@property (nonatomic, assign) BOOL showsCameraControls;
@property (nonatomic, assign) CGAffineTransform cameraViewTransform;
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;
@property (nonatomic, weak) id<UIImagePickerControllerDelegate> delegate;

- (void)takePicture;
- (void)setCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice;
- (void)setCameraFlashMode:(UIImagePickerControllerCameraFlashMode)cameraFlashMode;
#else
@interface RNCameraImagePickerController : UIImagePickerController
#endif

@property (nonatomic, copy) void (^boundsDidChangeBlock)(CGRect newBounds);

@end
