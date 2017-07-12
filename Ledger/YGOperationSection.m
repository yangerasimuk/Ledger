//
//  YGOperationSection.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationSection.h"
#import "YGOperation.h"
#import "YGOperationRow.h"
#import "YGOperationSectionHeader.h"
#import "YGTools.h"
#import "Define.h"

@interface YGOperationSection (){
    NSMutableArray <YGOperationRow *> *_operationRows;
}

+(NSString *)nameOfDateInHumanView:(NSDate *)date;

@end

@implementation YGOperationSection

@synthesize name = _name;

- (instancetype)initWithDate:(NSDate *)date operationRows:(NSMutableArray *)operationRows{
    if(self = [super init]){
        
        _date = [date copy];
        
        if(operationRows)
            _operationRows = operationRows;
        else
            _operationRows = [[NSMutableArray alloc] init];
        
        _headerView = [self cacheSection];
    }
    return self;
}

- (instancetype)initWithDate:(NSDate *)date{
    return [self initWithDate:date operationRows:nil];
}

// lazy
- (NSString *)name{
    if(!_name){
        
        _name = [YGTools humanViewShortWithTodayOfDay:_date];
    }
    return _name;
}

- (void)addOperationRow:(YGOperationRow *)operationRow{
    [_operationRows addObject:operationRow];
}


+ (NSString *)nameOfDateInHumanView:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru_RU"]];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    
    return [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
}

- (YGOperationSectionHeader *)cacheSection{
    
    YGOperationSectionHeader *headerView = [[YGOperationSectionHeader alloc] initWithSection:self];
    
    return headerView;
}

@end
