//
//  YGCategoryManager.m
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCategoryManager.h"
#import "YGSQLite.h"
#import "YGTools.h"

#define YGBooleanValueNO    0
#define YGBooleanValueYES   1

@interface YGCategoryManager (){
    YGSQLite *_sqlite;
}
- (YGCategory *)categoryBySqlQuery:(NSString *)sqlQuery;

@end

@implementation YGCategoryManager

+(instancetype)sharedInstance{
    static YGCategoryManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YGCategoryManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if(self){
        _sqlite = [YGSQLite sharedInstance];
    }
    return self;
}


- (NSArray <YGCategory *> *)listCategoriesByType:(YGCategoryType)type{
    
    NSMutableArray <YGCategory *> *result = [[NSMutableArray alloc] init];
        
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id, category_type_id, name, active, active_from, active_to, sort, short_name, symbol, attach, parent_id, comment  FROM category WHERE category_type_id = %ld ORDER BY sort ASC;", type];
    
    NSArray *classes = [NSArray arrayWithObjects:
                        [NSNumber class], // category_id
                        [NSNumber class], // category_type_id
                        [NSString class], // name
                        [NSNumber class], // active
                        [NSString class], // active_from
                        [NSString class], // active_to
                        [NSNumber class], // sort
                        [NSString class], // short_name
                        [NSString class], // symbol
                        [NSNumber class], // attach
                        [NSNumber class], // parent_id
                        [NSString class], // comment
                        nil];
    
    NSArray *rawCategories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
    
    for(NSArray *arr in rawCategories){
        
        NSInteger rowId = [arr[0] integerValue];
        YGCategoryType type = [arr[1] integerValue];
        NSString *name = arr[2];
        BOOL active = [arr[3] boolValue];
        NSDate *activeFrom = [YGTools dateFromString:arr[4]];
        NSDate *activeTo = [arr[5] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[5]];
        NSInteger sort = [arr[6] integerValue];
        NSString *shortName = [arr[7] isEqual:[NSNull null]] ? nil : arr[7];
        NSString *symbol = [arr[8] isEqual:[NSNull null]] ? nil : arr[8];
        BOOL attach = [arr[9] boolValue];
        NSInteger parentId = arr[10] > 0 ? [arr[10] integerValue] : -1;
        NSString *comment = [arr[11] isEqual:[NSNull null]] ? nil : arr[11];

        YGCategory *category = [[YGCategory alloc] initWithRowId:rowId categoryType:type name:name active:active activeFrom:activeFrom activeTo:activeTo sort:sort shortName:shortName symbol:symbol attach:attach parentId:parentId comment:comment];
        
        [result addObject:category];
    }
    
    return [result copy];
}

- (NSArray <YGCategory *> *)listCategoriesByType:(YGCategoryType)type exceptForId:(NSInteger)categoryId {
    
    NSMutableArray <YGCategory *> *result = [[NSMutableArray alloc] init];
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id, category_type_id, name, active, active_from, active_to, sort, short_name, symbol, attach, parent_id, comment  FROM category WHERE category_type_id = %ld AND category_id != %ld ORDER BY sort ASC;", type, categoryId];
    
    NSArray *classes = [NSArray arrayWithObjects:
                        [NSNumber class], // category_id
                        [NSNumber class], // category_type_id
                        [NSString class], // name
                        [NSNumber class], // active
                        [NSString class], // active_from
                        [NSString class], // active_to
                        [NSNumber class], // sort
                        [NSString class], // short_name
                        [NSString class], // symbol
                        [NSNumber class], // attach
                        [NSNumber class], // parent_id
                        [NSString class], // comment
                        nil];
    
    NSArray *rawCategories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
    
    for(NSArray *arr in rawCategories){
        
        NSInteger rowId = [arr[0] integerValue];
        YGCategoryType type = [arr[1] integerValue];
        NSString *name = arr[2];
        BOOL active = [arr[3] boolValue];
        NSDate *activeFrom = [YGTools dateFromString:arr[4]];
        NSDate *activeTo = [arr[5] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[5]];
        NSInteger sort = [arr[6] integerValue];
        NSString *shortName = [arr[7] isEqual:[NSNull null]] ? nil : arr[7];
        NSString *symbol = [arr[8] isEqual:[NSNull null]] ? nil : arr[8];
        BOOL attach = [arr[9] boolValue];
        NSInteger parentId = arr[10] > 0 ? [arr[10] integerValue] : -1;
        NSString *comment = [arr[11] isEqual:[NSNull null]] ? nil : arr[11];
        
        YGCategory *category = [[YGCategory alloc] initWithRowId:rowId categoryType:type name:name active:active activeFrom:activeFrom activeTo:activeTo sort:sort shortName:shortName symbol:symbol attach:attach parentId:parentId comment:comment];
        
        [result addObject:category];
    }
    
    return [result copy];
}


