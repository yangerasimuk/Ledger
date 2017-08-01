//
//  YGCategory.h
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YGCategoryType){
    YGCategoryTypeCurrency          = 1,
    YGCategoryTypeExpense           = 2,
    YGCategoryTypeIncome            = 3,
    YGCategoryTypeCreditorOrDebtor  = 4,
    YGCategoryTypeTag               = 5
};

NSString *NSStringFromCategoryType(YGCategoryType type);

@interface YGCategory : NSObject <NSCopying>

/**
 Base init for Category.
 */
- (instancetype)initWithRowId:(NSInteger)rowId categoryType:(YGCategoryType)type name:(NSString *)name active:(BOOL)active activeFrom:(NSDate *)activeFrom activeTo:(NSDate *)activeTo sort:(NSInteger)sort symbol:(NSString *)symbol attach:(BOOL)attach parentId:(NSInteger)parentId comment:(NSString *)comment;

/**
 Init for new currency.
 */
- (instancetype)initWithType:(YGCategoryType)type name:(NSString *)name sort:(NSInteger)sort symbol:(NSString *)symbol attach:(BOOL)attach parentId:(NSInteger)parentId comment:(NSString *)comment;

- (NSString *)shorterName;

@property (assign, nonatomic) NSInteger rowId;
@property (assign, nonatomic, readonly) YGCategoryType type;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic, getter=isActive) BOOL active;
@property (copy, nonatomic, readonly) NSDate *activeFrom;
@property (copy, nonatomic) NSDate *activeTo;
@property (assign, nonatomic) NSInteger sort;
@property (copy, nonatomic) NSString *symbol;
@property (assign, nonatomic, getter=isAttach) BOOL attach;
@property (assign, nonatomic) NSInteger parentId;
@property (copy, nonatomic) NSString *comment;

/// dynamic
@property (assign, nonatomic, readonly) BOOL isSaved;

@end
