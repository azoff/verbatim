//
//  VBCaptionScreen.m
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCaptionScreen.h"

@interface VBCaptionScreen ()

@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@property (strong, nonatomic) PocketsphinxController *pocketsphinxController;
@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;

@end

@implementation VBCaptionScreen

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (_openEarsEventsObserver == nil)
		_openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	return _openEarsEventsObserver;
}

- (PocketsphinxController *)pocketsphinxController {
	if (_pocketsphinxController == nil)
		_pocketsphinxController = [[PocketsphinxController alloc] init];
	return _pocketsphinxController;
}

- (void)initOpenEar
{
    NSString *languageModelPath = [[NSBundle mainBundle] pathForResource:@"english.ngsl" ofType:@"DMP"];
    NSString *languageDictionaryPath = [[NSBundle mainBundle] pathForResource:@"english.ngsl" ofType:@"dic"];
    NSString *acousticModelPath = [AcousticModel pathToModel:@"AcousticModelEnglish"];
    
    [self.pocketsphinxController startRealtimeListeningWithLanguageModelAtPath:languageModelPath
                                                              dictionaryAtPath:languageDictionaryPath
                                                           acousticModelAtPath:acousticModelPath];
    
//    [self.pocketsphinxController startListeningWithLanguageModelAtPath:languageModelPath
//                                                      dictionaryAtPath:languageDictionaryPath
//                                                   acousticModelAtPath:acousticModelPath
//                                                   languageModelIsJSGF:NO];
    
    [self.openEarsEventsObserver setDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initOpenEar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)screen
{
    return [[self alloc] init];
}

# pragma mark - open ears events

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    self.captionLabel.text = [NSString stringWithFormat:@"... %@ ...", [hypothesis lowercaseString]];
}

- (void) pocketsphinxDidStartCalibration {
	self.captionLabel.text = @"Calibrating...";
}

- (void) pocketsphinxDidStartListening {
	if ([self.captionLabel.text isEqualToString:@"Calibrating..."])
        self.captionLabel.text = @"Listening...";
}

- (void) rapidEarsDidReceiveLiveSpeechHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore {
    self.captionLabel.text = [NSString stringWithFormat:@"... %@...", [hypothesis lowercaseString]];
}

- (void) rapidEarsDidReceiveFinishedSpeechHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore {
    self.captionLabel.text = [NSString stringWithFormat:@"... %@ ...", [hypothesis lowercaseString]];
}

- (void) rapidEarsDidDetectBeginningOfSpeech {
    self.captionLabel.text = @"...";
}

@end
