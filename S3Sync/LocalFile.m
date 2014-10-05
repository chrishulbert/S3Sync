//
//  LocalFile.m
//  S3Sync
//
//  Created by Chris Hulbert on 5/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This represents the properties of a local file when scanning.

#import "LocalFile.h"

@implementation LocalFile

- (NSString *)description {
    return [NSString stringWithFormat:@"relativePath: %@; md5Base64: %@; _md5Etag: %@; size: %lld", _relativePath, _md5Base64, _md5Etag, _size];
}

@end
