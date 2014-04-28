//
//  VBCaptionController.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/23/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCaptionController.h"
#import <AVFoundation/AVFoundation.h>
#import "VBInputSourceManager.h"
#import "VBFont.h"
#import "VBPubSub.h"
#import "VBCaptionDataSource.h"
#import "VBCaptionTableViewCell.h"
#import "VBCaptionDelegate.h"

@interface VBCaptionController () <UIGestureRecognizerDelegate>

@property (nonatomic) CGFloat lastCaptionPanOffsetY;
@property (nonatomic) CGFloat captionTableMinHeight;
@property (nonatomic) BOOL adjustingHeight;
@property (nonatomic) BOOL captionTableCollapsed;
@property (nonatomic) BOOL monitoringContentSize;
@property (nonatomic) VBCaptionDataSource *captionDataSource;
@property (nonatomic) VBCaptionDelegate *captionDelegate;

@property (nonatomic, strong) AVCaptureSession *cameraCaptureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *cameraCaptureOutput;

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (weak, nonatomic) UIView *activeCameraView;
@property (weak, nonatomic) IBOutlet UITableView *captionTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionTableHeightConstraint;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *captionTablePanRecognizer;

@property (nonatomic) VBUser *lastSource;
@property (nonatomic) FirebaseHandle userImageSubscription;

- (IBAction)onCaptionTablePan:(id)sender;
- (IBAction)onCaptionTableLongPress:(id)sender;

@end

@implementation VBCaptionController


- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    [self setupCaptionTable];
    [self addObservers];
    [self setupCameraCaptureSession];
    [self setupCameraCaptureOutput];
    [self updateCameraSource];
}

- (void)setupView
{
    self.monitoringContentSize = YES;
    self.captionTableMinHeight = self.captionTableHeightConstraint.constant;
    self.captionTableCollapsed = YES;
    self.captionTablePanRecognizer.delegate = self;
    [self renderRandomCameraBackgroundColor];
}

- (void)setupCaptionTable
{
    // colors
    self.captionTable.backgroundColor = [VBColor captionBarColor];
    self.captionTable.backgroundView = nil;

    // data source
    id name = @"CaptionCell";
    self.captionTable.dataSource = self.captionDataSource = [VBCaptionDataSource sourceWithCellReuseIdentifier:name];
    [self.captionTable registerNib:VBCaptionTableViewCell.nib forCellReuseIdentifier:name];
    
    self.captionTable.delegate = self.captionDelegate = [VBCaptionDelegate delegateWithDataSource:self.captionDataSource];

}

- (void)addObservers
{
    
    id center = [NSNotificationCenter defaultCenter];
    
    // change camera on caption source changes
    [center addObserverForName:VBUserEventSourceChanged
                        object:nil queue:nil usingBlock:^(NSNotification *notification) {
                            [self updateCameraSource];
                        }];
    
    // when sending captions, also send image captures
    [center addObserverForName:VBInputSourceManagerEventCaptionProcessing
                        object:nil queue:nil usingBlock:^(NSNotification *notification) {
                             [self captureAndPublishUserImage];
                        }];
    
    [self.captionDataSource observeUpdateWithBlock:^{
        [self.captionTable reloadData];
    }];
    
}

- (void)updateCameraSource
{
    if (self.lastSource)
        [VBPubSub unsubscribeFromUserImage:self.lastSource
                                    handle:self.userImageSubscription];
    
    // check for local sourcing
    self.lastSource = nil;
    VBUser *current = [VBUser currentUser];
    if (![current isNotListeningToSelf]) {
        self.activeCameraView = self.cameraView;
        return;
    }
    
    // otherwise, we're sourcing from another user
    self.lastSource = current.source;
    self.activeCameraView = self.cameraImageView;
    self.userImageSubscription = [VBPubSub subscribeToUserImageData:current.source success:^(NSData *imageData) {
        [self updateCameraImage:[[UIImage alloc] initWithData:imageData]];
    } failure:^(NSError *error) {
        [VBHUD showWithError:error];
    }];
    
}

