//
//  YGOperation.m
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperation.h"

@implementation YGOperation

- (instancetype)initWithRowId:(NSInteger)rowId type:(YGOperationType)type sourceId:(NSInteger)sourceId targetId:(NSInteger)targetId sourceSum:(double)sourceSum sourceCurrencyId:(NSInteger)sourceCurrencyId targetSum:(double)targetSum targetCurrencyId:(NSInteger)targetCurrencyId created:(NSDate *)created modified:(NSDate *)modified comment:(NSString *)comment{
    
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
        
        if(created)
            _created = [created copy];
        else
            @throw [NSException exceptionWithName:@"-[YGOperation initWithRowId: type:sourceId:targetId:sourceSum:sourceCurrencyId:targetSum:targetCurrencyId:date:comment:" reason:@"Created date of operation can not be null" userInfo:nil];
        
        if(modified)
            _modified = [modified copy];
        else
            @throw [NSException exceptionWithName:@"-[YGOperation initWithRowId: type:sourceId:targetId:sourceSum:sourceCurrencyId:targetSum:targetCurrencyId:date:comment:" reason:@"Modified date of operation can not be null" userInfo:nil];
    
        if(comment)
            _comment = [comment copy];
    }
    return self;
}

- (instancetype)initWithType:(YGOperationType)type sourceId:(NSInteger)sourceId targetId:(NSInteger)targetId sourceSum:(double)sourceSum sourceCurrencyId:(NSInteger)sourceCurrencyId targetSum:(double)targetSum targetCurrencyId:(NSInteger)targetCurrencyId created:(NSDate *)created modified:(NSDate *)modified comment:(NSString *)comment {
    
    return [self initWithRowId:-1 type:type sourceId:sourceId targetId:targetId sourceSum:sourceSum sourceCurrencyId:sourceCurrencyId targetSum:targetSum targetCurrencyId:targetCurrencyId created:created modified:modified comment:comment];
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"Operation. RowId: %ld, type: %ld, sourceId: %ld, targetId: %ld, sourceSum: %.f, sourceCurrencyId: %ld, targetSum: %.2f, targetCurrencyId: %ld, created: %@, modified: %@, comment: %@", (long)_rowId, (long)_type, (long)_sourceId, (long)_targetId, _sourceSum, (long)_sourceCurrencyId, _targetSum, (long)_targetCurrencyId, _created, _modified, _comment];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone{
    YGOperation *newOperation = [[YGOperation alloc] initWithRowId:_rowId type:_type sourceId:_sourceId targetId:_targetId sourceSum:_sourceSum sourceCurrencyId:_sourceCurrencyId targetSum:_targetSum targetCurrencyId:_targetCurrencyId created:_created modified:_modified comment:_comment];
    
    return newOperation;
}

#pragma mark - Override system methods: Description, isEqual, hash

- (BOOL)isEqual:(id)object {
    
    if(self == object) return YES;
    
    if([self class] != [object class]) return NO;
    
    YGOperation *otherOperation = (YGOperation *)object;
    if(self.rowId != otherOperation.rowId)
        return NO;
    if(self.type != otherOperation.type)
        return NO;
    if(self.sourceId != otherOperation.sourceId)
        return NO;
    if(self.targetId != otherOperation.targetId)
        return NO;
    if(self.sourceSum != otherOperation.sourceSum)
        return NO;
    if(self.targetSum != otherOperation.targetSum)
        return NO;

    return YES;
}

-(NSUInteger)hash {
    NSString *hashString = [NSString stringWithFormat:@"%ld:%ld:%ld:%f:%ld:%f:%@", _type, _rowId, _sourceId, _sourceSum, _targetId, _targetSum, _created];
    
    return [hashString hash];
}


@end
