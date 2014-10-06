//
//  SyncConcurrentOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  Subclass of SyncBaseOperation, for concurrent things. To use it, overwrite concurrentStart and call concurrentFinish when done.

#import "SyncConcurrentOperation.h"

@interface SyncConcurrentOperation()

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@end

@implementation SyncConcurrentOperation

- (void)start {
    self.executing = YES;
    [self concurrentStart];
}

- (void)concurrentStart {
    // Implement this in your subclass.
}

- (void)concurrentFinish {
    self.finished = YES;
    self.executing = NO;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

@end
