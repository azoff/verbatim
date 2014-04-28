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

@interface VBCaptionController () <UIGestureRecognizerDelegate>

@property (nonatomic) CGFloat lastCaptionPanOffsetY;
@property (nonatomic) CGFloat lastCaptionContentOffsetY;
@property (nonatomic) CGFloat captionTextViewMinHeight;
@property (nonatomic) NSMutableAttributedString *captionHistory;
@property (nonatomic) BOOL adjustingHeight;
@property (nonatomic) BOOL monitoringContentSize;
@property (nonatomic) BOOL captionTextViewCollapsed;
@property (nonatomic, strong) AVCaptureSession *cameraCaptureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *cameraCaptureOutput;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (weak, nonatomic) IBOutlet UIView *activeCameraView;
@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *captionTextViewPanRecognizer;
@property (nonatomic) VBUser *lastSource;
@property (nonatomic) FirebaseHandle userImageSubscription;

- (IBAction)onCaptionTextViewPan:(id)sender;
- (IBAction)onCaptionTextViewHold:(id)sender;

@end

@implementation VBCaptionController


- (id)init
{
    self = [super init];
    if (self)
        self.captionHistory = [[NSMutableAttributedString alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    [self addObservers];
    [self setupCameraCaptureSession];
    [self setupCameraCaptureOutput];
    [self updateCameraSource];
}

- (void)setupView
{
    self.captionTextViewMinHeight = self.captionTextView.frame.size.height;
    self.captionTextViewCollapsed = YES;
    self.captionTextViewPanRecognizer.delegate = self;
    [self renderRandomCameraBackgroundColor];
}

- (void)addObservers
{
    
    // append captions on input source manager updates
    id center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:VBInputSourceManagerEventCaptionReceived
                        object:nil queue:nil usingBlock:^(NSNotification *notification) {
                            [self appendCaption:notification.userInfo[@"caption"]];
                        }];
    
    // clear out captions on caption source changes
    [center addObserverForName:VBUserEventSourceChanged
                        object:nil queue:nil usingBlock:^(NSNotification *notification) {
                            [self clearCaptionHistory];
                            [self updateCameraSource];
                        }];
    
    // when sending captions, also send image captures
    [center addObserverForName:VBInputSourceManagerEventCaptionProcessing
                        object:nil queue:nil usingBlock:^(NSNotification *notification) {
                             [self captureAndPublishUserImage];
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

- (void)setMonitoringContentSize:(BOOL)monitoringContentSize
{
    if (monitoringContentSize == _monitoringContentSize) return;
    id keyPath = NSStringFromSelector(@selector(contentSize));
    if ((_monitoringContentSize = monitoringContentSize)) {
        [self.captionTextView addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    } else {
        [self.captionTextView removeObserver:self forKeyPath:keyPath];
    }
}

- (void)clearCaptionHistory
{
    [self.captionHistory deleteCharactersInRange:NSMakeRange(0, self.captionHistory.length)];
    [self renderCaptionHistory];
}

-(void)setCaptionTextViewCollapsed:(BOOL)captionTextViewCollapsed
{
    [self setCaptionTextViewCollapsed:captionTextViewCollapsed animatedWithDuration:0 velocity:0];
}

-(void)setCaptionTextViewCollapsed:(BOOL)captionTextViewCollapsed animatedWithDuration:(CGFloat)duration velocity:(CGFloat)velocity
{
    self.captionTextViewHeightConstraint.constant = (_captionTextViewCollapsed = captionTextViewCollapsed) ?
        self.captionTextViewMinHeight : self.view.frame.size.height;
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
                             self.monitoringContentSize = self.captionTextViewCollapsed;
                             self.captionTextView.scrollEnabled = YES;
                             self.adjustingHeight = NO;
                             [self updateActiveCameraViewAlpha];
                         }
                     }];
}

- (void)appendCaption:(NSString *)caption
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    id attributes = @{
      NSFontAttributeName: [VBFont defaultFontWithSize:17],
      NSForegroundColorAttributeName: [VBColor translucsentTextColor],
      NSParagraphStyleAttributeName: paragraphStyle
    };
    NSString *string = [NSString stringWithFormat:@"\n\n%@\n", caption];
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    [self.captionHistory appendAttributedString:text];
    [self renderCaptionHistory];
}

- (void)setAdjustingHeight:(BOOL)adjustingHeight
{
    void(^animation)(void);
    if ((_adjustingHeight = adjustingHeight))
        animation = ^{ self.captionTextView.backgroundColor = [VBColor separatorColor]; };
    else
        animation = ^{ self.captionTextView.backgroundColor = [VBColor captionBarColor]; };
    [UIView animateWithDuration:0.3 delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animation
                     completion:nil];
}

- (void)renderCaptionHistory
{
    self.lastCaptionContentOffsetY = self.captionTextView.contentOffset.y;
    self.captionTextView.attributedText = self.captionHistory;
    [self pegCaptionContentOffset];
}

- (void)pegCaptionContentOffset
{
    CGPoint currentOffset = self.captionTextView.contentOffset;
    self.captionTextView.contentOffset = CGPointMake(currentOffset.x, self.lastCaptionContentOffsetY);
}

- (CGFloat)captionTextViewBottomOffsetY
{
    CGSize containerSize = self.captionTextView.bounds.size;
    CGSize contentSize   = self.captionTextView.contentSize;
    return contentSize.height - containerSize.height;
}

- (void)scrollToLastCaptionWithAnimation:(BOOL)animation
{
    if (animation) [self pegCaptionContentOffset];
    CGPoint currentOffset = self.captionTextView.contentOffset;
    CGFloat offsetY = self.captionTextViewBottomOffsetY;
    [self.captionTextView setContentOffset:CGPointMake(currentOffset.x, offsetY) animated:animation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))])
        [self scrollToLastCaptionWithAnimation:YES];
}

