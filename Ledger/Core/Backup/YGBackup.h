//
//  YGBackup.h
//  Ledger
//
//  Created by Ян on 07/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGStorage.h"

@protocol YGStoraging;

@interface YGBackup : NSObject

@property (copy, nonatomic) NSString *name;
@property (weak, nonatomic) id <YGStoraging> storage;
@property (copy, nonatomic) NSString *lastOperation;
@property (copy, nonatomic) NSString *backupDate;
@property (copy, nonatomic) NSString *dbSize;

- (instancetype)initWithName:(NSString *)name storage:(id<YGStoraging>)storage lastOperation:(NSString *)lastOperation backupDate:(NSString *)backupDate dbSize:(NSString *)dbSize;

- (instancetype)initWithName:(NSString *)name storage:(id<YGStoraging>)storage;

@end

