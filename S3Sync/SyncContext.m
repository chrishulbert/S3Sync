//
//  SyncContext.m
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This maintains state for the syncing.

#import "SyncContext.h"

@implementation SyncContext

- (id)init {
    if (self = [super init]) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

@end
