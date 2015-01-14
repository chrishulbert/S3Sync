//
//  SyncConcurrentOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  Subclass of SyncBaseOperation, for concurrent things. To use it, overwrite concurrentStart and call concurrentFinish when done.

#import "SyncConcurrentOperation.h"

@implementation SyncConcurrentOperation {
    BOOL _finished;
    BOOL _executing;
}

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

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isConcurrent {
    return YES;
}

@end
