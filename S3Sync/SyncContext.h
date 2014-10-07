//
//  SyncContext.h
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This maintains state for the syncing.

#import <Foundation/Foundation.h>

@class AFAmazonS3Manager;

@interface SyncContext : NSObject

@property(atomic, strong) NSOperationQueue *queue;
@property(atomic, strong) NSDictionary *config;
@property(atomic, strong) NSArray *localFiles;
@property(atomic, strong) NSArray *remoteFiles; // S3Object instances.
@property(atomic, strong) AFAmazonS3Manager *s3Manager;
@property(atomic, assign) BOOL shouldFinishRunning;

@end
