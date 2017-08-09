//
//  YGOperation.h
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YGOperationType){
    YGOperationTypeIncome           = 1,
    YGOperationTypeExpense          = 2,
    YGOperationTypeAccountActual    = 3,
    YGOperationTypeTransfer         = 4,
    YGOperationTypeGetCredit        = 5,
    YGOperationTypeReturnCredit     = 6,
    YGOperationTypeGiveDebt         = 7,
    YGOperationTypeReturnDebt       = 8
};

@interface YGOperation : NSObject

@property NSInteger rowId;
@property YGOperationType type;
@property NSInteger sourceId;
@property NSInteger targetId;
@property double sourceSum;
@property NSInteger sourceCurrencyId;
@property double targetSum;
@property NSInteger targetCurrencyId;
@property NSDate *day;
@property NSDate *created;
@property NSDate *modified;
@property NSString *comment;


- (instancetype)initWithRowId:(NSInteger)rowId type:(YGOperationType)type sourceId:(NSInteger)sourceId targetId:(NSInteger)targetId sourceSum:(double)sourceSum sourceCurrencyId:(NSInteger)sourceCurrencyId targetSum:(double)targetSum targetCurrencyId:(NSInteger)targetCurrencyId day:(NSDate *)day created:(NSDate *)created modified:(NSDate *)modified comment:(NSString *)comment;

- (instancetype)initWithType:(YGOperationType)type sourceId:(NSInteger)sourceId targetId:(NSInteger)targetId sourceSum:(double)sourceSum sourceCurrencyId:(NSInteger)sourceCurrencyId targetSum:(double)targetSum targetCurrencyId:(NSInteger)targetCurrencyId day:(NSDate *)day created:(NSDate *)created modified:(NSDate *)modified comment:(NSString *)comment;


@end
