//
//  ListObjectsParser.m
//  S3Sync
//
//  Created by Chris Hulbert on 4/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This parses the xml returned by the list objects call: http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGET.html

#import "ListObjectsParser.h"

#import "S3Object.h"

@implementation ListObjectsParser {
    BOOL _isInContents;
    NSString *_text;
    S3Object *_currentObject;
    NSCharacterSet *_quotes; // For trimming quotes.
}

+ (instancetype)parse:(NSXMLParser *)xml {
    ListObjectsParser *parser = [[self alloc] init];
    xml.delegate = parser;
    [xml parse];
    return parser;
}

#pragma mark - Private

- (id)init {
    if (self = [super init]) {
        _objects = [NSMutableArray array];
        _quotes = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    }
    return self;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"Contents"]) {
        _isInContents = YES;
        _currentObject = [[S3Object alloc] init];
    }
    _text = nil;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (_isInContents) {
        // In the inner area (contents).
        if ([elementName isEqualToString:@"Key"]) {
            _currentObject.key = _text;
        } else if ([elementName isEqualToString:@"ETag"]) {
            _currentObject.etag = [_text stringByTrimmingCharactersInSet:_quotes];
        } else if ([elementName isEqualToString:@"Size"]) {
            _currentObject.size = _text.longLongValue;
        } else if ([elementName isEqualToString:@"Contents"]) {
            [_objects addObject:_currentObject];
            _currentObject = nil;
            _isInContents = NO;
        }
    } else {
        // In the outer area.
        if ([elementName isEqualToString:@"IsTruncated"]) {
            _isTruncated = [_text isEqualToString:@"true"];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    _text = _text ? [_text stringByAppendingString:string] : string;
}

@end
