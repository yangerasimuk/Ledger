//
//  YGEntity.h
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YGEntityType) {
    YGEntityTypeNone    = 0, // using for select all entities
    YGEntityTypeAccount = 1,
    YGEntityTypeDebt    = 2,
    YGEntityTypeCredit  = 3
};

NSString * NSStringFromEntityType(YGEntityType type);

@interface YGEntity : NSObject

@property NSInteger rowId;
@property YGEntityType type;
@property NSString *name;
@property double sum;
@property NSInteger currencyId;
@property (getter=isActive) BOOL active;
@property NSDate *created;
@property NSDate *modified;
@property (assign, nonatomic, getter=isAttach) BOOL attach;
@property NSInteger sort;
@property NSString *comment;
@property NSUUID *uuid;

- (instancetype)initWithRowId:(NSInteger)rowId type:(YGEntityType)type name:(NSString *)name sum:(double)sum currencyId:(NSInteger)currencyId active:(BOOL)active created:(NSDate *)created modified:(NSDate *)modified attach:(BOOL)attach sort:(NSInteger)sort comment:(NSString *)comment uuid:(NSUUID *)uuid;

- (instancetype)initWithType:(YGEntityType)type name:(NSString *)name sum:(double)sum currencyId:(NSInteger)currencyId attach:(BOOL)attach sort:(NSInteger)sort comment:(NSString *)comment;

@end