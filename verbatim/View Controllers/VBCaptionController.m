//
//  VBCaptionScreen.m
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCaptionController.h"
#import "VBInputSourceManager.h"
#import "VBCheckinController.h"
#import "VBFont.h"
#import <AVFoundation/AVFoundation.h>


enum VBCaptionControllerPresentationModeType {
    PM_CAPTION_FULLTEXT,
    PM_CAPTION_CAMERA
};

typedef enum VBCaptionControllerPresentationModeType VBCaptionControllerPresentationModeType;

CGFloat const VBCaptionControllerSwipeToSwitchDistance = 100.0f;
CGFloat const VBCaptionControllerTransitionDistance = 50.0f;


@interface VBCaptionController ()

@property (strong,nonatomic) NSString *caption;
@property (assign,nonatomic) VBCaptionControllerPresentationModeType presentationMode;

@property (assign,nonatomic) CGPoint startPanPoint;
@property (nonatomic,strong) AVCaptureSession *cameraCaptureSession;

@property (strong,nonatomic) NSMutableArray *captions;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionsLabelAnimatedOverlay;

@property (weak, nonatomic) IBOutlet UIView *historyView;

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;

@property (strong,nonatomic) NSString *captionHistory;

- (IBAction)onPan:(UIPanGestureRecognizer *)panGestureRecognizer;

@end

@implementation VBCaptionController


// returns YES if a camera was detected and added, NO if not (for simulator)
- (BOOL)setupCameraCaptureSession {
    
    /*
     // add the following line below if we might want to capture a still frame from the camera
     // every now and then, e.g. for broadcast to listeners with caption
     AVCaptureOutput *output = [[AVCaptureStillImageOutput alloc] init];
    [session addOutput:output];*/
    
    // if we've already setup the cameraCaptureSession, let's return now as we only want
    // to do this once. This is also why it wasn't lazy instantiated.
    if (self.cameraCaptureSession) {
        return YES;
    }
    self.cameraCaptureSession = [[AVCaptureSession alloc] init];
    
    //Setup camera input
    NSArray *possibleDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (possibleDevices.count == 0) {
        // when in simulator just display an image.
        self.cameraImageView.image = [UIImage imageNamed:@"TigerTalk"];
        self.cameraImageView.hidden = NO;
        return NO;
    } else {
        // hide the image view
        self.cameraImageView.hidden = YES;
    }
    //You could check for front or back camera here, but for simplicity just grab the first device
    AVCaptureDevice *device = [possibleDevices objectAtIndex:0];
    NSError *error = nil;
    
    // create an input and add it to the session
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error]; //Handle errors
    if (error) {
        NSLog(@"VBCaptionController:addVideoInput: AVCaptureDeviceInput ERROR %@",error);
        return NO;
    }
    
    //set the session preset
    self.cameraCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto; //Or other preset supported by the input device
    [self.cameraCaptureSession addInput:input];
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.cameraCaptureSession];
    // Set the preview layer frame
    previewLayer.frame = self.cameraView.bounds;
    // make sure camera covers entire view
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // and add this layer to the camera view
    [self.cameraView.layer addSublayer:previewLayer];
    [self.cameraCaptureSession startRunning];
    return YES;
}

-(NSArray *)captions
{
    if (!_captions) {
        _captions = [NSMutableArray array];
    }
    return _captions;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.caption = @"";
    self.captionHistory = @"";
    self.captionLabel.text = @"Talk or select someone to listen to";
    self.captionsLabel.text = @"No history of captions yet!";
    
    [self setupCameraCaptureSession];
    
    // subscribe to channel for debug listening
    [[NSNotificationCenter defaultCenter]
     addObserverForName:VBInputSourceManagerEventCaptionReceived
     object:nil
     queue:nil
     usingBlock:^(NSNotification *notification) {
         NSLog(@"Caption controller received notification: %@",notification.userInfo[@"caption"]);
         self.caption = notification.userInfo[@"caption"];
     }];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.presentationMode = PM_CAPTION_CAMERA;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)setPresentationMode:(VBCaptionControllerPresentationModeType)presentationMode
{
    _presentationMode = presentationMode;
    
    if (self.presentationMode == PM_CAPTION_FULLTEXT) {
        self.cameraView.layer.opacity = 0;
        self.captionLabel.layer.opacity = 0;
        self.historyView.layer.opacity = 1;
        
        self.captionsLabelAnimatedOverlay.transform = CGAffineTransformIdentity;
        self.captionLabel.transform = CGAffineTransformMakeTranslation(0,-VBCaptionControllerTransitionDistance);
        
        //[self.cameraCaptureSession stopRunning];
    } else {
        self.historyView.layer.opacity = 0;
        self.captionLabel.layer.opacity = 1;
        
        // give a shadow to the caption for readability.
        CALayer *layer = self.captionLabel.layer;
        layer.shadowOpacity = 0.50;
        layer.shadowRadius = 5.0;
        layer.shadowOffset = (CGSize){.width=0.0,.height=0.0};
        
        self.cameraView.layer.opacity = 1;
        
        self.captionLabel.transform = CGAffineTransformIdentity;
        self.captionsLabelAnimatedOverlay.transform = CGAffineTransformMakeTranslation(0,-VBCaptionControllerTransitionDistance);
        
        //[self.cameraCaptureSession startRunning];
    }
}

