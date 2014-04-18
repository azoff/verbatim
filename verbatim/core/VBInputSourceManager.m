//
//  VBInputSourceManager.m
//  verbatim
//
//  Created by Nicolas Halper on 4/6/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBInputSourceManager.h"
#import "VBSpeechKit.h"
#import "VBPubSub.h"

// The SKRecognizer will cycle through these stages
enum RecordingStateTypes {
    RS_IDLE,
    RS_INITIAL,
    RS_RECORDING,
    RS_PROCESSING
};
typedef enum RecordingStateTypes RecordingStateTypes;

@interface VBInputSourceManager()<SpeechKitDelegate,SKRecognizerDelegate>

@property (strong,nonatomic) SKRecognizer *voice;
@property (assign,nonatomic) RecordingStateTypes voiceRecordingState;
@property (nonatomic,strong) VBPubSub *pubSub;
@property (nonatomic) VBUser *sourceUser;

@end

@implementation VBInputSourceManager

NSString *const VBInputSourceManagerEventCaptionReceived = @"VBInputSourceManagerUserNewCaptionNotification";

+ (instancetype)manager
{
    static id _manager = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        _manager = [[self alloc] init];
        [VBSpeechKit setupWithDelegate:_manager];
    });
    
    return _manager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.pubSub = [[VBPubSub alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(inputSourceDidChange:)
                                                     name:VBUserEventSourceChanged
                                                   object:nil];
    }
    return self;
}

- (void)inputSourceDidChange:(NSNotification *)notification
{
    self.sourceUser = notification.object;
    if ([self isSubscribedToOwnMicInput]) {
        [self.pubSub unsubscribeFromAllChannels];
    } else {
        NSString *channel = [self userChannelForUser:self.sourceUser];
        [self.pubSub subscribeOnlyToChannel:channel usingBlock:^(NSDictionary *data) {
            NSLog(@"got caption:[%@]",data[@"caption"]);
            [self postNotificationWithCaption:data[@"caption"] fromUser:self.sourceUser];
        }];
    }
}

- (void)startListening
{
    NSLog(@"VBInputSourceManager:startListening");
    
    if (self.voiceRecordingState == RS_IDLE) {
        
        self.voiceRecordingState = RS_INITIAL;
        
        // there are a few possible tweak options here, notably experimenting with
        // different detection types, which can be longer or shorter.
        self.voice = [[SKRecognizer alloc] initWithType:SKDictationRecognizerType
                                              detection:SKLongEndOfSpeechDetection
                                               language:@"en_US"
                                               delegate:self];
    } else {
        NSLog(@"APP BUG WARNING: this should only be called in an idle state.");
    }
    
}

-(NSString *)userChannelForUser:(VBUser *)user {
    if (user) {
        return [NSString stringWithFormat:@"User%@",user.foursquareID];
    } else {
        return @"UserAnon";
    }
}

-(BOOL)isSubscribedToOwnMicInput {
    
    // a user is subscribed to their own mic input if:
    // 1) the user is not listening to any other user
    // 2) the user is logged in and listening to their own user id
    
    VBUser *currentUser = VBUser.currentUser;
    
    if (!self.sourceUser)
        return YES;
    else if (currentUser)
        return [currentUser.foursquareID isEqualToString:self.sourceUser.foursquareID];
    else
        return NO;
}

-(void)postNotificationWithCaption:(NSString *)caption fromUser:(VBUser *)user {
    if (caption == nil) {
        NSLog(@"[WARNING] Invalid User or Caption sent to post notificaiton");
        return;
    }
    NSDictionary *userInfo;
    if (user) {
        userInfo = @{@"user":user, @"caption":caption};
    }
    else {
        userInfo = @{@"caption":caption};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:VBInputSourceManagerEventCaptionReceived object:self userInfo:userInfo];
}

#pragma mark SKRecognizerDelegate methods
-(void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    NSLog(@"VBInputSourceManager:recognizerDidBeginRecording");
    self.voiceRecordingState = RS_RECORDING;
    
}

-(void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    NSLog(@"VBInputSourceManager:recognizerDidFinishRecording");
    
    // TODO: at this stage we should get another recording going while this one is processing.
    self.voiceRecordingState = RS_PROCESSING;
}

-(void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"VBInputSourceManager:recognizer:didFinishWithResults for SpeechKit session [%@]:%@",[SpeechKit sessionID],results.results);
    
    self.voiceRecordingState = RS_IDLE;
    
    // the best result is stored as the first result of the results list.
    NSString *bestResult = @"[mumble mumble mumble]";
    if ([results.results count] > 0) {
        bestResult = [results firstResult];
    }
    
    // if we are listening to ourselves, post notification immediately after processing.
    if ([self isSubscribedToOwnMicInput]) {
        [self postNotificationWithCaption:bestResult fromUser:[VBUser currentUser]];
    }
    
    // if we are checked in, publish to our own user channel
    if ([VBUser currentUser]) {
        [self.pubSub publishToChannel:[self userChannelForUser:[VBUser currentUser]] Data:@{@"caption":bestResult}];
    }
    
    // For some reason we can't just run the listener again immediately.
    // I suspect we have to wait until the object is destroyed/disconnected on the listening server
    // so adding a delay here seems to help kick it into the next connection (but the delay has not been tuned yet)
    [self performSelector:@selector(startListening) withObject:nil afterDelay:1];
    
}

-(void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"VBInputSourceManager:recognizer:didFinishWithError for SpeechKit session[%@]:%@",[SpeechKit sessionID],error);
    self.voiceRecordingState = RS_IDLE;
}


@end
