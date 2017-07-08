//
//  YGEntity.m
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGEntity.h"

@implementation YGEntity

- (instancetype)initWithRowId:(NSInteger)rowId type:(YGEntityType)type name:(NSString *)name ownerId:(NSInteger)ownerId sum:(double)sum currencyId:(NSInteger)currencyId active:(BOOL)active activeFrom:(NSDate *)activeFrom activeTo:(NSDate *)activeTo attach:(BOOL)attach sort:(NSInteger)sort comment:(NSString *)comment{
    self = [super init];
    if(self){
        _rowId = rowId;
        _type = type;
        _name = [name copy];
        if(ownerId == 0)
            _ownerId = -1;
        else
            _ownerId = ownerId;
        _sum = sum;
        _currencyId = currencyId;
        _active = active;
        if(activeFrom)
            _activeFrom = [activeFrom copy];
        else
            _activeFrom = nil;
        if(activeTo)
            _activeTo = [activeTo copy];
        else
            _activeTo = nil;
        _attach = attach;
        _sort = sort;
        _comment = [comment copy];
    }
    return self;
}

- (instancetype)initWithType:(YGEntityType)type name:(NSString *)name sum:(double)sum currencyId:(NSInteger)currencyId attach:(BOOL)attach sort:(NSInteger)sort comment:(NSString *)comment {
    return [self initWithRowId:-1 type:type name:name ownerId:-1 sum:sum currencyId:currencyId active:YES activeFrom:[NSDate date] activeTo:nil attach:attach sort:sort comment:comment];
}

#pragma mark - Description


- (NSString *)description {
    return [NSString stringWithFormat:@"Entity. RowId:%ld, type:%ld, name:%@, ownerId:%ld, sum:%.2f, currencyId:%ld, active:%ld activeFrom:%@, activeTo:%@, attach:%ld, sort:%ld, comment:%@", _rowId, _type, _name, _ownerId, _sum, _currencyId, (long)_active, _activeFrom, _activeTo, (long)_attach, _sort, _comment];
    
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    YGEntity *newEntity = [[YGEntity alloc] initWithRowId:_rowId type:_type name:_name ownerId:_ownerId sum:_sum currencyId:_currencyId active:_active activeFrom:_activeFrom activeTo:_activeTo attach:_attach sort:_sort comment:_comment];
        
    return newEntity;
}

@end