#pragma mark - Is it possible to delete category? 

- (BOOL)isJustOneCategory:(YGCategory *)category {
    
    // search all categories for the current type
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id FROM category WHERE category_type_id = %ld;", category.type];
    NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
    
    NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
    
    if([categories count] == 1)
        return YES;
    else if([categories count] > 1)
        return NO;
    else
        @throw [NSException exceptionWithName:@"-[YGCategoryManager isJustOneCategory" reason:[NSString stringWithFormat:@"Category is not exist for the type: %ld", category.type] userInfo:nil];
}



/**
 Check category for linked objects (operations, entities, etc.) existense.
 
 @category Category checked for existense of objects
 
 @return YES if linked object exists and NO if linked objects does not exists
 */
- (BOOL)hasLinkedObjectsForCategory:(YGCategory *)category {
    
    if(category.type == YGCategoryTypeCurrency) {
        
        // search currency in operations
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id FROM operation WHERE source_currency_id = %ld OR target_currency_id = %ld LIMIT 1;", category.rowId, category.rowId];
        NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
        
        NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
        
        if([categories count] > 0)
            return YES;
        
        // in entities
        sqlQuery = [NSString stringWithFormat:@"SELECT entity_id FROM entity WHERE currency_id = %ld LIMIT 1;", category.rowId];
        classes = [NSArray arrayWithObjects:[NSNumber class], nil];
        
        categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
        
        if([categories count] > 0)
            return YES;
    }
    else if(category.type == YGCategoryTypeExpense){
        
        // search in operations
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id FROM operation WHERE operation_type_id = %ld AND target_id = %ld LIMIT 1;", YGCategoryTypeExpense, category.rowId];
        NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
        
        NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
        
        if([categories count] > 0)
            return YES;
    }
    else if(category.type == YGCategoryTypeIncome){
        
        // search in operations
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id FROM operation WHERE operation_type_id = %ld AND target_id = %ld LIMIT 1;", YGCategoryTypeIncome, category.rowId];
        NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
        
        NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
        
        if([categories count] > 0)
            return YES;
    }
    
    return NO;
}


- (void)removeCategoryWithId:(NSInteger)rowId{
    
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM category WHERE category_id = %ld;", rowId];
    
    [_sqlite removeRecordWithSQL:deleteSQL];
}

- (void)removeCategory:(YGCategory *)category{
    [self removeCategoryWithId:category.rowId];
}

- (void)addCategory:(YGCategory *)category {
    
    @try {
        NSArray *arrItem = [NSArray arrayWithObjects:
                            [NSNumber numberWithInteger:category.type], //category_type_id,
                            category.name, //name,
                            [NSNumber numberWithBool:category.active], //active,
                            [YGTools stringFromDate:category.activeFrom], //active_from,
                            category.activeTo ? [YGTools stringFromDate:category.activeTo] : [NSNull null], //active_to,
                            [NSNumber numberWithInteger:category.sort], //sort,
                            category.shortName ? category.shortName : [NSNull null], //short_name,
                            category.symbol ? category.symbol : [NSNull null], //symbol,
                            [NSNumber numberWithBool:category.attach], //attach,
                            category.parentId != -1 ? [NSNumber numberWithInteger:category.parentId] : [NSNull null], //parent_id,
                            category.comment ? category.comment : [NSNull null], //comment,
                            nil];
        
        NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, active_from, active_to, sort, short_name, symbol, attach, parent_id, comment) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        
        NSInteger resultId = [_sqlite addRecord:arrItem insertSQL:insertSQL];
        
        // if set default currency
        if((category.type == YGCategoryTypeCurrency) && (category.attach == YES)){
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE category SET attach=0 WHERE category_type_id = %ld AND category_id != %ld;", category.type, resultId];
            [_sqlite execSQL:updateSql];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", [exception description]);
    }
}

- (YGCategory *)categoryById:(NSInteger)categoryId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id, category_type_id, name, active, active_from, active_to, sort, short_name, symbol, attach, parent_id, comment  FROM category WHERE category_id = %ld;", categoryId];
    
    return [self categoryBySqlQuery:sqlQuery];
}


/**
 Return only one attached entity for type. Terms for category: equls type, active, attach and must be only one. Else return nil.
 
 */
- (YGCategory *)categoryAttachedForType:(YGCategoryType)type {

    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id, category_type_id, name, active, active_from, active_to, sort, short_name, symbol, attach, parent_id, comment  FROM category WHERE category_type_id=%ld AND active=%d AND attach=%d;", type, YGBooleanValueYES, YGBooleanValueYES];

    return [self categoryBySqlQuery:sqlQuery];
}

