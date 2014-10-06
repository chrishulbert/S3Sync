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
    return [self initWithContext:context dependencies:nil];
}

- (id)initWithContext:(SyncContext *)context dependencies:(NSArray *)dependencies {
    if (self = [super init]) {
        _context = context;
        for (NSOperation *operation in dependencies) {
            [self addDependency:operation];
        }
    }
    return self;
}

@end