- (void)updateCaptionTextViewHeight:(CGFloat)heightDelta
{
    CGFloat requestedHeight = self.captionTextViewHeightConstraint.constant + heightDelta;
    CGFloat allowedHeight   = MIN(MAX(self.captionTextViewMinHeight, requestedHeight), self.view.frame.size.height);
    self.captionTextViewHeightConstraint.constant = allowedHeight;
    [self.view layoutIfNeeded];
}

- (IBAction)onCaptionTextViewHold:(UILongPressGestureRecognizer *)sender {
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

- (IBAction)onCaptionTextViewPan:(UIPanGestureRecognizer *)sender {
    
    if (!self.adjustingHeight && self.captionTextView.scrollEnabled)
        return;
    
    CGPoint p;
    
    switch (sender.state) {
        default: break;
        case UIGestureRecognizerStateBegan:
            self.monitoringContentSize = NO;
            self.captionTextView.scrollEnabled = NO;
            break;
        case UIGestureRecognizerStateChanged:
            p = [sender translationInView:self.view];
            [self updateCaptionTextViewHeight:self.lastCaptionContentOffsetY - p.y];
            [self updateActiveCameraViewAlpha];
            break;
        case UIGestureRecognizerStateEnded:
            p = [sender velocityInView:self.view];
            CGFloat duration = MIN(ABS(1500.0 / p.y), 1);
            CGFloat velocity = MIN(ABS(self.view.frame.size.height / p.y), 0.3);
            [self setCaptionTextViewCollapsed:(p.y > 0) animatedWithDuration:duration velocity:velocity];
            break;
    }
    
    self.lastCaptionContentOffsetY = p.y;
    
}

- (void)updateActiveCameraViewAlpha
{
    CGFloat range    = self.view.frame.size.height - self.captionTextViewMinHeight;
    CGFloat distance = self.captionTextViewHeightConstraint.constant - self.captionTextViewMinHeight;
    CGFloat percent  = distance / range;
    CGFloat alpha    = 1 - 0.5*percent;
    self.activeCameraView.alpha = alpha;
}

@end
