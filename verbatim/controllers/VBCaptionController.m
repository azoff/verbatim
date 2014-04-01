//
//  VBCaptionScreen.m
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCaptionController.h"

// The SKRecognizer will cycle through these stages
enum RecordingStateTypes {
    RS_IDLE,
    RS_INITIAL,
    RS_RECORDING,
    RS_PROCESSING
};
typedef enum RecordingStateTypes RecordingStateTypes;

@interface VBCaptionController ()

@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordingStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *listenButton;
- (IBAction)onListenButton:(id)sender;

@property (strong,nonatomic) SKRecognizer *voice;
@property (assign,nonatomic) RecordingStateTypes voiceRecordingState;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSpeechKit];
    [self startListening];
}

- (void)setupSpeechKit {
    [VBSpeechKit setupWithDelegate:self];
    self.voiceRecordingState = RS_IDLE;
}

- (void)startListening
{
    NSLog(@"VBCaptionController:startListening");
    
    if (self.voiceRecordingState == RS_IDLE) {
        
        self.listenButton.hidden = YES;
        self.voiceRecordingState = RS_INITIAL;
        [self refreshDebugLabels];
        
        // there are a few possible tweak options here, notably experimenting with
        // different detection types, which can be longer or shorter.
        self.voice = [[SKRecognizer alloc] initWithType:SKDictationRecognizerType
                                              detection:SKLongEndOfSpeechDetection
                                               language:@"en_US"
                                               delegate:self];
    } else {
        NSLog(@"WARNING: this should only be called in an idle state.");
    }
    
}

- (void)refreshDebugLabels
{
    NSString *stateText;
    
    switch (self.voiceRecordingState) {
        case RS_IDLE:stateText = @"Idle"; break;
        case RS_INITIAL:stateText = @"Initializing"; break;
        case RS_RECORDING:stateText = @"Recording"; break;
        case RS_PROCESSING:stateText = @"Processing"; break;
    }
    self.recordingStateLabel.text = [NSString stringWithFormat:@"Voice:%@",stateText];
}


#pragma mark SKRecognizerDelegate methods
-(void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    self.voiceRecordingState = RS_RECORDING;
    [self refreshDebugLabels];
}

-(void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    self.voiceRecordingState = RS_PROCESSING;
    [self refreshDebugLabels];
}

-(void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"VBCaptionController:recognizer:didFinishWithResults for SpeechKit session [%@]:%@",[SpeechKit sessionID],results.results);
    
    
    self.voiceRecordingState = RS_IDLE;
    [self refreshDebugLabels];
    
    // the best result is stored as the first result of the results list.
    NSString *bestResult = @"[mumble mumble mumble]";
    if ([results.results count] > 0) {
        bestResult = [results firstResult];
    }
    
    self.captionLabel.text = bestResult;
    
    
    // BUG: for some reason, if I set it to immediatly start listening again, it fails to work and causes a memory leak.
    // whereas if you press the "listen" button, it will start re-recording fine. WTF!? Maybe the server-side needs a few moments
    // to re-initialize a connection without failing.
    //[self startListening];
    self.listenButton.hidden = NO;
}

-(void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"VBCaptionController:recognizer:didFinishWithError for SpeechKit session[%@]:%@",[SpeechKit sessionID],error);
    self.voiceRecordingState = RS_IDLE;
    [self refreshDebugLabels];
    
    self.listenButton.hidden = NO;
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

- (IBAction)onListenButton:(id)sender {
    [self startListening];
}
@end
