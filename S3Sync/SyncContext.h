//
//  SyncContext.h
//  S3Sync
//
//  Created by Chris Hulbert on 6/10/2014.
//  Copyright (c) 2014 Chris Hulbert. All rights reserved.
//
//  This maintains state for the syncing.

#import <Foundation/Foundation.h>

@interface SyncContext : NSObject

@property(nonatomic, strong) NSDictionary *config;

@end
