//
//  YGOperationSectionManager.m
//  Ledger
//
//  Created by Ян on 04.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationSectionManager.h"
#import "YGOperationRow.h"

#import "YGOperationManager.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGEntity.h"
#import "YGCategory.h"

#import "YGTools.h"
#import "YGConfig.h"

@interface YGOperationSectionManager(){

    YGCategoryManager *p_categoryManager;
    YGEntityManager *p_entityManager;
    YGOperationManager *p_operationManager;

    NSArray <YGOperation *> *p_operations;
    /// for quick search in sectionsFromExpenses
    NSMutableArray <NSDate *> *_dates;

    YGConfig *p_config;
    NSInteger p_widthView; // CGFloat?
    BOOL p_hideDecimalFraction;
}
@end

@implementation YGOperationSectionManager

static NSInteger const kWidthOfMarginIndents = 45;

#pragma mark - sharedInstanse & init

+ (instancetype)sharedInstance{
    static YGOperationSectionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YGOperationSectionManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if(self){
        
        p_categoryManager = [YGCategoryManager sharedInstance];
        p_entityManager = [YGEntityManager sharedInstance];
        p_operationManager = [YGOperationManager sharedInstance];
        p_operationManager.sectionDelegate = self;
        p_config = [YGTools config];
        
        // width of view must be set befor calculate of strings
        p_widthView = (NSInteger)[UIScreen mainScreen].bounds.size.width;
        
        [self makeSections];
    }
    return self;
}

/**
 Called from constructor and from outside, when reload operation list
 */
- (void)makeSections {
    p_operations = p_operationManager.listOperations;
    _sections = [[self sectionsFromOperations] mutableCopy];
    [self sortSectionsByDate];
}

