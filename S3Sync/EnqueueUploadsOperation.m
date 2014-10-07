//
//  EnqueueUploadsOperation.m
//  S3Sync
//
//  Created by Chris Hulbert on 7/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This enqueues the uploads and the 'finished' operation.

#import "EnqueueUploadsOperation.h"

#import "FinishedOperation.h"
#import "UploadOperation.h"
#import "SyncContext.h"
#import "LocalFile.h"

@implementation EnqueueUploadsOperation

- (void)main {
    // The last operation that signifies that the app can finish.
    NSOperation *finished = [[FinishedOperation alloc] initWithContext:self.context];

    // Queue all the uploads.
    for (LocalFile *localFile in self.context.localFilesToUpload) {
        #warning TODO If it's a big file do a multipart upload.
        UploadOperation *upload = [[UploadOperation alloc] initWithContext:self.context];
        upload.localFile = localFile;
        [finished addDependency:upload]; // App can't finish until this is done.
        [self.context.queue addOperation:upload];
    }

    // Queue the 'finished' op to complete last.
    [self.context.queue addOperation:finished];
}

@end
