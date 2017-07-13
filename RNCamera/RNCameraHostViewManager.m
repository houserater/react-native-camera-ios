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
RCT_EXPORT_VIEW_PROPERTY(onCapture, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCancel, RCTDirectEventBlock)
RCT_EXPORT_METHOD(capture) {
    [self.hostViews.anyObject capturePhoto];
}

@end
