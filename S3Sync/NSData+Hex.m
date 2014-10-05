//
//  NSData+Hex.m
//  S3Sync
//
//  Created by Chris Hulbert on 5/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  Convert data to a lowercase hex string, like an etag.

#import "NSData+Hex.h"

@implementation NSData (Hex)

- (NSString *)lowercaseHexString {
    NSMutableString *string = [NSMutableString stringWithCapacity:self.length*2];
    for (NSUInteger i=0; i<self.length; i++) {
        [string appendFormat:@"%02x", ((unsigned char *)self.bytes)[i]];
    }
    return [string copy];
}

@end
