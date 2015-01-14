//
//  ReadConfigOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This reads and parses the config.

#import "ReadConfigOperation.h"

#import "SyncContext.h"

@implementation ReadConfigOperation

- (void)main {
    // First look in the current folder.
    NSData *configData = [NSData dataWithContentsOfFile:@"_S3Sync.config.json"];
    // Fall back to the home folder.
    if (!configData) {
        configData = [NSData dataWithContentsOfFile:@"~/S3Sync.config.json".stringByExpandingTildeInPath];
    }
    self.context.config = [NSJSONSerialization JSONObjectWithData:configData options:0 error:nil];
}

@end
