//
//  ComparingOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 7/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This compares the local and remote files and enqueues all the necessary upload operations.

#import "ComparingOperation.h"

#import "SyncContext.h"
#import "S3Object.h"
#import "LocalFile.h"

@implementation ComparingOperation

- (void)main {
    NSLog(@"Comparing files");
    
    // Index it for speed.
    NSMutableDictionary *s3ObjectIndex = [NSMutableDictionary dictionary];
    for (S3Object *object in self.context.remoteFiles) {
        s3ObjectIndex[object.key] = object;
    }
    
    // Compare them.
    NSMutableArray *localFilesToUpload = [NSMutableArray array];
    for (LocalFile *local in self.context.localFiles) {
        S3Object *remote = s3ObjectIndex[local.relativePath];
        BOOL same = remote && remote.size == local.size && [remote.etag isEqualToString:local.md5Etag];
        if (!same) {
            [localFilesToUpload addObject:local];
        }
    }
    
    NSLog(@"Finished comparing files");
}

@end
