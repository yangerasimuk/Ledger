//
//  YGSection.m
//  Ledger
//
//  Created by Ян on 16/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSection.h"
#import "YGOperation.h"

@interface YGSection (){
    NSMutableArray <YGOperation *> *_operations;
}

+(NSString *)nameOfDateInHumanView:(NSDate *)date;

@end

@implementation YGSection

@synthesize name = _name;

- (instancetype)initWithDate:(NSDate *)date operations:(NSMutableArray *)operations{
    if(self = [super init]){
        
        _date = [date copy];
        
        if(operations)
            _operations = operations;
        else
            _operations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithDate:(NSDate *)date{
    return [self initWithDate:date operations:nil];
}

// lazy
- (NSString *)name{
    if(!_name){
        _name = [YGSection nameOfDateInHumanView:_date];
    }
    return _name;
}

- (void)addOperation:(YGOperation *)operation{
    [_operations addObject:operation];
}


+ (NSString *)nameOfDateInHumanView:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru_RU"]];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    
    return [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
}

@end
