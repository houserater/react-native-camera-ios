//
//  RNCameraHostViewManager.h
//  RNCamera
//
//  Created by Hank Brekke on 7/11/17.
//  Copyright © 2017 Hank Brekke. All rights reserved.
//

#import <React/RCTViewManager.h>
#import <React/RCTInvalidating.h>

@implementation RCTConvert (RNCameraHostViewManager)

RCT_ENUM_CONVERTER(UIImagePickerControllerCameraDevice, (@{
        @"front": @(UIImagePickerControllerCameraDeviceFront),
        @"rear": @(UIImagePickerControllerCameraDeviceRear),
}), UIImagePickerControllerCameraDeviceRear, integerValue);

RCT_ENUM_CONVERTER(UIImagePickerControllerCameraFlashMode, (@{
        @"off": @(UIImagePickerControllerCameraFlashModeOff),
        @"auto": @(UIImagePickerControllerCameraFlashModeAuto),
        @"on": @(UIImagePickerControllerCameraFlashModeOn),
}), UIImagePickerControllerCameraFlashModeOff, integerValue);

@end

@interface RNCameraHostViewManager : RCTViewManager <RCTInvalidating>

@end
