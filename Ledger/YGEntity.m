//
//  YGEntity.m
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGEntity.h"

@implementation YGEntity

- (instancetype)initWithRowId:(NSInteger)rowId type:(YGEntityType)type name:(NSString *)name sum:(double)sum currencyId:(NSInteger)currencyId active:(BOOL)active created:(NSDate *)created modified:(NSDate *)modified attach:(BOOL)attach sort:(NSInteger)sort comment:(NSString *)comment uuid:(NSUUID *)uuid {
    
    self = [super init];
    if(self){
        _rowId = rowId;
        _type = type;
        _name = [name copy];
        _sum = sum;
        _currencyId = currencyId;
        _active = active;
        if(created)
            _created = [created copy];
        else
            @throw [NSException exceptionWithName:@"-[YGEntity initWithRowId:type:name:sum:currencyId:active:created:modified:attach:sort:comment:uuid:]" reason:@"Entity's created date can not be nil" userInfo:nil];
        if(modified)
            _modified = [modified copy];
        else
            @throw [NSException exceptionWithName:@"-[YGEntity initWithRowId:type:name:sum:currencyId:active:created:modified:attach:sort:comment:uuid:]" reason:@"Entity's modified date can not be nil" userInfo:nil];
        _attach = attach;
        _sort = sort;
        _comment = [comment copy];
        if(uuid)
            _uuid = [uuid copy];
        else
            @throw [NSException exceptionWithName:@"-[YGEntity initWithRowId:type:name:sum:currencyId:active:created:modified:attach:sort:comment:uuid:]" reason:@"Entity's UUID can not be nil" userInfo:nil];
    }
    return self;
}


- (instancetype)initWithType:(YGEntityType)type name:(NSString *)name sum:(double)sum currencyId:(NSInteger)currencyId attach:(BOOL)attach sort:(NSInteger)sort comment:(NSString *)comment {
    
    NSDate *now = [NSDate date];
    
    return [self initWithRowId:-1 type:type name:name sum:sum currencyId:currencyId active:YES created:now modified:now attach:attach sort:sort comment:comment uuid:[NSUUID UUID]];
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
    if(![self.uuid isEqual:otherEntity.uuid])
        return NO;

    return YES;
}


-(NSUInteger)hash {
    NSString *hashString = [NSString stringWithFormat:@"%ld:%ld:%@:%@:%@", (long)_type, (long)_rowId, _name, _created, _uuid];
    
    return [hashString hash];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"Entity. RowId:%ld, type:%ld, name:%@, sum:%.2f, currencyId:%ld, active:%ld created:%@, modified:%@, attach:%ld, sort:%ld, comment:%@, uuid:%@", (long)_rowId, (long)_type, _name, _sum, (long)_currencyId, (long)_active, _created, _modified, (long)_attach, (long)_sort, _comment, _uuid];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    
    YGEntity *newEntity = [[YGEntity alloc] initWithRowId:_rowId type:_type name:_name sum:_sum currencyId:_currencyId active:_active created:_created modified:_modified attach:_attach sort:_sort comment:_comment uuid:_uuid];
        
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
