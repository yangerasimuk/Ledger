//
//  YGOperationManager.m
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationManager.h"
#import "YGSQLite.h"
#import "YGTools.h"
#import "YGEntityManager.h"
#import "YGConfig.h"


@interface YGOperationManager (){
    YGSQLite *_sqlite;
}

- (YGOperation *)operationBySqlQuery:(NSString *)sqlQuery;
- (NSArray <YGOperation *> *)operationsBySqlQuery:(NSString *)sqlQuery;
@end

@implementation YGOperationManager

@synthesize operations = _operations;

#pragma mark - Init

+ (instancetype)sharedInstance{
    static YGOperationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YGOperationManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if(self){
        _sqlite = [YGSQLite sharedInstance];
        _operations = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - Getter for categories

/**
 @warning All another methods must call property only through self. syntax.
 */
- (NSMutableArray <YGOperation *> *)operations {
    
    if(!_operations || [_operations count] == 0) {
        _operations = [[self operationsForCache] mutableCopy];
    }
    return _operations;
}


#pragma mark - Inner methods for memory cache process

- (NSArray <YGOperation *> *)operationsForCache {
    
    NSString *sqlQuery = @"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, created, modified, comment FROM operation ORDER BY created_unix DESC;";
    
    return [self operationsBySqlQuery:sqlQuery];
}

- (void)sortOperationsInArray:(NSMutableArray <YGOperation *> *)array {
    
    NSSortDescriptor *sortOnDateUnixByDesc = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    
    [array sortUsingDescriptors:@[sortOnDateUnixByDesc]];
}


#pragma mark - Actions on operation(s)

- (NSInteger)addOperation:(YGOperation *)operation{
    
    // return value
    NSInteger operationId = 0;
    
    NSNumber *operation_type_id = [NSNumber numberWithInteger:operation.type];
    NSNumber *source_id = [NSNumber numberWithInteger:operation.sourceId];
    NSNumber *target_id = [NSNumber numberWithInteger:operation.targetId];
    NSNumber *source_sum = [NSNumber numberWithDouble:operation.sourceSum];
    NSNumber *source_currency_id = [NSNumber numberWithInteger:operation.sourceCurrencyId];
    NSNumber *target_sum = [NSNumber numberWithDouble:operation.targetSum];
    NSNumber *target_currency_id = [NSNumber numberWithInteger:operation.targetCurrencyId];
    
    NSDate *timestamp = operation.created; //[NSDate date];
    NSString *created = [YGTools stringWithCurrentTimeZoneFromDate:timestamp];
    NSNumber *created_unix = [NSNumber numberWithDouble:[timestamp timeIntervalSince1970]];
    NSString *modified = [created copy];
    NSNumber *modified_unix = [created_unix copy];

    NSString *comment = operation.comment;
    
    @try {
        
        NSArray *operationArr = [NSArray arrayWithObjects:
                                 operation_type_id,
                                 source_id,
                                 target_id,
                                 source_sum,
                                 source_currency_id,
                                 target_sum,
                                 target_currency_id,
                                 created,
                                 created_unix,
                                 modified,
                                 modified_unix,
                                 comment ? comment : [NSNull null],
                                 nil];
        
        // sql string
        NSString *insertSQL = @"INSERT INTO operation (operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, created, created_unix, modified, modified_unix, comment) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        
        // db
        operationId = [_sqlite addRecord:operationArr insertSQL:insertSQL];
        
        // specific actions
        if(operation.type == YGOperationTypeAccountActual){
            
            // update account sum colomn
            
            YGEntityManager *em = [YGEntityManager sharedInstance];
            
            YGEntity *account = [em entityById:operation.targetId type:YGEntityTypeAccount];
            
            account.sum = operation.targetSum;
            
            //NSLog(@"%@", [account description]);
            
            // check
            if(account.currencyId != operation.sourceCurrencyId || account.currencyId != operation.targetCurrencyId)
                @throw [NSException exceptionWithName:@"-[YGOperationManager addOperation]" reason:@"AccountActual operation currency is not equal account currency" userInfo:nil];
            
            [em updateEntity:account];
        }
        
        // add operation to memory cache
        YGOperation *newOperation = [operation copy];
        newOperation.rowId = operationId;
        [self.operations addObject:newOperation];
        
        [self sortOperationsInArray:self.operations];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"OperationManagerCacheUpdateEvent"
                              object:nil];
        
        return operationId;
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in -[YGOperationManager addOperation]. Description: %@.", [exception description]);
    }
    
}

- (YGOperation *)operationById:(NSInteger)operationId {
    
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"rowId = %ld", operationId];
    
    return [[self.operations filteredArrayUsingPredicate:idPredicate] firstObject];
}


