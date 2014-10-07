//
//  UploadOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 7/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This performs a basic upload operation (not a multipart one).

#warning TODO Would be nice to use the multipart upload (not multipart form!) if the file is >5MB:
// http://docs.aws.amazon.com/AmazonS3/latest/API/mpUploadInitiate.html

#import "UploadOperation.h"

#import "AFAmazonS3Manager.h"
#import "SyncContext.h"
#import "LocalFile.h"

@implementation UploadOperation

- (void)concurrentStart {
    
    // Get the file using url loading mechanisms to get the mime type.
    NSMutableURLRequest *fileRequest = [NSMutableURLRequest requestWithURL:[NSURL fileURLWithPath:_localFile.fullPath]];
    fileRequest.cachePolicy = NSURLCacheStorageNotAllowed;
    NSURLResponse *fileResponse = nil;
    NSError *fileError = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:fileRequest returningResponse:&fileResponse error:&fileError];

    // Build the un-authed request.
    NSURL *url = [self.context.s3Manager.baseURL URLByAppendingPathComponent:_localFile.relativePath];
    NSMutableURLRequest *originalRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    originalRequest.HTTPMethod = @"PUT";
    originalRequest.HTTPBody = data;
    [originalRequest setValue:_localFile.md5Base64 forHTTPHeaderField:@"Content-MD5"];
    [originalRequest setValue:fileResponse.MIMEType forHTTPHeaderField:@"Content-Type"];

    // Sign it.
    NSURLRequest *request = [self.context.s3Manager.requestSerializer requestBySettingAuthorizationHeadersForRequest:originalRequest error:nil];

    // Upload it.
    NSLog(@"Uploading %@ (%.1f%%)", _localFile.relativePath, _percentage*100);
    AFHTTPRequestOperation *operation = [self.context.s3Manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Uploaded %@", _localFile.relativePath);
        [self concurrentFinish];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error uploading %@: %@", _localFile.relativePath, error);
        [self concurrentFinish];
    }];
    [self.context.s3Manager.operationQueue addOperation:operation];
}

@end
