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


@interface VBInputSourceManager ()

@property (nonatomic) FirebaseHandle pubSubHandle;
@property (nonatomic) VBUser *lastSource;

@end

@implementation VBInputSourceManager

NSString *const VBInputSourceManagerEventCaptionReceived = @"VBInputSourceManagerUserNewCaptionNotification";
NSString *const VBInputSourceManagerEventCaptionProcessing = @"VBInputSourceManagerEventCaptionProcessing";

+ (instancetype)manager
{
    static id _manager = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}


- (void)startListening
{
    [[VBSpeechKit kit] startListeningWithBlock:^(SKRecognition *recognition) {
        id center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:VBInputSourceManagerEventCaptionProcessing object:self userInfo:nil];
        [self processRecognitionResults:recognition.results];
    }];
}

- (void)stopListening
{
    [[VBSpeechKit kit] stopListening];
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeInputSource)
                                                     name:VBUserEventSourceChanged
                                                   object:nil];
        [self didChangeInputSource];
    }
    return self;
}

- (void)didChangeInputSource
{
    if (self.lastSource) {
        [VBPubSub unsubscribeFromUser:self.lastSource handle:self.pubSubHandle];
        self.lastSource = nil;
    }
    
    VBUser *user = [VBUser currentUser];
    if ([user isNotListeningToSelf]) {
        self.pubSubHandle = [VBPubSub subscribeToUserCaptionAdditions:user.source success:^(NSString *caption) {
            self.lastSource = user.source;
            [self postCaption:caption];
        } failure:^(NSError *error) {
            [VBHUD showWithError:error];
        }];
    }
    
}

-(void)postCaption:(NSString *)caption {
    if (caption == nil) return;
    id userInfo = @{ @"caption": caption };
    id center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:VBInputSourceManagerEventCaptionReceived object:self userInfo:userInfo];
}

-(void)processRecognitionResults:(NSArray *)results
{
    if (results.count <= 0) return;
    id caption = results.firstObject;
    if (caption == nil) return;
    id current = [VBUser currentUser];
    if (!current || [current isListeningToSelf])
        [self postCaption:caption];
    if ([current isCheckedIn])
        [VBPubSub publishNewCaption:caption fromUser:current success:nil failure:^(NSError *error) {
            [VBHUD showWithError:error];
        }];
}

@end