- (void)updateOperation:(YGOperation *)operation{
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE operation SET operation_type_id=%ld, source_id=%ld, target_id=%ld, source_sum=%.2f, source_currency_id=%ld, target_sum=%.2f, target_currency_id=%ld, created='%@', created_unix=%f, modified='%@', modified_unix=%f,comment='%@' WHERE operation_id=%ld;", operation.type, operation.sourceId,
                           operation.targetId,
                           operation.sourceSum,
                           operation.sourceCurrencyId,
                           operation.targetSum,
                           operation.targetCurrencyId,
                           [YGTools stringWithCurrentTimeZoneFromDate:operation.created],
                           [operation.created timeIntervalSince1970],
                           [YGTools stringWithCurrentTimeZoneFromDate:operation.modified],
                           [operation.modified timeIntervalSince1970],
                           operation.comment,
                           operation.rowId];
    
    [_sqlite execSQL:updateSQL];
    
    // update memory cache
    YGOperation *replaceOperation = [self operationById:operation.rowId];
    NSUInteger index = [self.operations indexOfObject:replaceOperation];
    //self.operations set
    self.operations[index] = [operation copy];
    
    // Need sort? It seems not. But if update date?
    [self sortOperationsInArray:self.operations];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"OperationManagerCacheUpdateEvent"
                          object:nil];
}


- (void)removeOperation:(YGOperation *)operation{
    
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM operation WHERE operation_id = %ld;", (long)operation.rowId];
    
    [_sqlite removeRecordWithSQL:deleteSQL];
    
    // update memory cache
    [self.operations removeObject:operation];
    
    // sort don't needed
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"OperationManagerCacheUpdateEvent"
                          object:nil];
}


- (NSArray <YGOperation *> *)operationsWithAccountId:(NSInteger)accountId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, created, modified, comment FROM operation WHERE (operation_type_id=2 AND source_id=%ld) OR (operation_type_id=1 AND target_id=%ld) OR (operation_type_id=4 AND (source_id=%ld OR target_id=%ld)) ORDER BY created_unix DESC;", (long)accountId, (long)accountId, (long)accountId, (long)accountId];
    
    return [self operationsBySqlQuery:sqlQuery];
}

- (NSArray <YGOperation *> *)operationsWithAccountId:(NSInteger)accountId sinceDate:(NSDate *)startDate {
    NSInteger startDateUnix = [startDate timeIntervalSince1970];
    
    NSString *sqlQuery = [NSString stringWithFormat:
        @"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, created, modified, comment "
        "FROM operation "
        "WHERE created_unix > %ld AND ((operation_type_id=2 AND source_id=%ld) "
                          "OR (operation_type_id=1 AND target_id=%ld) "
                          "OR (operation_type_id=4 AND (source_id=%ld OR target_id=%ld))) "
        "ORDER BY created_unix DESC;", startDateUnix, accountId, accountId, accountId, accountId];
    
    return [self operationsBySqlQuery:sqlQuery];
    
}

- (NSArray <YGOperation *> *)operationsWithTargetId:(NSInteger)targetId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, created, modified, comment FROM operation WHERE target_id=%ld ORDER BY created_unix DESC;", targetId];

    return [self operationsBySqlQuery:sqlQuery];
}

- (NSArray <YGOperation *> *)operationsOfType:(YGOperationType)type withSourceId:(NSInteger)sourceId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, created, modified, comment FROM operation WHERE operation_type_id=%ld AND source_id=%ld ORDER BY created_unix DESC;", type, sourceId];
    
    return [self operationsBySqlQuery:sqlQuery];
}


