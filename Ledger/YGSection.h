//
//  YGSection.h
//  Ledger
//
//  Created by Ян on 16/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YGOperation;

@interface YGSection : NSObject

/// name of section in human view
@property (copy, nonatomic, readonly)NSString *name;

/// opertions of this section
@property (strong, nonatomic, readonly) NSArray <YGOperation *> *operations;

/// date in format 'yyyy-MM-dd'
@property NSDate *date;

- (instancetype)initWithDate:(NSDate *)date;
- (instancetype)initWithDate:(NSDate *)date operations:(NSMutableArray <YGOperation *>*)operations;
- (void)addOperation:(YGOperation *)operation;

@end
