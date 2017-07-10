//
//  YGCategory.m
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCategory.h"

@interface YGCategory()


@end

@implementation YGCategory

@dynamic isSaved;

- (instancetype)initWithRowId:(NSInteger)rowId categoryType:(YGCategoryType)type name:(NSString *)name active:(BOOL)active activeFrom:(NSDate *)activeFrom activeTo:(NSDate *)activeTo sort:(NSInteger)sort shortName:(NSString *)shortName symbol:(NSString *)symbol attach:(BOOL)attach parentId:(NSInteger)parentId comment:(NSString *)comment{
    
    self = [super init];
    if(self){
        
        _rowId = rowId > 0 ? rowId : -1;
        _type = type;
        _name = name != nil ? [name copy] : nil;
        _active = active;
        
        if(activeFrom)
            _activeFrom = [activeFrom copy];
        else
            @throw [NSException exceptionWithName:@"-YGCategory initWithRowId:categoryTypeId:parentId:name:active:activeFrom:activeTo:sort:shortName:symbol:attach:comment" reason:@"Category can not be created without activeFrom timestamp" userInfo:nil];
        
        _activeTo = activeTo != nil ? [activeTo copy] : nil;
        _sort = sort > 0 ? sort : 100;
        _shortName = shortName != nil ? [shortName copy] : nil;
        
        if(symbol && [symbol length] >= 1){
            unichar ch = [symbol characterAtIndex:0];
            _symbol = [NSString stringWithFormat:@"%C", ch];
        }
        else
            _symbol = nil;
        
        _attach = attach;
        _parentId = parentId > 0 ? parentId : -1; // -1 as nil
        _comment = comment != nil ? [comment copy] : nil;
        
    }
    return self;
}

- (instancetype)initWithType:(YGCategoryType)type name:(NSString *)name sort:(NSInteger)sort shortName:(NSString *)shortName symbol:(NSString *)symbol attach:(BOOL)attach parentId:(NSInteger)parentId comment:(NSString *)comment{
    
    return [self initWithRowId:-1 categoryType:type name:name active:YES activeFrom:[NSDate date] activeTo:nil sort:sort shortName:shortName symbol:symbol attach:attach parentId:parentId comment:comment];
}


/** 
 Is category saved in db or not.
 */
- (BOOL)isSaved{
    return (_rowId > 0) ? YES : NO;
}

- (NSString *)shorterName {
    if(self.type == YGCategoryTypeCurrency){
        if(self.symbol)
            return self.symbol;
        else if(self.shortName){
            return self.shortName;
        }
        else
            return @"?";
    }
    else{
        return nil;
    }
}

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone{
    YGCategory *newCategory = [[YGCategory alloc] initWithRowId:_rowId categoryType:_type name:_name active:_active activeFrom:_activeFrom activeTo:_activeTo sort:_sort shortName:_shortName symbol:_symbol attach:_attach parentId:_parentId comment:_comment];
    
    return newCategory;
}

@end