- (NSArray <YGOperationSection*>*)sectionsFromOperations {
    
    YGConfig *config = [YGTools config];
    p_hideDecimalFraction = [[config valueForKey:@"HideDecimalFractionInLists"] boolValue];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [p_operations enumerateObjectsUsingBlock:^(YGOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDate *dayOfDate = [YGOperationSectionManager dayOfDate:obj.day];
        
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
            } else {
                
                // create YGOperationRow from obj
                // set YGOperationRow properties
                // add to section array
                YGOperationRow *row = [[YGOperationRow alloc] initWithOperation:obj];
                [self cacheRow:row];
                
                NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:row, nil];
                YGOperationSection *s = [[YGOperationSection alloc] initWithDate:dayOfDate operationRows:arr];
                [result addObject:s];
            }
        } else {
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
    [_sections sortUsingComparator:^NSComparisonResult(YGOperationSection *sec1, YGOperationSection *sec2){
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
        
        YGCategory *sourceCurrency = [p_categoryManager categoryById:row.operation.sourceCurrencyId type:YGCategoryTypeCurrency];
        
        row.sourceSum = [NSString stringWithFormat:@"- %@ %@", [YGTools stringCurrencyFromDouble:row.operation.sourceSum hideDecimalFraction:p_hideDecimalFraction], [sourceCurrency shorterName]];
        
        YGCategory *expenseCategory = [p_categoryManager categoryById:row.operation.targetId type:YGCategoryTypeExpense];
        
        NSInteger widthSum = [YGTools widthForContentString:row.sourceSum];
        NSInteger widthName = [YGTools widthForContentString:expenseCategory.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:expenseCategory.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.target = expenseCategory.name;
        
    }
    else if(row.operation.type == YGOperationTypeIncome){
        
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"+ %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGCategory *incomeSource = [p_categoryManager categoryById:row.operation.sourceId type:YGCategoryTypeIncome];
        
        NSInteger widthSum = [YGTools widthForContentString:row.targetSum];
        NSInteger widthName = [YGTools widthForContentString:incomeSource.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.source = [YGTools stringForContentString:incomeSource.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.source = incomeSource.name;
    }
    else if(row.operation.type == YGOperationTypeAccountActual){
        
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"= %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGEntity *targetAccount = [p_entityManager entityById:row.operation.targetId type:YGEntityTypeAccount];
        
        NSInteger widthSum = [YGTools widthForContentString:row.targetSum];
        NSInteger widthName = [YGTools widthForContentString:targetAccount.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:targetAccount.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.target = targetAccount.name;
    }
    else if(row.operation.type == YGOperationTypeTransfer){
        
        // source
        YGCategory *sourceCurrency = [p_categoryManager categoryById:row.operation.sourceCurrencyId type:YGCategoryTypeCurrency];
        row.sourceSum = [NSString stringWithFormat:@"- %@ %@", [YGTools stringCurrencyFromDouble:row.operation.sourceSum hideDecimalFraction:p_hideDecimalFraction], [sourceCurrency shorterName]];
        
        YGEntity *sourceAccount = [p_entityManager entityById:row.operation.sourceId type:YGEntityTypeAccount];
        
        NSInteger widthSourceSum = [YGTools widthForContentString:row.sourceSum];
        NSInteger widthSourceName = [YGTools widthForContentString:sourceAccount.name];
        
        if(widthSourceName > (p_widthView - widthSourceSum - kWidthOfMarginIndents))
            row.source = [YGTools stringForContentString:sourceAccount.name holdInWidth:(p_widthView - widthSourceSum - kWidthOfMarginIndents)];
        else
            row.source = sourceAccount.name;
        
        // target
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"+ %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGEntity *targetAccount = [p_entityManager entityById:row.operation.targetId type:YGEntityTypeAccount];
        
        NSInteger widthTargetSum = [YGTools widthForContentString:row.sourceSum];
        NSInteger widthTargetName = [YGTools widthForContentString:targetAccount.name];
        
        if(widthTargetName > (p_widthView - widthTargetSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:targetAccount.name holdInWidth:(p_widthView - widthTargetSum - kWidthOfMarginIndents)];
        else
            row.target = targetAccount.name;
    }
}

#pragma mark - OperationSectionProtocol

- (void)addOperation:(YGOperation *)operation {
    
    YGOperationRow *row = [[YGOperationRow alloc] initWithOperation:operation];
    [self cacheRow:row];
    
    // Находим секцию для операции, если нет - создаем и вставляем в список секций
    NSDate *day = [YGOperationSectionManager dayOfDate:operation.day];
    YGOperationSection *section = [self sectionWithDate:day];
    if (section) {
        [section addOperationRow:row];
    } else {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:row, nil];
        [self addSection:[[YGOperationSection alloc] initWithDate:day operationRows:arr]];
    }    
}

- (void)updateOperation:(YGOperation *)oldOperation withNew:(YGOperation *)newOperation {
    
//#ifdef DEBUG
//    NSLog(@"YGOperationSectionMananger.updateOperation:withNew:");
//#endif
    
    // New or exist section
    if ([oldOperation.day compare:newOperation.day] == NSOrderedSame) {
//#ifdef DEBUG
//        NSLog(@"");
//#endif
        YGOperationSection *section = [self sectionWithDate:oldOperation.day];
        
//#ifdef DEBUG
//        NSLog(@"Finded section: \n%@", [section description]);
//#endif
        
        NSMutableArray <YGOperationRow *> *rows = [section.operationRows mutableCopy];
        NSInteger index = [rows indexOfObjectPassingTest:^BOOL(YGOperationRow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (oldOperation.rowId == obj.operation.rowId)
                return YES;
            else
                return NO;
        }];
        
//#ifdef DEBUG
//        NSLog(@"Finded index: %ld", (long)index);
//        NSLog(@"Operation on index: %@", rows[index].operation);
//        NSLog(@"New operation: %@", newOperation);
//#endif
        
        rows[index].operation = [newOperation copy];
        [self cacheRow:rows[index]];
        [section setOperationRows:rows];
    } else {
//#ifdef DEBUG
//        NSLog(@"");
//#endif
        [self removeOperation:oldOperation];
        [self addOperation:newOperation];
    }
}

- (void)removeOperation:(YGOperation *)operation {
    
    YGOperationSection *section = [self sectionWithDate:operation.day];
    
    // find index of operation
    NSInteger index = [section.operationRows indexOfObjectPassingTest:^BOOL(YGOperationRow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (operation.rowId == obj.operation.rowId)
            return YES;
        else
            return NO;
    }];
    
    // temp mutableArray
    NSMutableArray <YGOperationRow *> *rows = [section.operationRows mutableCopy];
    [rows removeObjectAtIndex:index];
    
    // update section rows
    [section setOperationRows:rows];
    
    // remove section without rows
    if ([section.operationRows count] == 0) {
        NSInteger index = [_sections indexOfObject:section];
        [_sections removeObjectAtIndex:index];
    }
}

#pragma mark - Tools for update cache

- (YGOperationSection *)sectionWithDate:(NSDate *)date {
    // Need becouse date add +3 hours :)
    NSDate *day = [YGOperationSectionManager dayOfDate:date];
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"date = %@", day];
    return [[self.sections filteredArrayUsingPredicate:dayPredicate] firstObject];
}

- (void)addSection:(YGOperationSection *)section {
    
    // Calculate bounds for new section in dataSource
    NSInteger lowIndex = [self.sections indexOfObjectPassingTest:^BOOL(YGOperationSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([section.date compare:obj.date] == NSOrderedAscending) {
            return YES;
        } else {
            return NO;
        }
    }];
    NSInteger upperIndex = [self.sections indexOfObjectPassingTest:^BOOL(YGOperationSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([section.date compare:obj.date] == NSOrderedDescending) {
            return YES;
        } else {
            return NO;
        }
    }];
    
    // Add new section to dataSource
    if (lowIndex != NSNotFound && upperIndex != NSNotFound) {
        [self.sections insertObject:section atIndex:upperIndex];
    } else if (lowIndex != NSNotFound && upperIndex == NSNotFound) {
        [self.sections addObject:section];
    } else if (lowIndex == NSNotFound && upperIndex != NSNotFound) {
        [self.sections insertObject:section atIndex:0];
    } else if (lowIndex == NSNotFound && upperIndex == NSNotFound) {
        [self.sections addObject:section];
    }
}

@end
