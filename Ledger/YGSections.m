//
//  YGSections.m
//  Ledger
//
//  Created by Ян on 16/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSections.h"
//#import "YGOperation.h"
//#import "YGSection.h"

@interface YGSections(){
    /// YGExpenses *_expenses;
    NSArray <YGOperation *> *_operations;
    
    /// for quick search in sectionsFromExpenses
    NSMutableArray <NSDate *> *_dates;
}
-(NSArray <YGSection*>*)sectionsFromOperations;
+(NSDate *)dayOfDate:(NSDate *)date;
@end

@implementation YGSections

-(instancetype)initWithOperations:(NSArray <YGOperation *> *)operations{
    if(self = [super init]){
        _operations = operations;
        
#warning Why mutable?
        _list = [[self sectionsFromOperations] mutableCopy];
    }
    return self;
}

-(NSArray <YGSection*>*)sectionsFromOperations{
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [_operations enumerateObjectsUsingBlock:^(YGOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDate *dayOfDate = [YGSections dayOfDate:obj.date];
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"date = %@", dayOfDate];
        
        if([result count] > 0){
            NSArray *secs = [result filteredArrayUsingPredicate:datePredicate];
            
            if([secs count] > 1){
                @throw [NSException exceptionWithName:@"-[YGSections sectionsFromOperations]" reason:@"More than one section for the date" userInfo:nil];
            }
            if([secs count] == 1){
                YGSection *s = secs[0];
                [s addOperation:obj];
            }
            else{
                NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:obj, nil];
                YGSection *s = [[YGSection alloc] initWithDate:dayOfDate operations:arr];
                [result addObject:s];
            }
        }
        else{
            NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:obj, nil];
            YGSection *s = [[YGSection alloc] initWithDate:dayOfDate operations:arr];
            [result addObject:s];
        }
    }];
    
    return result;
}

+ (NSDate *)dayOfDate:(NSDate *)date{
    
    NSDateFormatter *formatterFromDate = [[NSDateFormatter alloc] init];
    [formatterFromDate setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatterFromDate stringFromDate:date];
    
    NSDateFormatter *formatterToDate = [[NSDateFormatter alloc] init];
    [formatterToDate setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [formatterToDate dateFromString:stringFromDate];
    
    return dateFromString;
}

#pragma mark - Sort sections

- (void)sortSectionsByDate{
    [_list sortUsingComparator:^NSComparisonResult(YGSection *sec1, YGSection *sec2){
        if([sec1.date compare: sec2.date] == NSOrderedDescending)
            return NSOrderedAscending;
        else if([sec1.date compare:sec2.date] == NSOrderedAscending)
            return NSOrderedDescending;
        else
            return NSOrderedSame; // :)
    }];
}

@end
