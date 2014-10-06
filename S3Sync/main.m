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
#import "SyncContext.h"
#import "ReadConfigOperation.h"

BOOL shouldKeepRunning = YES;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        // Make the shared context.
        SyncContext *context = [[SyncContext alloc] init];
        
        // Make the operations.
        NSOperation *readConfig = [[ReadConfigOperation alloc] initWithContext:context];

        #warning TODO Make the queue, set up the dependencies, dont wait till finished, add one final block to say done.
//        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//        [queue addOperations:@[readConfig] waitUntilFinished:NO];
        
        // Find all local files.
        NSString *localFolder = [context.config[@"LocalFolder"] stringByExpandingTildeInPath];
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
        AFAmazonS3Manager *s3Manager = [[AFAmazonS3Manager alloc] initWithAccessKeyID:context.config[@"AccessKeyID"]
                                                                               secret:context.config[@"Secret"]];
        // Not really needed below, but maybe it makes it faster.
        s3Manager.requestSerializer.region = context.config[@"Region"] ?: AFAmazonS3USStandardRegion;
        s3Manager.requestSerializer.bucket = context.config[@"Bucket"];
        
        // Get the list of objects
        // TODO use marker to get > 1000 of them.
        NSLog(@"Getting object list from S3");
        [s3Manager GET:@"/" parameters:nil success:^(AFHTTPRequestOperation *operation, NSXMLParser *responseObject) {
            NSLog(@"Parsing objects");
            ListObjectsParser *listObjects = [ListObjectsParser parse:responseObject];
            NSLog(@"isTruncated: %@", listObjects.isTruncated ? @"Yes" : @"No");
            NSLog(@"objects[%lu]: %@", (unsigned long)listObjects.objects.count ,listObjects.objects);
            
            #warning TODO Do something if it's truncated.
            if (listObjects.isTruncated) {
                NSLog(@"Can't handle truncated yet!");
                exit(1);
            }
            
            // Compare now.
            NSMutableDictionary *s3ObjectIndex = [NSMutableDictionary dictionary];
            for (S3Object *object in listObjects.objects) {
                s3ObjectIndex[object.key] = object;
            }
            int filesSame=0, filesMissing=0, filesDiffSize=0, filesDiffHash=0;
            long long sizeOfWork=0;
            for (LocalFile *local in localFiles) {
                S3Object *remote = s3ObjectIndex[local.relativePath];
                if (!remote) {
                    NSLog(@"Remote file missing: %@", local.relativePath);
                    filesMissing++;
                    sizeOfWork += local.size;
                } else if (remote.size != local.size) {
                    NSLog(@"File sizes are different: %@; local: %lld; remote: %lld", local.relativePath, local.size, remote.size);
                    filesDiffSize++;
                    sizeOfWork += local.size;
                } else if (![remote.etag isEqualToString:local.md5Etag]) {
                    NSLog(@"Hashes are different: %@", local.relativePath);
                    filesDiffHash++;
                    sizeOfWork += local.size;
                } else {
                    NSLog(@"Files are the same: %@", local.relativePath);
                    filesSame++;
                }
            }
            NSLog(@"Same files: %d, Missing: %d; Diff size: %d; Diff hash: %d; Bytes to do: %lld", filesSame, filesMissing, filesDiffSize, filesDiffHash, sizeOfWork);
            
//            todo compare, show how many are different (lots!), how many match
            
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
