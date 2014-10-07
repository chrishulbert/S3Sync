//
//  UploadOperation.h
//  S3Sync
//
//  Created by Chris Hulbert on 7/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This performs a basic upload operation (not a multipart one).

#import "SyncConcurrentOperation.h"

@class LocalFile;

@interface UploadOperation : SyncConcurrentOperation

/// The file to upload.
@property(nonatomic, strong) LocalFile *localFile;

@end
