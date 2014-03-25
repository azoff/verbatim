//
//  openear.m
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/AcousticModel.h>

int DISABLED_main(int argc, char * argv[])
{
    @autoreleasepool {
        NSString *ngslFileName = @"english.ngsl";
        NSString *ngslFilePath = [[NSBundle mainBundle] pathForResource:ngslFileName ofType:@"plist"];
        NSArray  *ngslWords    = [NSArray arrayWithContentsOfFile:ngslFilePath];
        
        LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
        NSError *err = [lmGenerator generateLanguageModelFromArray:ngslWords
                                                    withFilesNamed:ngslFileName
                                            forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
        
        NSDictionary *languageGeneratorResults = nil;
        
        if([err code] == noErr) {
            languageGeneratorResults = [err userInfo];
            NSLog(@"Model: %@", [languageGeneratorResults objectForKey:@"LMPath"]);
            NSLog(@"Dict: %@", [languageGeneratorResults objectForKey:@"DictionaryPath"]);
            return 0;
        } else {
            NSLog(@"Error: %@", [err localizedDescription]);
            return 0;
        }
    }
}