- (void)updateCameraImage:(UIImage *)image
{
    [UIView transitionWithView:self.cameraImageView
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.cameraImageView.image = image;
                    } completion:nil];
}

- (void)setActiveCameraView:(UIView *)activeCameraView
{
    UIView *inactiveCameraView;
    if ([activeCameraView isEqual:self.cameraView])
        inactiveCameraView = self.cameraImageView;
    else
        inactiveCameraView = self.cameraView;
    _activeCameraView = activeCameraView;
    [UIView animateWithDuration:0.5 animations:^{
        [self updateActiveCameraViewAlpha];
        inactiveCameraView.alpha = 0;
    }];
}

- (void)captureAndPublishUserImage
{
    // don't publish image unless checked in
    VBUser *current = [VBUser currentUser];
    if (![current isCheckedIn]) return;

    [self captureUserImageWithCompletion:^(NSData *data) {
        [VBPubSub publishImageData:data user:current success:nil failure:^(NSError * error) {
            [VBHUD showWithError:error];
        }];
    }];
}

- (void)captureUserImageWithCompletion:(void(^)(NSData*))complete
{
    if (!self.cameraCaptureOutput) {
        complete([self synthesizeUserImageDataFromBackgroundColor]);
        return;
    }
    
    // get a handle to the connection from the video stream
    AVCaptureConnection *videoConnection;
    for (AVCaptureConnection *connection in self.cameraCaptureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    // capture the image from the video stream
    [self.cameraCaptureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        // convert the buffer into data in memory
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        complete(imageData);
    }];
    
}

- (NSData *)synthesizeUserImageDataFromBackgroundColor
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [self.cameraView.backgroundColor setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(image, 1);
}

- (void)setupCameraCaptureOutput
{
    if (self.cameraCaptureOutput)
        return;
    
    if (!self.cameraCaptureSession)
        return;
    
    // setup still image capture from camera
    self.cameraCaptureOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.cameraCaptureOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecJPEG}];
    [self.cameraCaptureSession addOutput:self.cameraCaptureOutput];
    
}

- (void)setupCameraCaptureSession
{
    if (self.cameraCaptureSession)
        return;
    
    // see if we have any cameras
    AVCaptureDevice *videoDevice;
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (videoDevices.count > 0) {
        // if so, see if we can get a front facing camera
        for (AVCaptureDevice *device in videoDevices){
            if (!device.position == AVCaptureDevicePositionFront) continue;
            videoDevice = device;
        }
        // if not, just settle for any camera
        if (!videoDevice)
            videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    // if no video device, just return
    if (!videoDevice)
        return;
    
    // if we have a device, try to get a handle for it
    NSError *error = nil;
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    // return on error
    if (error) {
        [VBHUD showWithError:error];
        return;
    }
    
    // now we can create our session object
    self.cameraCaptureSession = [[AVCaptureSession alloc] init];
    self.cameraCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    [self.cameraCaptureSession addInput:input];
    
    // and use it to add a camera preview to the controller
    AVCaptureVideoPreviewLayer *preview =
        [AVCaptureVideoPreviewLayer layerWithSession:self.cameraCaptureSession];
    preview.frame = self.cameraView.bounds;
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.cameraView.layer addSublayer:preview];
    
    // finally, we start the show
    [self.cameraCaptureSession startRunning];
    
}

- (void)renderRandomCameraBackgroundColor
{
    [UIView animateWithDuration:1.5 animations:^{
        self.cameraView.backgroundColor = [VBColor randomLightColor];
    }];
}

-(void)setCaptionTableCollapsed:(BOOL)captionTextViewCollapsed
{
    [self setCaptionTextViewCollapsed:captionTextViewCollapsed animatedWithDuration:0 velocity:0];
}

