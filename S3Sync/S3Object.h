//
//  S3Object.h
//  S3Sync
//
//  Created by Chris Hulbert on 4/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This is an object returned by the ListObjectsParser.

#import <Foundation/Foundation.h>

@interface S3Object : NSObject

@property(nonatomic, strong) NSString *key; // Eg 'somefolder/subfolder/car.jpg'.
@property(nonatomic, strong) NSString *etag;
@property(nonatomic, assign) long long size; // In bytes.

@end
