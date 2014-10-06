//
//  SyncConcurrentOperation.h
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  Subclass of SyncBaseOperation, for concurrent things. To use it, overwrite concurrentStart and call concurrentFinish when done.

#import "SyncBaseOperation.h"

@interface SyncConcurrentOperation : SyncBaseOperation

/// Override this (no need to call super) to start your code.
- (void)concurrentStart;

/// Call this when you're done.
- (void)concurrentFinish;

@end
