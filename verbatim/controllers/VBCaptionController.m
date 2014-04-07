//
//  VBCaptionScreen.m
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCaptionController.h"
#import "VBInputSourceManager.h"
#import <AVFoundation/AVFoundation.h>


@interface VBCaptionController ()

@property (strong,nonatomic) NSMutableArray *captions;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionsLabel;


@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (nonatomic,strong) AVCaptureSession *cameraCaptureSession;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
- (IBAction)onPan:(UIPanGestureRecognizer *)panGestureRecognizer;

@property (assign,nonatomic) BOOL menuOpen;
@property (assign,nonatomic) CGAffineTransform menuOriginTransform;
@property (assign,nonatomic) CGPoint startPanPoint;

@end

@implementation VBCaptionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


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
        // when in simulator just display a redColor (or maybe an image).
        self.cameraView.backgroundColor = [UIColor redColor];
        return NO;
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
    // and add this layer to the camera view
    [self.cameraView.layer addSublayer:previewLayer];
    [self.cameraCaptureSession startRunning];
    return YES;
}

- (NSArray *)captions
{
    if (!_captions) {
        _captions = [NSMutableArray array];
    }
    return _captions;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCameraCaptureSession];
    
    // subscribe to channel for debug listening
    [[NSNotificationCenter defaultCenter]
     addObserverForName:VBInputSourceManagerDidFinishWithResultsNotification
     object:nil
     queue:nil
     usingBlock:^(NSNotification *notification) {
         NSLog(@"Caption controller received notification: %@",notification.userInfo[@"best"]);
         self.caption = notification.userInfo[@"best"];
     }];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.presentationMode = PM_CAPTION_CAMERA;
    
}

-(void)setPresentationMode:(VBCaptionControllerPresentationModeType)presentationMode
{
    _presentationMode = presentationMode;
    
    if (self.presentationMode == PM_CAPTION_FULLTEXT) {
        self.captionsLabel.layer.opacity = 1;
        self.captionLabel.layer.opacity = 0;
        self.cameraView.layer.opacity = 0;
        [self.cameraCaptureSession stopRunning];
    } else {
        self.captionsLabel.layer.opacity = 0;
        self.captionLabel.layer.opacity = 1;
        
        // give a shadow to the caption for readability.
        CALayer *layer = self.captionLabel.layer;
        layer.shadowOpacity = 0.50;
        layer.shadowRadius = 5.0;
        layer.shadowOffset = (CGSize){.width=0.0,.height=0.0};
        
        self.cameraView.layer.opacity = 1;
        
        [self.cameraCaptureSession startRunning];
    }
}

-(void)setCaption:(NSString *)caption
{
    _caption = caption;
    self.captionLabel.text = caption;
    [self.captions addObject:caption];
    self.captionsLabel.text = [self.captionsLabel.text stringByAppendingString:[NSString stringWithFormat:@" %@",caption]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)controller
{
    return [[self alloc] init];
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
        CGFloat dest_perc = MIN(1.0,0.0 + ABS(travelled/200.0));
        NSLog(@"travelled: %f perc: %f",travelled,dest_perc);
        
        //self.menuView.transform = CGAffineTransformMakeTranslation(point.x - self.startPanPoint.x, 0);
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
        
        [UIView animateWithDuration:0.3 animations:^{
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