- (NSArray <YGOperation *> *)listOperations{
    
    NSString *sqlQuery = @"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, created, modified, comment FROM operation ORDER BY created_unix DESC;";
    
    return [self operationsBySqlQuery:sqlQuery];
}


- (NSArray <YGOperation *> *)operationsBySqlQuery:(NSString *)sqlQuery {
    
    NSArray *rawList = [_sqlite selectWithSqlQuery:sqlQuery];
    
    NSMutableArray <YGOperation *> *result = [[NSMutableArray alloc] init];
    
    for(NSArray *arr in rawList){
        
        NSInteger rowId = [arr[0] integerValue];
        YGOperationType type = [arr[1] integerValue];
        NSInteger sourceId = [arr[2] integerValue];
        NSInteger targetId = [arr[3] integerValue];
        double sourceSum = [arr[4] doubleValue];
        NSInteger sourceCurrencyId = [arr[5] integerValue];
        double targetSum = [arr[6] doubleValue];
        NSInteger targetCurrencyId= [arr[7] integerValue];
        NSDate *created = [arr[8] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[8]];
        NSDate *modified = [arr[9] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[9]];
        NSString *comment = [arr[10] isEqual:[NSNull null]] ? nil : arr[10];
        
        YGOperation *operation = [[YGOperation alloc] initWithRowId:rowId type:type sourceId:sourceId targetId:targetId sourceSum:sourceSum sourceCurrencyId:sourceCurrencyId targetSum:targetSum targetCurrencyId:targetCurrencyId created:created modified:modified comment:comment];
        
        [result addObject:operation];
    }
    
    return [result copy];
}

/**
 Wrapper on operationBySqlQuery:.
 */
- (YGOperation *)lastOperationForType:(YGOperationType)type {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, created, modified, comment FROM operation WHERE operation_type_id=%ld ORDER BY created_unix DESC LIMIT 1;", type];
    
    return [self operationBySqlQuery:sqlQuery];
}

- (YGOperation *)lastOperationOfType:(YGOperationType)type withTargetId:(NSInteger)targetId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, created, modified, comment FROM operation WHERE operation_type_id=%ld AND target_id=%ld ORDER BY created_unix DESC LIMIT 1;", type, targetId];
    
    return [self operationBySqlQuery:sqlQuery];
}

- (YGOperation *)operationBySqlQuery:(NSString *)sqlQuery {
    
    NSArray *rawList = [_sqlite selectWithSqlQuery:sqlQuery];
    
    NSMutableArray <YGOperation *> *result = [[NSMutableArray alloc] init];
    
    for(NSArray *arr in rawList){
        
        NSInteger rowId = [arr[0] integerValue];
        YGOperationType type = [arr[1] integerValue];
        NSInteger sourceId = [arr[2] integerValue];
        NSInteger targetId = [arr[3] integerValue];
        double sourceSum = [arr[4] doubleValue];
        NSInteger sourceCurrencyId = [arr[5] integerValue];
        double targetSum = [arr[6] doubleValue];
        NSInteger targetCurrencyId= [arr[7] integerValue];
        NSDate *created = [arr[8] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[8]];
        NSDate *modified = [arr[9] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[9]];
        NSString *comment = [arr[10] isEqual:[NSNull null]] ? nil : arr[10];
        
        YGOperation *operation = [[YGOperation alloc] initWithRowId:rowId type:type sourceId:sourceId targetId:targetId sourceSum:sourceSum sourceCurrencyId:sourceCurrencyId targetSum:targetSum targetCurrencyId:targetCurrencyId created:created modified:modified comment:comment];

        [result addObject:operation];
    }
    
    if([result count] == 0)
        return nil;
    else if([result count] > 1)
        @throw [NSException exceptionWithName:@"-[YGOperationManager operationBySqlQuery]" reason:[NSString stringWithFormat:@"Undefined choice for operation. Sql query: %@", sqlQuery]  userInfo:nil];
    else
        return [result objectAtIndex:0];
}

@end
