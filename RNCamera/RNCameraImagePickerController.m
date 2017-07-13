//
// Created by Hank Brekke on 7/11/17.
// Copyright (c) 2017 Hank Brekke. All rights reserved.
//

#import "RNCameraImagePickerController.h"

@interface RNCameraImagePickerController ()

@property (nonatomic, assign) CGRect lastViewFrame;

#if TARGET_IPHONE_SIMULATOR

@property (nonatomic, retain) NSTimer *cameraTimer;
@property (nonatomic, assign) int cameraRed;
@property (nonatomic, assign) int cameraGreen;
@property (nonatomic, assign) int cameraBlue;

- (void)shiftColor;

#endif

@end

@implementation RNCameraImagePickerController

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.boundsDidChangeBlock && !CGRectEqualToRect(self.lastViewFrame, self.view.frame)) {
        self.boundsDidChangeBlock(self.view.bounds);
        self.lastViewFrame = self.view.frame;
    }
}

#if TARGET_IPHONE_SIMULATOR

- (void)viewDidLoad {
    [super viewDidLoad];

    self.cameraTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(shiftColor) userInfo:nil repeats:YES];
}

- (void)setCameraOverlayView:(UIView *)cameraOverlayView {
    if (_cameraOverlayView) {
        [_cameraOverlayView removeFromSuperview];
    }

    if (cameraOverlayView) {
        cameraOverlayView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        cameraOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.view insertSubview:cameraOverlayView atIndex:0];
    }
    _cameraOverlayView = cameraOverlayView;
}

- (void)shiftColor {
    self.cameraRed += 1;
    self.cameraGreen += 2;
    self.cameraBlue += 3;

    self.view.backgroundColor = [UIColor colorWithRed:abs(self.cameraRed % 510 - 255) / 255.0f
                                                green:abs(self.cameraGreen % 510 - 255) / 255.0f
                                                 blue:abs(self.cameraBlue % 510 - 255) / 255.0f
                                                alpha:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
}

- (void)takePicture {
    CGRect imageFrame = CGRectMake(0, 0, 1024, 768);
    UIGraphicsBeginImageContextWithOptions(imageFrame.size, false, 0.0);
    [self.view.backgroundColor setFill];
    UIRectFill(imageFrame);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self.delegate imagePickerController:nil didFinishPickingMediaWithInfo:@{
            UIImagePickerControllerOriginalImage: image
    }];
}

#endif

@end