- (YGCategory *)categoryOnTopForType:(YGCategoryType)type {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id, category_type_id, name, active, active_from, active_to, sort, short_name, symbol, attach, parent_id, comment  FROM category WHERE category_type_id=%ld AND active=%d ORDER BY sort ASC LIMIT 1;", type, YGBooleanValueYES];
    
    return [self categoryBySqlQuery:sqlQuery];
}

/**
 Inner func for categoryById:, categoryAttachedForType: and categoryOnTopForType:.
 
 */
- (YGCategory *)categoryBySqlQuery:(NSString *)sqlQuery {

    NSMutableArray <YGCategory *> *result = [[NSMutableArray alloc] init];
    
    NSArray *classes = [NSArray arrayWithObjects:
                        [NSNumber class], // category_id
                        [NSNumber class], // category_type_id
                        [NSString class], // name
                        [NSNumber class], // active
                        [NSString class], // active_from
                        [NSString class], // active_to
                        [NSNumber class], // sort
                        [NSString class], // short_name
                        [NSString class], // symbol
                        [NSNumber class], // attach
                        [NSNumber class], // parent_id
                        [NSString class], // comment
                        nil];
    
    NSArray *rawCategories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
    
    for(NSArray *arr in rawCategories){
        
        NSInteger rowId = [arr[0] integerValue];
        YGCategoryType type = [arr[1] integerValue];
        NSString *name = arr[2];
        BOOL active = [arr[3] boolValue];
        NSDate *activeFrom = [YGTools dateFromString:arr[4]];
        NSDate *activeTo = [arr[5] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[5]];
        NSInteger sort = [arr[6] integerValue];
        NSString *shortName = [arr[7] isEqual:[NSNull null]] ? nil : arr[7];
        NSString *symbol = [arr[8] isEqual:[NSNull null]] ? nil : arr[8];
        BOOL attach = [arr[9] boolValue];
        NSInteger parentId = arr[10] > 0 ? [arr[10] integerValue] : -1;
        NSString *comment = [arr[11] isEqual:[NSNull null]] ? nil : arr[11];
        
        YGCategory *category = [[YGCategory alloc] initWithRowId:rowId categoryType:type name:name active:active activeFrom:activeFrom activeTo:activeTo sort:sort shortName:shortName symbol:symbol attach:attach parentId:parentId comment:comment];
        
        [result addObject:category];
    }
    
    if([result count] == 0)
        return nil;
    else if([result count] > 1)
        @throw [NSException exceptionWithName:@"-[YGCategoryManager categoryBySqlQuery:]" reason:[NSString stringWithFormat:@"Undefined choice for category. Sql query: %@", sqlQuery]  userInfo:nil];
    else
        return [result objectAtIndex:0];
}


- (void)updateCategory:(YGCategory *)category{
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET name=%@, active=%@, active_from=%@, active_to=%@, sort=%@, short_name=%@, symbol=%@, attach=%@, parent_id=%@, comment=%@ WHERE category_id=%@;",
                           [YGTools sqlStringForStringOrNull:category.name],
                           [YGTools sqlStringForBool:category.active],
                           [YGTools sqlStringForDateOrNull:category.activeFrom],
                           [YGTools sqlStringForDateOrNull:category.activeTo],
                           [YGTools sqlStringForIntOrNull:category.sort],
                           [YGTools sqlStringForStringOrNull:category.shortName],
                           [YGTools sqlStringForStringOrNull:category.symbol],
                           [YGTools sqlStringForBool:category.attach],
                           [YGTools sqlStringForIntOrNull:category.parentId],
                           [YGTools sqlStringForStringOrNull:category.comment],
                           [YGTools sqlStringForIntOrNull:category.rowId]];
    
    [_sqlite execSQL:updateSQL];
}

- (void)setOnlyOneDefaultCategory:(YGCategory *)category{
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET attach=0 "
                           "WHERE category_type_id = %ld AND category_id != %ld;",
                           category.type,
                           category.rowId];
    
    [_sqlite execSQL:updateSQL];
}


- (void)deactivateCategory:(YGCategory *)category{
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET active=0, active_to='%@' WHERE category_id='%ld';", [YGTools stringFromDate:[NSDate date]], category.rowId];
    
    [_sqlite execSQL:updateSQL];
}

- (void)activateCategory:(YGCategory *)category {
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET active=1, active_to=NULL WHERE category_id='%ld';", category.rowId];
    
    [_sqlite execSQL:updateSQL];
}


@end
