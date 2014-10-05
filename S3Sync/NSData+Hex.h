//
//  NSData+Hex.h
//  S3Sync
//
//  Created by Chris Hulbert on 5/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  Convert data to a lowercase hex string, like an etag.

#import <Foundation/Foundation.h>

@interface NSData (Hex)

- (NSString *)lowercaseHexString;

@end
