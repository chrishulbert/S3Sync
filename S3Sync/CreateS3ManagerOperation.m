//
//  CreateS3ManagerOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This configures the s3 manager.

#import "CreateS3ManagerOperation.h"

#import "SyncContext.h"
#import "AFAmazonS3Manager.h"

@implementation CreateS3ManagerOperation

- (void)main {
    self.context.s3Manager = [[AFAmazonS3Manager alloc] initWithAccessKeyID:self.context.config[@"AccessKeyID"]
                                                                     secret:self.context.config[@"Secret"]];
    // Region isn't really needed, but maybe it can make it faster.
    self.context.s3Manager.requestSerializer.region = self.context.config[@"Region"] ?: AFAmazonS3USStandardRegion;
    self.context.s3Manager.requestSerializer.bucket = self.context.config[@"Bucket"];
}

@end
