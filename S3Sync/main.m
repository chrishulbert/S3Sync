//
//  main.m
//  S3Sync
//
//  Created by Chris Hulbert on 3/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SyncContext.h"
#import "ReadConfigOperation.h"
#import "ScanLocalFilesOperation.h"
#import "CreateS3ManagerOperation.h"
#import "GetObjectListOperation.h"
#import "FinishedOperation.h"
#import "ComparingOperation.h"
#import "EnqueueUploadsOperation.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        // Make the shared context.
        SyncContext *context = [[SyncContext alloc] init];
        
        // Make the operations.
        NSOperation *readConfig = [[ReadConfigOperation alloc] initWithContext:context];
        NSOperation *scanLocal = [[ScanLocalFilesOperation alloc] initWithContext:context dependencies:@[readConfig]];
        NSOperation *createS3 = [[CreateS3ManagerOperation alloc] initWithContext:context dependencies:@[readConfig]];
        NSOperation *getS3List = [[GetObjectListOperation alloc] initWithContext:context dependencies:@[createS3]];
        NSOperation *compare = [[ComparingOperation alloc] initWithContext:context dependencies:@[scanLocal, getS3List]];
        NSOperation *enqueue = [[EnqueueUploadsOperation alloc] initWithContext:context dependencies:@[compare]];

        // Start it all off!
        [context.queue addOperations:@[readConfig, scanLocal, createS3, getS3List, compare, enqueue]
                   waitUntilFinished:NO];
        
        // Run the run loop.
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        while (!context.shouldFinishRunning && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:.1]]);
    }
    return 0;
}