-(void)setCaptionTextViewCollapsed:(BOOL)captionTextViewCollapsed animatedWithDuration:(CGFloat)duration velocity:(CGFloat)velocity
{
    self.captionTableHeightConstraint.constant = (_captionTableCollapsed = captionTextViewCollapsed) ?
        self.captionTableMinHeight : self.view.frame.size.height;
    self.adjustingHeight = NO;
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:velocity
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view layoutIfNeeded];
                         [self updateActiveCameraViewAlpha];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             self.monitoringContentSize = self.captionTableCollapsed;
                             self.captionTable.scrollEnabled = YES;
                             self.adjustingHeight = NO;
                             [self updateActiveCameraViewAlpha];
                         }
                     }];
}

- (void)setAdjustingHeight:(BOOL)adjustingHeight
{
    id color = (_adjustingHeight = adjustingHeight) ? [VBColor separatorColor] : [VBColor captionBarColor];
    [UIView animateWithDuration:0.3 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ self.captionTable.backgroundColor = color; }
                     completion:nil];
}

- (CGFloat)captionTextViewBottomOffsetY
{
    CGSize containerSize = self.captionTable.bounds.size;
    CGSize contentSize   = self.captionTable.contentSize;
    return contentSize.height - containerSize.height;
}

- (void)scrollToLastCaptionWithAnimation:(BOOL)animation
{
    CGPoint currentOffset = self.captionTable.contentOffset;
    CGFloat offsetY = self.captionTextViewBottomOffsetY;
    [self.captionTable setContentOffset:CGPointMake(currentOffset.x, offsetY) animated:animation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))])
        [self scrollToLastCaptionWithAnimation:YES];
}

- (void)updateCaptionTextViewHeight:(CGFloat)heightDelta
{
    CGFloat requestedHeight = self.captionTableHeightConstraint.constant + heightDelta;
    CGFloat allowedHeight   = MIN(MAX(self.captionTableMinHeight, requestedHeight), self.view.frame.size.height);
    self.captionTableHeightConstraint.constant = allowedHeight;
    [self.captionTable layoutIfNeeded];
}

- (IBAction)onCaptionTableLongPress:(UILongPressGestureRecognizer *)sender {
    switch (sender.state) {
        default: break;
        case UIGestureRecognizerStateBegan:
            self.adjustingHeight = YES;
            break;
        case UIGestureRecognizerStateEnded:
            self.adjustingHeight = NO;
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (IBAction)onCaptionTablePan:(UIPanGestureRecognizer *)sender {
    
    if (!self.adjustingHeight && self.captionTable.scrollEnabled)
        return;
    
    CGPoint p;
    
    switch (sender.state) {
        default: break;
        case UIGestureRecognizerStateBegan:
            self.monitoringContentSize = NO;
            self.captionTable.scrollEnabled = NO;
            break;
        case UIGestureRecognizerStateChanged:
            p = [sender translationInView:self.view];
            [self updateCaptionTextViewHeight:self.lastCaptionPanOffsetY - p.y];
            [self updateActiveCameraViewAlpha];
            break;
        case UIGestureRecognizerStateEnded:
            p = [sender velocityInView:self.view];
            CGFloat duration = MIN(ABS(1500.0 / p.y), 1);
            CGFloat velocity = MIN(ABS(self.view.frame.size.height / p.y), 0.3);
            [self setCaptionTextViewCollapsed:(p.y > 0) animatedWithDuration:duration velocity:velocity];
            break;
    }
    
    self.lastCaptionPanOffsetY = p.y;
    
}

- (void)setMonitoringContentSize:(BOOL)monitoringContentSize
{
    if (monitoringContentSize == _monitoringContentSize) return;
    id keyPath = NSStringFromSelector(@selector(contentSize));
    if ((_monitoringContentSize = monitoringContentSize)) {
        [self.captionTable addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    } else {
        [self.captionTable removeObserver:self forKeyPath:keyPath];
    }
}

- (void)updateActiveCameraViewAlpha
{
    CGFloat range    = self.view.frame.size.height - self.captionTableMinHeight;
    CGFloat distance = self.captionTableHeightConstraint.constant - self.captionTableMinHeight;
    CGFloat percent  = distance / range;
    CGFloat alpha    = 1 - 0.5*percent;
    self.activeCameraView.alpha = alpha;
}

@end
