//
//  FinishedOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 7/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This sets the context's 'done' flag.

#import "FinishedOperation.h"

#import "SyncContext.h"

@implementation FinishedOperation

- (void)main {
    self.context.shouldFinishRunning = YES;
}

@end
