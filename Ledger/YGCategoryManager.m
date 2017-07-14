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
#import "YGOperation.h"

#define YGBooleanValueNO    0
#define YGBooleanValueYES   1

@interface YGCategoryManager (){
    YGSQLite *_sqlite;
}
- (YGCategory *)categoryBySqlQuery:(NSString *)sqlQuery;

@end

@implementation YGCategoryManager

@synthesize categories = _categories;

#pragma mark - Singleton, init & accessors

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
        _categories = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark - Getter for categories

- (NSMutableDictionary <NSString *, NSMutableArray <YGCategory *> *> *)categories {
    
    if([_categories count] == 0) {
        _categories = [self categoriesForCache];
    }
    return _categories;
}

#pragma mark - Inner methods for memory cache process



- (NSArray <YGCategory *> *)categoriesFromDb {
    
    NSString *sqlQuery = @"SELECT category_id, category_type_id, name, active, active_from, active_to, sort, short_name, symbol, attach, parent_id, comment  FROM category ORDER BY active DESC, sort ASC;";
    
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
    
    NSMutableArray <YGCategory *> *result = [[NSMutableArray alloc] init];
    
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


- (NSMutableDictionary <NSString *, NSMutableArray <YGCategory *> *> *)categoriesForCache {
    
    NSArray *categoriesRaw = [self categoriesFromDb];
    
    NSMutableDictionary <NSString *, NSMutableArray <YGCategory *> *> *categoriesResult = [[NSMutableDictionary alloc] init];
    
    NSString *typeString = nil;
    for(YGCategory *category in categoriesRaw){
        
        typeString = NSStringFromCategoryType(category.type);
        
        if([categoriesResult valueForKey:typeString]){
            [[categoriesResult valueForKey:typeString] addObject:category];
        }
        else{
            [categoriesResult setValue:[[NSMutableArray alloc] init] forKey:typeString];
            [[categoriesResult valueForKey:typeString] addObject:category];
        }
    }
    
    // sort categories in each inner array
    NSArray *types = [categoriesResult allKeys];
    for(NSString *type in types)
        [self sortCategoriesInArray:categoriesResult[type]];
    
    return categoriesResult;
}

- (void)sortCategoriesInArray:(NSMutableArray <YGCategory *>*)array {
    
    NSSortDescriptor *sortOnActiveByDesc = [[NSSortDescriptor alloc] initWithKey:@"active" ascending:NO];
    NSSortDescriptor *sortOnSortByAsc = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    //NSSortDescriptor *sortOnActiveFromByAsc = [[NSSortDescriptor alloc] initWithKey:@"activeFrom"  ascending:YES];
    
    [array sortUsingDescriptors:@[sortOnActiveByDesc, sortOnSortByAsc]];
}



/*
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
 
 */

/*
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
*/

#pragma mark - Is it possible to delete category? 

/**
 @warning Why search in db instead of cache?

*/
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
 Check category for linked objects (operations, categories, etc.) existense.
 @warning Why search in db instead of cache?
 
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
    else if(category.type == YGCategoryTypeIncome){
        
        // search in operations
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id FROM operation WHERE operation_type_id = %ld AND source_id = %ld LIMIT 1;", YGOperationTypeIncome, category.rowId];
        NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
        
        NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
        
        if([categories count] > 0)
            return YES;
    }
    else if(category.type == YGCategoryTypeExpense){
        
        // search in operations
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id FROM operation WHERE operation_type_id = %ld AND target_id = %ld LIMIT 1;", YGOperationTypeExpense, category.rowId];
        NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
        
        NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
        
        if([categories count] > 0)
            return YES;
                
    }
    else{
        @throw [NSException exceptionWithName:@"-[YGCategoryManager hasLinkedObjectsForCategory]" reason:@"Can not check for this type of category" userInfo:nil];
    }
    
    return NO;
}

- (BOOL)hasChildObjectForCategory:(YGCategory *)category {
    
    // search child for category
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id FROM category WHERE parent_id=%ld LIMIT 1;", category.rowId];
    NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
    NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
    
    if([categories count] > 0)
        return YES;
    else
        return NO;
}

