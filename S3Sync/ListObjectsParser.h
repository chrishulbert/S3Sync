//
//  ListObjectsParser.h
//  S3Sync
//
//  Created by Chris Hulbert on 4/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This parses the xml returned by the list objects call: http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGET.html

#import <Foundation/Foundation.h>

@interface ListObjectsParser : NSObject<NSXMLParserDelegate>

/// S3Object instances.
@property(nonatomic, readonly) NSMutableArray *objects;

/// YES if you need to make another call to get the rest.
@property(nonatomic, assign) BOOL isTruncated;

/// Parse the supplied xml.
+ (instancetype)parse:(NSXMLParser *)xml;

@end
