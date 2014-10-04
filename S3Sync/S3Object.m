//
//  S3Object.m
//  S3Sync
//
//  Created by Chris Hulbert on 4/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This is an object returned by the ListObjectsParser.

#import "S3Object.h"

@implementation S3Object

- (NSString *)description {
    return [NSString stringWithFormat:@"key: %@; etag: %@; size: %lld", _key, _etag, _size];
}

@end
