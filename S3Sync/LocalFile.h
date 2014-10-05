//
//  LocalFile.h
//  S3Sync
//
//  Created by Chris Hulbert on 5/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This represents the properties of a local file when scanning.

#import <Foundation/Foundation.h>

@interface LocalFile : NSObject

@property(nonatomic, strong) NSString *relativePath; // Eg 'somefolder/subfolder/car.jpg' or 'atom.xml'.
@property(nonatomic, strong) NSString *fullPath; // Eg '/Users/Bob/somefolder/subfolder/car.jpg'.
@property(nonatomic, assign) long long size; // In bytes.
@property(nonatomic, strong) NSString *md5Base64; // Base64 encoded, eg 'yXkT+C/b29hrkDVUZHlLqg=='.
@property(nonatomic, strong) NSString *md5Etag; // ETag encoded, eg "d41d8cd98f00b204e9800998ecf8427e".

@end
