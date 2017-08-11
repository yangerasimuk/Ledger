//
//  YGOperationSections.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationSections.h"
#import "YGOperationRow.h"

#import "YGOperationManager.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGEntity.h"
#import "YGCategory.h"

#import "YGTools.h"
#import "YGConfig.h"


@interface YGOperationSections(){
    /// YGExpenses *_expenses;
    NSArray <YGOperation *> *_operations;
    
    /// for quick search in sectionsFromExpenses
    NSMutableArray <NSDate *> *_dates;
    
    YGCategoryManager *_cm;
    YGEntityManager *_em;
    YGOperationManager *_om;
    YGConfig *_config;
    
    BOOL p_hideDecimalFraction;
}
@end

@implementation YGOperationSections

-(instancetype)initWithOperations:(NSArray <YGOperation *> *)operations{
    if(self = [super init]){
        
        _cm = [YGCategoryManager sharedInstance];
        _em = [YGEntityManager sharedInstance];
        _om = [YGOperationManager sharedInstance];
        _config = [YGTools config];
        
        _operations = operations;
        
        _list = [[self sectionsFromOperations] mutableCopy];
        
    }
    return self;
}


- (NSArray <YGOperationSection*>*)sectionsFromOperations {
    
    YGConfig *config = [YGTools config];
    p_hideDecimalFraction = [[config valueForKey:@"HideDecimalFractionInLists"] boolValue];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [_operations enumerateObjectsUsingBlock:^(YGOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //@autoreleasepool {
        
        NSDate *dayOfDate = [YGOperationSections dayOfDate:obj.day];
        
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"date = %@", dayOfDate];
        
        if([result count] > 0){
            NSArray *secs = [result filteredArrayUsingPredicate:datePredicate];
            
            if([secs count] > 1){
                @throw [NSException exceptionWithName:@"-[YGSections sectionsFromOperations]" reason:@"More than one section for the date" userInfo:nil];
            }
            if([secs count] == 1){
                YGOperationSection *s = secs[0];
                
                // create YGOperationRow from obj
                // set YGOperationRow properties
                // add to section array
                YGOperationRow *row = [[YGOperationRow alloc] initWithOperation:obj];
                [self cacheRow:row];
                [s addOperationRow:row];
            }
            else{
                
                // create YGOperationRow from obj
                // set YGOperationRow properties
                // add to section array
                YGOperationRow *row = [[YGOperationRow alloc] initWithOperation:obj];
                [self cacheRow:row];
                
                NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:row, nil];
                YGOperationSection *s = [[YGOperationSection alloc] initWithDate:dayOfDate operationRows:arr];
                [result addObject:s];
            }
        }
        else{
            // create YGOperationRow from obj
            // set YGOperationRow properties
            // add to section array
            YGOperationRow *row = [[YGOperationRow alloc] initWithOperation:obj];
            [self cacheRow:row];
            
            NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:row, nil];
            YGOperationSection *s = [[YGOperationSection alloc] initWithDate:dayOfDate operationRows:arr];
            [result addObject:s];
        }
            
        //}// delete
    }];
    
    [self sortSectionsByDate];
    
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
    [_list sortUsingComparator:^NSComparisonResult(YGOperationSection *sec1, YGOperationSection *sec2){
        if([sec1.date compare: sec2.date] == NSOrderedDescending)
            return NSOrderedAscending;
        else if([sec1.date compare:sec2.date] == NSOrderedAscending)
            return NSOrderedDescending;
        else
            return NSOrderedSame; // :)
    }];
}

#pragma mark - Prepare cache for operation row

- (void)cacheRow:(YGOperationRow *)row {
    
    if(row.operation.type == YGOperationTypeExpense){
        
        YGCategory *sourceCurrency = [_cm categoryById:row.operation.sourceCurrencyId type:YGCategoryTypeCurrency];
        
        row.sourceSum = [NSString stringWithFormat:@"- %@ %@", [YGTools stringCurrencyFromDouble:row.operation.sourceSum hideDecimalFraction:p_hideDecimalFraction], [sourceCurrency shorterName]];
        
        // crutch
        NSInteger lengthMax = [YGTools lengthCharachtersForTableView] - [row.sourceSum length];
        
        YGCategory *expenseCategory = [_cm categoryById:row.operation.targetId type:YGCategoryTypeExpense];
        
        row.target = [YGTools stringContainString:expenseCategory.name lengthMax:lengthMax];

    }
    else if(row.operation.type == YGOperationTypeIncome){
        
        YGCategory *targetCurrency = [_cm categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"+ %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        
        // crutch
        NSInteger lengthMax = [YGTools lengthCharachtersForTableView] - [row.targetSum length];
        
        YGCategory *incomeSource = [_cm categoryById:row.operation.sourceId type:YGCategoryTypeIncome];
        row.source = [YGTools stringContainString:incomeSource.name lengthMax:lengthMax];
    }
    else if(row.operation.type == YGOperationTypeAccountActual){
        
        YGCategory *targetCurrency = [_cm categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"= %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        // crutch
        NSInteger lengthMax = [YGTools lengthCharachtersForTableView] - [row.targetSum length];
        
        YGEntity *targetAccount = [_em entityById:row.operation.targetId type:YGEntityTypeAccount];
        row.target = [YGTools stringContainString:targetAccount.name lengthMax:lengthMax];
    }
    else if(row.operation.type == YGOperationTypeTransfer){
        
        YGCategory *sourceCurrency = [_cm categoryById:row.operation.sourceCurrencyId type:YGCategoryTypeCurrency];
        row.sourceSum = [NSString stringWithFormat:@"- %@ %@", [YGTools stringCurrencyFromDouble:row.operation.sourceSum hideDecimalFraction:p_hideDecimalFraction], [sourceCurrency shorterName]];;
        
        // crutch
        NSInteger lengthMaxSource = [YGTools lengthCharachtersForTableView] - [row.sourceSum length] + 1;
        
        YGEntity *sourceAccount = [_em entityById:row.operation.sourceId type:YGEntityTypeAccount];
        row.source = [YGTools stringContainString:sourceAccount.name lengthMax:lengthMaxSource];

        //
        
        YGCategory *targetCurrency = [_cm categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"+ %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        // crutch
        NSInteger lengthMaxTarget = [YGTools lengthCharachtersForTableView] - [row.targetSum length] + 1;
        
        YGEntity *targetAccount = [_em entityById:row.operation.targetId type:YGEntityTypeAccount];
        row.target = [YGTools stringContainString:targetAccount.name lengthMax:lengthMaxTarget];
    }
}

@end
