//
//  ScanLocalFilesOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This scans for all the local files.

#import "ScanLocalFilesOperation.h"

#import <CommonCrypto/CommonCrypto.h>

#import "LocalFile.h"
#import "NSData+Hex.h"
#import "SyncContext.h"

@implementation ScanLocalFilesOperation

- (void)main {
    // Find all local files.
    NSString *localFolder = [self.context.config[@"LocalFolder"] stringByExpandingTildeInPath];
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
        if (index % 50 == 0) {
            NSLog(@"Hashing local files: %lu%%", index*100/localFiles.count);
        }
    }
    NSLog(@"Done hashing local files");
    
    // Save it to the context.
    self.context.localFiles = [localFiles copy];
}

@end
