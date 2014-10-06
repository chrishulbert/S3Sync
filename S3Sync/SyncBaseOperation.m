//
//  SyncBaseOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  The base class for operations, so they get the context.

#import "SyncBaseOperation.h"

#import "SyncContext.h"

@implementation SyncBaseOperation

- (id)initWithContext:(SyncContext *)context {
    if (self = [super init]) {
        _context = context;
    }
    return self;
}


@end
