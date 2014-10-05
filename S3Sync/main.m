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
#import "ListObjectsParser.h"
#import "S3Object.h"
#import "LocalFile.h"
#import "NSData+Hex.h"

BOOL shouldKeepRunning = YES;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Get the config.
        NSData *configData = [NSData dataWithContentsOfFile:@"~/S3Sync.config.json".stringByExpandingTildeInPath];
        NSDictionary *configJson = [NSJSONSerialization JSONObjectWithData:configData options:0 error:nil];
        
        // Find all local files.
        NSString *localFolder = [configJson[@"LocalFolder"] stringByExpandingTildeInPath];
        NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:localFolder];
        NSMutableArray *localFiles = [NSMutableArray array];
        NSString *file;
        while ((file = [dirEnum nextObject])) {
            // Is it a DS_Store? We want to skip those.
            BOOL isDSStore = [file hasSuffix:@".DS_Store"];
            if (!isDSStore) {
                // Is it a directory? Also want to skip those.
                NSString *fullPath = [localFolder stringByAppendingPathComponent:file];
                BOOL isDirectory;
                [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory];
                if (!isDirectory) {
                    // Add it to the list. We *don't* get the md5 at this point, we get it later so we can show % progress.
                    LocalFile *localFile = [[LocalFile alloc] init];
                    localFile.size = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil].fileSize;
                    localFile.relativePath = file;
                    localFile.fullPath = fullPath;
                    [localFiles addObject:localFile];
                }
            }
        }

        // MD5 the local files.
        int index=0;
        for (LocalFile *localFile in localFiles) {
            NSData *localData = [NSData dataWithContentsOfFile:localFile.fullPath];
            unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
            CC_MD5(localData.bytes, (CC_LONG)localData.length, md5Buffer);
            NSData *md5data = [NSData dataWithBytes:md5Buffer length:sizeof(md5Buffer)];
            localFile.md5Base64 = [md5data base64EncodedStringWithOptions:0];
            localFile.md5Etag = [md5data lowercaseHexString];
            
            // Report progress.
            index++;
            if (index % 10 == 0) {
                NSLog(@"Hashing local files: %lu%%", index*100/localFiles.count);
            }
        }
        NSLog(@"Done hashing local files");
        
        NSLog(@"Local files: %@", localFiles);
        
        // Create the manager.
        AFAmazonS3Manager *s3Manager = [[AFAmazonS3Manager alloc] initWithAccessKeyID:configJson[@"AccessKeyID"]
                                                                               secret:configJson[@"Secret"]];
        // Not really needed below, but maybe it makes it faster.
        s3Manager.requestSerializer.region = configJson[@"Region"] ?: AFAmazonS3USStandardRegion;
        s3Manager.requestSerializer.bucket = configJson[@"Bucket"];
        
        // Get the list of objects
        // TODO use marker to get > 1000 of them.
        NSLog(@"Getting objects");
        [s3Manager GET:@"/" parameters:nil success:^(AFHTTPRequestOperation *operation, NSXMLParser *responseObject) {
            NSLog(@"Parsing objects");
            ListObjectsParser *listObjects = [ListObjectsParser parse:responseObject];
            NSLog(@"isTruncated: %@", listObjects.isTruncated ? @"Yes" : @"No");
            NSLog(@"objects[%lu]: %@", (unsigned long)listObjects.objects.count ,listObjects.objects);
            
            shouldKeepRunning = NO;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            shouldKeepRunning = NO;
        }];
        
        // Get the file using url loading mechanisms to get the mime type.
        NSMutableURLRequest *fileRequest = [NSMutableURLRequest requestWithURL:[NSURL fileURLWithPath:@"/Users/chris/car.jpg"]];
        fileRequest.cachePolicy = NSURLCacheStorageNotAllowed;
        NSURLResponse *fileResponse = nil;
        NSError *fileError = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:fileRequest returningResponse:&fileResponse error:&fileError];
        
        // Get the md5 of it.
        #warning TODO Use the one from localfile.
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

        // Upload it.
//        AFHTTPRequestOperation *operation = [s3Manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"Upload Complete");
////            shouldKeepRunning = NO;
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Error: %@", error);
////            shouldKeepRunning = NO;
//        }];
//        [s3Manager.operationQueue addOperation:operation];

        #warning TODO Would be nice to use the multipart upload (not multipart form!) if the file is >5MB:
        // http://docs.aws.amazon.com/AmazonS3/latest/API/mpUploadInitiate.html
        
        // Run the run loop.
        NSRunLoop *theRL = [NSRunLoop currentRunLoop];
        while (shouldKeepRunning && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    }
    return 0;
}
