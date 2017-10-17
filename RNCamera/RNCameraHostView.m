//
//  RNCamera.m
//  RNCamera
//
//  Created by Hank Brekke on 7/11/17.
//  Copyright © 2017 Hank Brekke. All rights reserved.
//

#import "RNCameraHostView.h"

#import <React/RCTTouchHandler.h>
#import <React/RCTUIManager.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>

@interface RNCameraHostView () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, assign) BOOL isPresented;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) RNCameraImagePickerController *imagePicker;
@property (nonatomic, strong) RCTTouchHandler *touchHandler;

@end

@implementation RNCameraHostView

RCT_NOT_IMPLEMENTED(- (instancetype)initWithFrame:(CGRect)frame)
RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder)

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.bridge = bridge;
        self.isPresented = NO;
        self.imagePicker = [RNCameraImagePickerController new];
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.delegate = self;
        self.touchHandler = [[RCTTouchHandler alloc] initWithBridge:bridge];
    }
    return self;
}

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex {
    RCTAssert(self.customView == nil, @"Camera view can only have one subview");
    [super insertReactSubview:subview atIndex:atIndex];
    [self.touchHandler attachToView:subview];
    self.imagePicker.cameraOverlayView = subview;
    self.imagePicker.showsCameraControls = NO;
    self.customView = subview;

    __weak typeof(self) weakSelf = self;
    self.imagePicker.boundsDidChangeBlock = ^(CGRect newBounds) {
        [weakSelf.bridge.uiManager setSize:newBounds.size forView:weakSelf.customView];
    };
}

- (void)removeReactSubview:(UIView *)subview {
    RCTAssert(subview == self.customView, @"Cannot remove view other than camera view");
    [super removeReactSubview:subview];
    [self.touchHandler detachFromView:subview];
    self.customView = nil;
    self.imagePicker.showsCameraControls = YES;
    self.imagePicker.boundsDidChangeBlock = nil;
}

- (void)didUpdateReactSubviews {
    // Do nothing, as subview (singular) is managed by `insertReactSubview:atIndex:`
}

- (void)didMoveToWindow {
    [super didMoveToWindow];

    if (!self.isPresented && self.window) {
        RCTAssert(self.reactViewController, @"Can't present image view controller without a presenting view controller");

        if ([self.animationType isEqualToString:@"fade"]) {
            self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        } else if ([self.animationType isEqualToString:@"slide"]) {
            self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        }

        [self.delegate presentModalHostView:self withViewController:self.imagePicker animated:[self _isAnimated]];
        self.isPresented = YES;
    }
}

- (void)_dismissViewController {
    if (self.isPresented) {
        [self.delegate dismissModalHostView:self withViewController:self.imagePicker animated:[self _isAnimated]];
        self.isPresented = NO;
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    if (self.isPresented && !self.superview) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _dismissViewController];
        });
    }
}

- (void)invalidate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _dismissViewController];
    });
}

- (BOOL)_isAnimated {
    return ![self.animationType isEqualToString:@"none"];
}

- (void)_sendCapturedImage:(NSString *)imagePath image:(UIImage *)image {
    NSNumber *width = nil;
    NSNumber *height = nil;
    if (image) {
        height = @(image.size.height);
        width = @(image.size.width);
    }

    self.onCapture(@{
            @"image": imagePath,
            @"width": RCTNullIfNil(width),
            @"height": RCTNullIfNil(height)
    });
}

- (void)setCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice {
    _cameraDevice = cameraDevice;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imagePicker setCameraDevice:cameraDevice];
    });
}

- (void)setCameraFlashMode:(UIImagePickerControllerCameraFlashMode)cameraFlashMode {
    _cameraFlashMode = cameraFlashMode;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imagePicker setCameraFlashMode:cameraFlashMode];
    });
}

#pragma mark - Exported methods

+ (void)checkFlashAvailableWithCameraDevice:(UIImagePickerControllerCameraDevice)device callback:(RCTResponseSenderBlock)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isFlashAvailable = [UIImagePickerController isFlashAvailableForCameraDevice:device];

        callback(@[[NSNull null], @(isFlashAvailable)]);
    });
}

- (void)capturePhoto {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imagePicker takePicture];
    });
}

#pragma mark - Image picker delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    NSURL *imageURL = info[UIImagePickerControllerReferenceURL];
    UIImage *image = info[UIImagePickerControllerOriginalImage];

    if (imageURL) {
        [self _sendCapturedImage:imageURL.absoluteString image:image];
        return;
    }

    NSDictionary *imageMetadata = info[UIImagePickerControllerMediaMetadata];

    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    imageURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@.jpg", [NSUUID UUID]] isDirectory:NO relativeToURL:documentsURL];

    CLLocationManager *locationManager = [CLLocationManager new];
    CLLocation *location = [locationManager location];
    NSMutableDictionary *newMetadata = [NSMutableDictionary dictionaryWithDictionary:imageMetadata];
    if (!newMetadata[(NSString *)kCGImagePropertyGPSDictionary] && location) {
        NSTimeZone      *timeZone   = [NSTimeZone timeZoneWithName:@"UTC"];
        NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:timeZone];
        [formatter setDateFormat:@"HH:mm:ss.SS"];

        NSDictionary *gpsDict = @{(NSString *)kCGImagePropertyGPSLatitude: @(fabs(location.coordinate.latitude)),
                (NSString *)kCGImagePropertyGPSLatitudeRef: ((location.coordinate.latitude >= 0) ? @"N" : @"S"),
                (NSString *)kCGImagePropertyGPSLongitude: @(fabs(location.coordinate.longitude)),
                (NSString *)kCGImagePropertyGPSLongitudeRef: ((location.coordinate.longitude >= 0) ? @"E" : @"W"),
                (NSString *)kCGImagePropertyGPSTimeStamp: [formatter stringFromDate:[location timestamp]],
                (NSString *)kCGImagePropertyGPSAltitude: @(fabs(location.altitude)),
        };

        newMetadata[(NSString *)kCGImagePropertyGPSDictionary] = gpsDict;
    }

    // Reference: http://sylvana.net/jpegcrop/exif_orientation.html
    int newOrientation;
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
            newOrientation = 1;
            break;

        case UIImageOrientationDown:
            newOrientation = 3;
            break;

        case UIImageOrientationLeft:
            newOrientation = 8;
            break;

        case UIImageOrientationRight:
            newOrientation = 6;
            break;

        case UIImageOrientationUpMirrored:
            newOrientation = 2;
            break;

        case UIImageOrientationDownMirrored:
            newOrientation = 4;
            break;

        case UIImageOrientationLeftMirrored:
            newOrientation = 5;
            break;

        case UIImageOrientationRightMirrored:
            newOrientation = 7;
            break;

        default:
            newOrientation = -1;
    }
    if (newOrientation != -1) {
        newMetadata[(NSString *)kCGImagePropertyOrientation] = @(newOrientation);
    }

    // create an imagesourceref
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) UIImageJPEGRepresentation(image, 0.8), NULL);

    // this is the type of image (e.g., public.jpeg)
    CFStringRef UTI = CGImageSourceGetType(source);

    // create a new data object and write the new image into it
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data, UTI, 1, NULL);
    if (!destination) {
        NSLog(@"Error: Could not create image destination");
    }
    // add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef) newMetadata);
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    if (!success) {
        NSLog(@"Error: Could not create data from image destination");
    }
    CFRelease(destination);
    CFRelease(source);

    [dest_data writeToURL:imageURL atomically:YES];

    [self _sendCapturedImage:imageURL.absoluteString image:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.onCancel(nil);
}

@end
