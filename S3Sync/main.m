//
//  main.m
//  S3Sync
//
//  Created by Chris Hulbert on 3/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonCrypto.h>

#import "AFAmazonS3Manager.h"

BOOL shouldKeepRunning = YES;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Get the config.
        NSData *configData = [NSData dataWithContentsOfFile:@"~/S3Sync.config.json".stringByExpandingTildeInPath];
        NSDictionary *configJson = [NSJSONSerialization JSONObjectWithData:configData options:0 error:nil];
        
        // Create the manager.
        AFAmazonS3Manager *s3Manager = [[AFAmazonS3Manager alloc] initWithAccessKeyID:configJson[@"AccessKeyID"]
                                                                               secret:configJson[@"Secret"]];
        // Not really needed below, but maybe it makes it faster.
        s3Manager.requestSerializer.region = configJson[@"Region"] ?: AFAmazonS3USStandardRegion;
        s3Manager.requestSerializer.bucket = configJson[@"Bucket"];
        
        
        // Get the file using url loading mechanisms to get the mime type.
        NSMutableURLRequest *fileRequest = [NSMutableURLRequest requestWithURL:[NSURL fileURLWithPath:@"/Users/chris/car.jpg"]];
        fileRequest.cachePolicy = NSURLCacheStorageNotAllowed;
        NSURLResponse *fileResponse = nil;
        NSError *fileError = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:fileRequest returningResponse:&fileResponse error:&fileError];
        
        // Get the md5 of it.
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        CC_MD5(data.bytes, (CC_LONG)data.length, md5Buffer);
        NSData *md5data = [NSData dataWithBytes:md5Buffer length:sizeof(md5Buffer)];
        NSString *base64Md5 = [md5data base64EncodedStringWithOptions:0];
        
        // Build the un-authed request.
        NSURL *url = [s3Manager.baseURL URLByAppendingPathComponent:@"somefolder/subfolder/car.jpg"];
        NSMutableURLRequest *originalRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        originalRequest.HTTPMethod = @"PUT";
        originalRequest.HTTPBody = data;
        [originalRequest setValue:base64Md5 forHTTPHeaderField:@"Content-MD5"];
        [originalRequest setValue:fileResponse.MIMEType forHTTPHeaderField:@"Content-Type"];
        
        // Sign it.
        NSURLRequest *request = [s3Manager.requestSerializer requestBySettingAuthorizationHeadersForRequest:originalRequest error:nil];
        
        AFHTTPRequestOperation *operation = [s3Manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Upload Complete");
            shouldKeepRunning = NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            shouldKeepRunning = NO;
        }];
        [s3Manager.operationQueue addOperation:operation];

        #warning TODO Would be nice to use the multipart upload (not multipart form!) if the file is >5MB:
        // http://docs.aws.amazon.com/AmazonS3/latest/API/mpUploadInitiate.html
        
        // Run the run loop.
        NSRunLoop *theRL = [NSRunLoop currentRunLoop];
        while (shouldKeepRunning && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    }
    return 0;
}