- (BOOL)hasChildObjectActiveForCategory:(YGCategory *)category {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id FROM category WHERE parent_id=%ld AND active=%d LIMIT 1;", category.rowId, YGBooleanValueYES];
    NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
    NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
    
    if([categories count] > 0)
        return YES;
    else
        return NO;
}


/**
 @warning Why search in db instead of cache?
 */
- (BOOL)hasActiveCategoryForTypeExceptCategory:(YGCategory *)category {
    
    // search currency in operations
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT category_id FROM category WHERE category_type_id=%ld AND active=%d AND category_id<>%ld LIMIT 1;", category.type,  YGBooleanValueYES, category.rowId];
    NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
    
    NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
    
    if([categories count] > 0)
        return YES;
    else
        return NO;
}


#pragma mark - Actions on category

- (NSInteger)idAddCategory:(YGCategory *)category {
    
    NSInteger rowId = -1;
    
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
        
        rowId = [_sqlite addRecord:arrItem insertSQL:insertSQL];
        
        // if set default currency
        if((category.type == YGCategoryTypeCurrency) && (category.attach == YES)){
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE category SET attach=0 WHERE category_type_id = %ld AND category_id != %ld;", category.type, rowId];
            [_sqlite execSQL:updateSql];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", [exception description]);
    }
    @finally {
        return rowId;
    }
    
}


- (void)addCategory:(YGCategory *)category {
    
    // add entity to db
    NSInteger rowId = [self idAddCategory:category];
    YGCategory *newCategory = [category copy];
    newCategory.rowId = rowId;
    
    // add entity to memory cache
    [[_categories valueForKey:NSStringFromCategoryType(newCategory.type)] addObject:newCategory];
    [self sortCategoriesInArray:[_categories valueForKey:NSStringFromCategoryType(newCategory.type)]];
    
    [self generateChangeCacheEventForType:category.type];

}

- (YGCategory *)categoryById:(NSInteger)categoryId type:(YGCategoryType)type {
    
    NSArray <YGCategory *> *categoriesByType = [self.categories valueForKey:NSStringFromCategoryType(type)];
    
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"rowId = %ld", categoryId];
    
    return [[categoriesByType filteredArrayUsingPredicate:idPredicate] firstObject];
}

#warning Is entity needs to update in inner storage?
/**
 @warning It seems entity updated in EditController edit by reference, so... is it true?
 */
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
    
    // update memory cache
    NSMutableArray <YGCategory *> *categoriesByType = [_categories valueForKey:NSStringFromCategoryType(category.type)];
    YGCategory *replaceCategory = [self categoryById:category.rowId type:category.type];
    NSUInteger index = [categoriesByType indexOfObject:replaceCategory];
    categoriesByType[index] = category;
    
    // sort memory cache
    [self sortCategoriesInArray:categoriesByType];
    
    // post notification for subscribers
    [self generateChangeCacheEventForType:category.type];

}

- (void)deactivateCategory:(YGCategory *)category{
    
    NSString *activeTo = [YGTools stringFromDate:[NSDate date]];
    
    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET active=0, active_to='%@' WHERE category_id='%ld';", activeTo, category.rowId];
    
    [_sqlite execSQL:updateSQL];
    
    // update memory cache
    NSMutableArray <YGCategory *> *categoriesByType = [_categories valueForKey:NSStringFromCategoryType(category.type)];
    YGCategory *updateCategory = [categoriesByType objectAtIndex:[categoriesByType indexOfObject:category]];
    updateCategory.active = NO;
    updateCategory.activeTo = [YGTools dateFromString:activeTo];
    
    // sort memory cache
    [self sortCategoriesInArray:categoriesByType];
    
    // post notification for subscribers
    [self generateChangeCacheEventForType:category.type];

    
}

- (void)activateCategory:(YGCategory *)category {
    
    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET active=1, active_to=NULL WHERE category_id='%ld';", category.rowId];
    
    [_sqlite execSQL:updateSQL];
    
    // update memory cache
    NSMutableArray <YGCategory *> *categoriesByType = [_categories valueForKey:NSStringFromCategoryType(category.type)];
    YGCategory *updateCategory = [categoriesByType objectAtIndex:[categoriesByType indexOfObject:category]];
    updateCategory.active = YES;
    updateCategory.activeTo = nil;
    
    [self sortCategoriesInArray:categoriesByType];
    
    // post notification for subscribers
    [self generateChangeCacheEventForType:category.type];

}