-(NSString *)captionHistory
{
    if (!_captionHistory) {
        _captionHistory = @"";
    }
    return _captionHistory;
}

-(void)setCaption:(NSString *)caption
{
    _caption = caption;
    self.captionLabel.text = caption;
    self.captionLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.captions addObject:caption];
    
    NSInteger previousLength=[self.captionHistory length];
    NSInteger addToLength = [caption length]+1;
    
    self.captionHistory = [self.captionHistory stringByAppendingString:[NSString stringWithFormat:@"%@ ",caption]];
    NSInteger totalLength = [self.captionHistory length];
    
    NSMutableAttributedString *display = [[NSMutableAttributedString alloc] initWithString:self.captionHistory];
    NSMutableAttributedString *olddisplay = [[NSMutableAttributedString alloc] initWithString:self.captionHistory];
    
    UIColor *activeColor  = [VBColor activeColor];
    UIColor *regularColor = [VBColor translucsentTextColor];
    UIColor *hiddenColor  = [UIColor clearColor];
    UIFont *font          = [VBFont defaultFontWithSize:16];
    NSShadow *shadow      = [[NSShadow alloc] init];
    
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowColor:[UIColor grayColor]];
    [shadow setShadowOffset:CGSizeMake(0, 3)];
    
    [display addAttribute:NSFontAttributeName
                    value:font
                    range:NSMakeRange(0, totalLength)];
    
    [display addAttribute:NSForegroundColorAttributeName
                    value:activeColor
                    range:NSMakeRange(previousLength, addToLength)];
    
    [display addAttribute:NSShadowAttributeName
                    value:shadow
                    range:NSMakeRange(previousLength,addToLength)];
    
    [display addAttribute:NSForegroundColorAttributeName
                    value:regularColor
                    range:NSMakeRange(previousLength, addToLength)];
    
    [display addAttribute:NSForegroundColorAttributeName
                    value:hiddenColor
                    range:NSMakeRange(0, previousLength)];
    
    [olddisplay addAttribute:NSFontAttributeName
                       value:font
                       range:NSMakeRange(0, totalLength)];
    
    [olddisplay addAttribute:NSForegroundColorAttributeName
                       value:activeColor
                       range:NSMakeRange(previousLength, addToLength)];
    
    [olddisplay addAttribute:NSShadowAttributeName
                       value:shadow range:NSMakeRange(previousLength, addToLength)];
    
    [olddisplay addAttribute:NSForegroundColorAttributeName
                       value:hiddenColor
                       range:NSMakeRange(previousLength, addToLength)];
    
    [olddisplay addAttribute:NSForegroundColorAttributeName
                       value:regularColor
                       range:NSMakeRange(0, previousLength)];
    
    self.captionsLabel.attributedText = olddisplay;
    
    // put text to animate to into the captions overlay text
    //self.captionsLabelAnimatedOverlay.frame = self.captionsLabel.frame;
    self.captionsLabelAnimatedOverlay.attributedText = display;
    self.captionsLabelAnimatedOverlay.layer.opacity = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.captionsLabelAnimatedOverlay.layer.opacity = 1;
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPan:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint point = [panGestureRecognizer locationInView:self.view];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Start point: %f",point.y);
        self.startPanPoint = point;
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        // if we want to transition smoothly as we swipe, we can animate
        // the partial transitions here.
        CGFloat travelled = point.y - self.startPanPoint.y;
        CGFloat dest_perc = MIN(1.0,0.0 + ABS(travelled/VBCaptionControllerSwipeToSwitchDistance));
        NSLog(@"travelled: %f perc: %f",travelled,dest_perc);
        
        if (self.presentationMode == PM_CAPTION_CAMERA) {
            if (travelled > 0) {
                dest_perc = 0.0;
            }
            // fade the camera...
            self.cameraView.layer.opacity = 1 - dest_perc;
            self.captionLabel.layer.opacity = 1 - dest_perc;
            self.captionLabel.transform = CGAffineTransformMakeTranslation(0,-dest_perc * VBCaptionControllerTransitionDistance);
            self.captionsLabelAnimatedOverlay.transform = CGAffineTransformMakeTranslation(0,(1-dest_perc) * VBCaptionControllerTransitionDistance);
            self.historyView.layer.opacity = dest_perc;
        } else {
            if (travelled < 0) {
                dest_perc = 0.0;
            }
            self.cameraView.layer.opacity = dest_perc;
            self.captionLabel.layer.opacity = dest_perc;
            self.captionLabel.transform = CGAffineTransformMakeTranslation(0,-(1-dest_perc) * VBCaptionControllerTransitionDistance);
            self.captionsLabelAnimatedOverlay.transform = CGAffineTransformMakeTranslation(0,(dest_perc) * VBCaptionControllerTransitionDistance);
            
            self.historyView.layer.opacity = 1 - dest_perc;
        }
        
        //self.menuView.transform = CGAffineTransformMakeTranslation(point.x - self.startPanPoint.x, 0);
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            NSLog(@"animate transition to presentation mode");
            if (velocity.y<0) {
                self.presentationMode = PM_CAPTION_FULLTEXT;
            } else {
                self.presentationMode = PM_CAPTION_CAMERA;
            }

        } completion:^(BOOL finished) {
            NSLog(@"done");
        }];
    }

}
@end
