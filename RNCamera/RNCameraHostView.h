//
//  RNCamera.h
//  RNCamera
//
//  Created by Hank Brekke on 7/11/17.
//  Copyright © 2017 Hank Brekke. All rights reserved.
//

#import <React/RCTInvalidating.h>
#import <React/RCTModalHostViewManager.h>
#import <React/RCTView.h>

#import "RNCameraImagePickerController.h"

@protocol RNCameraHostViewInteractor;

@interface RNCameraHostView : UIView <RCTInvalidating>

@property(nonatomic, copy) NSString *animationType;
@property (nonatomic, copy) RCTDirectEventBlock onCapture;
@property (nonatomic, copy) RCTDirectEventBlock onCancel;

@property (nonatomic, assign) UIImagePickerControllerCameraDevice cameraDevice;
@property (nonatomic, assign) UIImagePickerControllerCameraFlashMode cameraFlashMode;

@property (nonatomic, weak) id<RNCameraHostViewInteractor> delegate;

- (instancetype)initWithBridge:(RCTBridge *)bridge NS_DESIGNATED_INITIALIZER;

+ (void)checkFlashAvailableWithCameraDevice:(UIImagePickerControllerCameraDevice)device callback:(RCTResponseSenderBlock)callback;
- (void)capturePhoto;

@end

@protocol RNCameraHostViewInteractor <NSObject>

- (void)presentModalHostView:(RNCameraHostView *)modalHostView withViewController:(RNCameraImagePickerController *)viewController animated:(BOOL)animated;
- (void)dismissModalHostView:(RNCameraHostView *)modalHostView withViewController:(RNCameraImagePickerController *)viewController animated:(BOOL)animated;

@end