- (void)removeCategory:(YGCategory *)category{

    // update db
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM category WHERE category_id = %ld;", category.rowId];
    
    [_sqlite removeRecordWithSQL:deleteSQL];
    
    // update memory cache
    NSMutableArray <YGCategory *> *categoriesByType = [_categories valueForKey:NSStringFromCategoryType(category.type)];
    
    NSUInteger index = [categoriesByType indexOfObject:category];
    [categoriesByType removeObjectAtIndex:index];
    
    
    // post notification for subscribers
    [self generateChangeCacheEventForType:category.type];
}


/*
- (void)removeCategoryWithId:(NSInteger)rowId{
    
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM category WHERE category_id = %ld;", rowId];
    
    [_sqlite removeRecordWithSQL:deleteSQL];
}

- (void)removeCategory:(YGCategory *)category{
    [self removeCategoryWithId:category.rowId];
}
 
 */



#pragma mark - Lists of categories

- (NSArray <YGCategory *> *)categoriesByType:(YGCategoryType)type onlyActive:(BOOL)onlyActive exceptCategory:(YGCategory *)exceptCategory {
    
    NSArray <YGCategory *> *categoriesResult = [_categories valueForKey:NSStringFromCategoryType(type)];
    
    if(onlyActive){
        NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"active = YES"];
        categoriesResult = [categoriesResult filteredArrayUsingPredicate:activePredicate];
    }
    
    if(exceptCategory){
        NSPredicate *exceptPredicate = [NSPredicate predicateWithFormat:@"rowId != %ld", exceptCategory.rowId];
        categoriesResult = [categoriesResult filteredArrayUsingPredicate:exceptPredicate];
    }
    
    return categoriesResult;
}

- (NSArray <YGCategory *> *)categoriesByType:(YGCategoryType)type onlyActive:(BOOL)onlyActive {
    
    return [self categoriesByType:type onlyActive:onlyActive exceptCategory:nil];
}

- (NSArray <YGCategory *> *)categoriesByType:(YGCategoryType)type {
    
    return [self categoriesByType:type onlyActive:NO exceptCategory:nil];
}

#pragma mark - Auxiliary methods

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


- (void)setOnlyOneDefaultCategory:(YGCategory *)category{
    
    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE category SET attach=0 "
                           "WHERE category_type_id = %ld AND category_id != %ld;",
                           category.type,
                           category.rowId];
    
    [_sqlite execSQL:updateSQL];
    
    
    // update memory cache
    NSPredicate *unAttachedPredicate = [NSPredicate predicateWithFormat:@"type = %ld && rowId != %ld", category.type, category.rowId];
    
    NSArray <YGCategory *> *categoriesByType = [self categoriesByType:category.type];
    
    NSArray <YGCategory *> *updateCategories = [categoriesByType filteredArrayUsingPredicate:unAttachedPredicate];

    if([updateCategories count] > 0)
        for(YGCategory *c in updateCategories)
            c.attach = NO;
}

- (void)generateChangeCacheEventForType:(YGCategoryType)type {
    
    NSLog(@"-[YGCategoryMananger generateChangeCacheEventForType]");
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    switch (type) {
        case YGCategoryTypeCurrency:
            [center postNotificationName:@"CategoryManagerCurrencyCacheUpdateEvent" object:nil];
            break;
        case YGCategoryTypeExpense:
            [center postNotificationName:@"CategoryManagerExpenseCacheUpdateEvent" object:nil];
            break;
        case YGCategoryTypeIncome:
            [center postNotificationName:@"CategoryManagerIncomeCacheUpdateEvent" object:nil];
            break;
        case YGCategoryTypeCreditorOrDebtor:
            [center postNotificationName:@"CategoryManagerCreditorOrDebtorCacheUpdateEvent" object:nil];
            break;
        case YGCategoryTypeTag:
            [center postNotificationName:@"CategoryManagerTagCacheUpdateEvent" object:nil];
            break;
        default:
            break;
    }
}

@end
