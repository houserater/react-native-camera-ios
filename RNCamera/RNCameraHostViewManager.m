//
//  RNCameraHostViewManager.m
//  RNCamera
//
//  Created by Hank Brekke on 7/11/17.
//  Copyright © 2017 Hank Brekke. All rights reserved.
//

#import "RNCameraHostViewManager.h"
#import "RNCameraHostView.h"

#import <React/RCTShadowView.h>
#import <React/RCTImageLoader.h>

@interface RNCameraHostShadowView : RCTShadowView

@end

@implementation RNCameraHostShadowView

- (void)insertReactSubview:(id<RCTComponent>)subview atIndex:(NSInteger)atIndex
{
    [super insertReactSubview:subview atIndex:atIndex];
    if ([subview isKindOfClass:[RCTShadowView class]]) {
        ((RCTShadowView *)subview).size = RCTScreenSize();
    }
}

@end

@interface RNCameraHostViewManager () <RNCameraHostViewInteractor>

@property (nonatomic, strong) NSHashTable *hostViews;

@end

@implementation RNCameraHostViewManager
RCT_EXPORT_MODULE()

- (UIView *)view {
    if (!self.hostViews) {
        self.hostViews = [NSHashTable weakObjectsHashTable];
    }

    RNCameraHostView *view = [[RNCameraHostView alloc] initWithBridge:self.bridge];
    view.delegate = self;
    [self.hostViews addObject:view];
    return view;
}

- (void)presentModalHostView:(RNCameraHostView *)modalHostView withViewController:(RNCameraImagePickerController *)viewController animated:(BOOL)animated {
    [[modalHostView reactViewController] presentViewController:viewController animated:animated completion:nil];
}

- (void)dismissModalHostView:(RNCameraHostView *)modalHostView withViewController:(RNCameraImagePickerController *)viewController animated:(BOOL)animated {
    [viewController dismissViewControllerAnimated:animated completion:nil];
}

- (RCTShadowView *)shadowView {
    return [RNCameraHostShadowView new];
}

- (void)invalidate {
    for (RNCameraHostView *hostView in self.hostViews) {
        [hostView invalidate];
    }
    [self.hostViews removeAllObjects];
}

RCT_EXPORT_VIEW_PROPERTY(animationType, NSString)
RCT_EXPORT_VIEW_PROPERTY(offsetX, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(offsetY, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(onCapture, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCancel, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(cameraDevice, UIImagePickerControllerCameraDevice)
RCT_EXPORT_VIEW_PROPERTY(cameraFlashMode, UIImagePickerControllerCameraFlashMode)
RCT_EXPORT_METHOD(capture) {
    [self.hostViews.anyObject capturePhoto];
}
RCT_EXPORT_METHOD(checkFlashAvailableWithCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice callback:(RCTResponseSenderBlock)callback) {
    [RNCameraHostView checkFlashAvailableWithCameraDevice:cameraDevice callback:callback];
}
RCT_EXPORT_METHOD(resizeImage:(NSString *)fullSizeImagePath toPath:(NSString *)destinationPath withOptions:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback) {
    if (![fullSizeImagePath hasPrefix:@"file:"] || ![destinationPath hasPrefix:@"file:"]) {
        callback(@[ @"File path must be URL-style" ]);
        return;
    }

    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:fullSizeImagePath]]];
    NSURL *destinationURL = [NSURL URLWithString:destinationPath];

    [RNCameraHostView resizeImage:image toFileURL:destinationURL withOptions:options callback:callback];
}

@end
