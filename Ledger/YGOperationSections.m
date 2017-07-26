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
}
-(NSArray <YGOperationSection*>*)sectionsFromOperations;
+(NSDate *)dayOfDate:(NSDate *)date;
@end

@implementation YGOperationSections

-(instancetype)initWithOperations:(NSArray <YGOperation *> *)operations{
    if(self = [super init]){
        
        _cm = [YGCategoryManager sharedInstance];
        _em = [YGEntityManager sharedInstance];
        _om = [YGOperationManager sharedInstance];
        _config = [YGTools config];
        
        _operations = operations;
        
#warning Why mutable?
        _list = [[self sectionsFromOperations] mutableCopy];
        
    }
    return self;
}


- (NSArray <YGOperationSection*>*)sectionsFromOperations {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [_operations enumerateObjectsUsingBlock:^(YGOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDate *dayOfDate = [YGOperationSections dayOfDate:obj.date];
        
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

    YGConfig *config = [YGTools config];
    BOOL hideDecimalFraction = [[config valueForKey:@"HideDecimalFractionInLists"] boolValue];
    
    static NSString *formatForIncomeNumbers;
    static NSString *formatForExpenseNumbers;
    static NSString *formatForEqualNumbers;
    
    if(hideDecimalFraction){
        formatForIncomeNumbers = @"+ %.f %@";
        formatForExpenseNumbers = @"- %.f %@";
        formatForEqualNumbers = @"= %.f %@";
    }
    else{
        formatForIncomeNumbers = @"+ %.2f %@";
        formatForExpenseNumbers = @"- %.2f %@";
        formatForEqualNumbers = @"= %.2f %@";
    }
    
    
    if(row.operation.type == YGOperationTypeExpense){
        
        //YGCategory *sourceCurrency = [_cm categoryById:row.operation.sourceCurrencyId];
        YGCategory *sourceCurrency = [_cm categoryById:row.operation.sourceCurrencyId type:YGCategoryTypeCurrency];
        
        row.sourceSum = [NSString stringWithFormat:formatForExpenseNumbers, row.operation.sourceSum, [sourceCurrency shorterName]];
        
        YGCategory *expenseCateogry = [_cm categoryById:row.operation.targetId type:YGCategoryTypeExpense];
        
        row.target = expenseCateogry.name;

    }
    else if(row.operation.type == YGOperationTypeIncome){
        
        //YGCategory *incomeSource = [_cm categoryById:row.operation.sourceId];
        YGCategory *incomeSource = [_cm categoryById:row.operation.sourceId type:YGCategoryTypeIncome];
        row.source = incomeSource.name;
        
        //YGCategory *targetCurrency = [_cm categoryById:row.operation.targetCurrencyId];
        YGCategory *targetCurrency = [_cm categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:formatForIncomeNumbers, row.operation.targetSum, [targetCurrency shorterName]];
                          
    }
    else if(row.operation.type == YGOperationTypeAccountActual){
        
        YGEntity *targetAccount = [_em entityById:row.operation.targetId type:YGEntityTypeAccount];
        
        row.target = targetAccount.name;
        //YGCategory *targetCurrency = [_cm categoryById:row.operation.targetCurrencyId];
        YGCategory *targetCurrency = [_cm categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:formatForEqualNumbers, row.operation.targetSum, [targetCurrency shorterName]];
        
    }
    else if(row.operation.type == YGOperationTypeTransfer){
        
        YGEntity *sourceAccount = [_em entityById:row.operation.sourceId type:YGEntityTypeAccount];
        row.source = sourceAccount.name;
        //YGCategory *sourceCurrency = [_cm categoryById:row.operation.sourceCurrencyId];
        YGCategory *sourceCurrency = [_cm categoryById:row.operation.sourceCurrencyId type:YGCategoryTypeCurrency];
        row.sourceSum = [NSString stringWithFormat:formatForExpenseNumbers, row.operation.sourceSum, [sourceCurrency shorterName]];;
        
        YGEntity *targetAccount = [_em entityById:row.operation.targetId type:YGEntityTypeAccount];
        row.target = targetAccount.name;

        //YGCategory *targetCurrency = [_cm categoryById:row.operation.targetCurrencyId];
        YGCategory *targetCurrency = [_cm categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:formatForIncomeNumbers, row.operation.targetSum, [targetCurrency shorterName]];
    }
}

@end
