//
//  SyncBaseOperation.h
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  The base class for operations, so they get the context.

#import <Foundation/Foundation.h>

@class SyncContext;

@interface SyncBaseOperation : NSOperation

@property(nonatomic, readonly) SyncContext *context;

- (id)initWithContext:(SyncContext *)context;

@end
