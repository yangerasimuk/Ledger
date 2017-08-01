//
//  YGEntity.m
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGEntity.h"

@implementation YGEntity

- (instancetype)initWithRowId:(NSInteger)rowId type:(YGEntityType)type name:(NSString *)name sum:(double)sum currencyId:(NSInteger)currencyId active:(BOOL)active activeFrom:(NSDate *)activeFrom activeTo:(NSDate *)activeTo attach:(BOOL)attach sort:(NSInteger)sort comment:(NSString *)comment{
    self = [super init];
    if(self){
        _rowId = rowId;
        _type = type;
        _name = [name copy];
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
    return [self initWithRowId:-1 type:type name:name sum:sum currencyId:currencyId active:YES activeFrom:[NSDate date] activeTo:nil attach:attach sort:sort comment:comment];
}

#pragma mark - Override system methods: Description, isEqual, hash

- (BOOL)isEqual:(id)object {
    
    if(self == object) return YES;
    
    if([self class] != [object class]) return NO;
    
    YGEntity *otherEntity = (YGEntity *)object;
    if(self.rowId != otherEntity.rowId)
        return NO;
    if(self.type != otherEntity.type)
        return NO;
    if(![self.name isEqualToString:otherEntity.name])
        return NO;
    return YES;
}

-(NSUInteger)hash {
    NSString *hashString = [NSString stringWithFormat:@"%ld:%ld:%@:%@", _type, _rowId, _name, _activeFrom];
    
    return [hashString hash];
    
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Entity. RowId:%ld, type:%ld, name:%@, sum:%.2f, currencyId:%ld, active:%ld activeFrom:%@, activeTo:%@, attach:%ld, sort:%ld, comment:%@", _rowId, _type, _name, _sum, _currencyId, (long)_active, _activeFrom, _activeTo, (long)_attach, _sort, _comment];
    
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    YGEntity *newEntity = [[YGEntity alloc] initWithRowId:_rowId type:_type name:_name sum:_sum currencyId:_currencyId active:_active activeFrom:_activeFrom activeTo:_activeTo attach:_attach sort:_sort comment:_comment];
        
    return newEntity;
}

NSString * NSStringFromEntityType(YGEntityType type) {
    if(type == YGEntityTypeNone)
        return @"None";
    else if(type == YGEntityTypeAccount)
        return @"Account";
    else if(type == YGEntityTypeDebt)
        return @"Debt";
    else if(type == YGEntityTypeCredit)
        return @"Credit";
    else
        return @"Unknown";
}

@end
