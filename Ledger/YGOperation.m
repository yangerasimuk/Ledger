//
//  YGOperation.m
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperation.h"

@implementation YGOperation

- (instancetype)initWithRowId:(NSInteger)rowId type:(YGOperationType)type sourceId:(NSInteger)sourceId targetId:(NSInteger)targetId sourceSum:(double)sourceSum sourceCurrencyId:(NSInteger)sourceCurrencyId targetSum:(double)targetSum targetCurrencyId:(NSInteger)targetCurrencyId date:(NSDate *)date comment:(NSString *)comment{
    
    self = [super init];
    if(self){
        _rowId = rowId;
        _type = type;
        _sourceId = sourceId;
        _targetId = targetId;
        _sourceSum = sourceSum;
        _sourceCurrencyId = sourceCurrencyId;
        _targetSum = targetSum;
        _targetCurrencyId = targetCurrencyId;
        if(date)
            _date = [date copy];
        else
            @throw [NSException exceptionWithName:@"-[YGOperation initWithRowId: type:sourceId:targetId:sourceSum:sourceCurrencyId:targetSum:targetCurrencyId:date:comment:" reason:@"Date of operation can not be null" userInfo:nil];
    
        if(comment)
            _comment = [comment copy];
    }
    return self;
}

- (instancetype)initWithType:(YGOperationType)type sourceId:(NSInteger)sourceId targetId:(NSInteger)targetId sourceSum:(double)sourceSum sourceCurrencyId:(NSInteger)sourceCurrencyId targetSum:(double)targetSum targetCurrencyId:(NSInteger)targetCurrencyId date:(NSDate *)date comment:(NSString *)comment {
    
    return [self initWithRowId:-1 type:type sourceId:sourceId targetId:targetId sourceSum:sourceSum sourceCurrencyId:sourceCurrencyId targetSum:targetSum targetCurrencyId:targetCurrencyId date:date comment:comment];
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"Operation. RowId: %ld, type: %ld, sourceId: %ld, targetId: %ld, sourceSum: %.f, sourceCurrencyId: %ld, targetSum: %.2f, targetCurrencyId: %ld, date: %@, comment: %@", _rowId, _type, _sourceId, _targetId, _sourceSum, _sourceCurrencyId, _targetSum, _targetCurrencyId, _date, _comment];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone{
    YGOperation *newOperation = [[YGOperation alloc] initWithRowId:_rowId type:_type sourceId:_sourceId targetId:_targetId sourceSum:_sourceSum sourceCurrencyId:_sourceCurrencyId targetSum:_targetSum targetCurrencyId:_targetCurrencyId date:_date comment:_comment];
    
    return newOperation;
}

@end
