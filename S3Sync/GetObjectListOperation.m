//
//  GetObjectListOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This gets the list of objects from s3.

#import "GetObjectListOperation.h"

#import "SyncContext.h"
#import "AFAmazonS3Manager.h"
#import "ListObjectsParser.h"
#import "S3Object.h"

@implementation GetObjectListOperation

- (void)concurrentStart {
    [self getS3ListFromMarker:nil];
}

/// Marker is nil for the first fetch.
- (void)getS3ListFromMarker:(NSString *)marker {
    // Make the params.
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"max-keys"] = @100; // TODO remove
    if (marker) {
        params[@"marker"] = marker;
    }
    
    if (marker) {
        NSLog(@"Getting initial object list from S3");
    } else {
        NSLog(@"Getting object list from S3 from marker: %@", marker);
    }
    
    #warning TODO Expect 385 (inc ds store and folders)
    [self.context.s3Manager GET:@"/" parameters:params success:^(AFHTTPRequestOperation *operation, NSXMLParser *responseObject) {
        ListObjectsParser *listObjects = [ListObjectsParser parse:responseObject];
        
        // Progress report.
        NSLog(@"Got %lu objects; isTruncated: %@", listObjects.objects.count, listObjects.isTruncated ? @"Yes" : @"No");
        
        // Save  the files into the context.
        if (self.context.remoteFiles) { // Add it to existing files.
            NSMutableArray *joined = [self.context.remoteFiles mutableCopy];
            [joined addObjectsFromArray:listObjects.objects];
            self.context.remoteFiles = joined;
        } else {
            self.context.remoteFiles = listObjects.objects;
        }
        
        // Fetch more if necessary.
        if (listObjects.isTruncated) {
            S3Object *lastObject = listObjects.objects.lastObject;
            [self getS3ListFromMarker:lastObject.key];
        } else {
            [self concurrentFinish];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        exit(1);
    }];
}

@end
