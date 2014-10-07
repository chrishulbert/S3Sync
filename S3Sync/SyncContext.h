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

@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) NSDictionary *config;
@property(nonatomic, strong) NSArray *localFiles;
@property(nonatomic, strong) NSArray *remoteFiles;
@property(nonatomic, strong) AFAmazonS3Manager *s3Manager;

@end
