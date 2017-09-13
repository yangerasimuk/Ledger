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

#pragma mark - sharedInstanse & init

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
        [self getOperationsForCache];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(getOperationsForCache)
                       name:@"DatabaseRestoredEvent"
                     object:nil];
    }
    return self;
}


-(void)dealloc {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}


/**
 @warning Массиву нельзя присваивать nil, так как в этом случае нельзя будет добавлять объекты
 */
- (void)setOperations:(NSMutableArray<YGOperation *> *)operations {
    
    if(operations && ![_operations isEqual:operations]){
        
        _operations = [operations mutableCopy];
    }
    else if(!operations && [_operations count] > 0)
        [_operations removeAllObjects];
    
    // Нужно извещать и в том случае, если операций нет, такое возможно при восстановлении из пусто бд
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"OperationManagerCacheUpdateEvent"
                          object:nil];
}


#pragma mark - Inner methods for memory cache process

- (void) getOperationsForCache {
    
    NSString *sqlQuery = @"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation ORDER BY day_unix DESC, modified_unix DESC;";
    
    self.operations = [[self operationsBySqlQuery:sqlQuery] mutableCopy];
}


/**
 Sort operations in cache array. First sort: day, second: modified.
 */
- (void)sortOperationsInArray:(NSMutableArray <YGOperation *> *)array {
    
    NSSortDescriptor *sortOnDayByDesc = [[NSSortDescriptor alloc] initWithKey:@"day" ascending:NO];
    NSSortDescriptor *sortOnCreatedByDesc = [[NSSortDescriptor alloc] initWithKey:@"modified" ascending:NO];

    [array sortUsingDescriptors:@[sortOnDayByDesc, sortOnCreatedByDesc]];
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

    NSString *day = [YGTools stringFromAbsoluteDate:operation.day];
    NSNumber *day_unix = [NSNumber numberWithDouble:[operation.day timeIntervalSince1970]];
    NSString *created = [YGTools stringFromLocalDate:operation.created];
    NSNumber *created_unix = [NSNumber numberWithDouble:[operation.created timeIntervalSince1970]];
    NSString *modified = [YGTools stringFromLocalDate:operation.modified];
    NSNumber *modified_unix = [NSNumber numberWithDouble:[operation.modified timeIntervalSince1970]];

    NSString *comment = operation.comment;
    NSString *uuid = [operation.uuid UUIDString];
    
    @try {
        
        NSArray *operationArr = [NSArray arrayWithObjects:
                                 operation_type_id,
                                 source_id,
                                 target_id,
                                 source_sum,
                                 source_currency_id,
                                 target_sum,
                                 target_currency_id,
                                 day,
                                 day_unix,
                                 created,
                                 created_unix,
                                 modified,
                                 modified_unix,
                                 comment ? comment : [NSNull null],
                                 uuid,
                                 nil];
        
        // sql string
        NSString *insertSQL = @"INSERT INTO operation (operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, day_unix, created, created_unix, modified, modified_unix, comment, uuid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        
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


/**
 Update operations in db and memory cache. Write object as is, without any modifications.
 
 */
- (void)updateOperation:(YGOperation *)operation{
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE operation SET operation_type_id=%@, source_id=%@, target_id=%@, source_sum=%@, source_currency_id=%@, target_sum=%@, target_currency_id=%@, day=%@, day_unix=%@, created=%@, created_unix=%@, modified=%@, modified_unix=%@, comment=%@, uuid=%@ WHERE operation_id=%@;",
                           [YGTools sqlStringForInt:operation.type],
                           [YGTools sqlStringForInt:operation.sourceId],
                           [YGTools sqlStringForInt:operation.targetId],
                           [YGTools sqlStringForDecimal:operation.sourceSum],
                           [YGTools sqlStringForInt:operation.sourceCurrencyId],
                           [YGTools sqlStringForDecimal:operation.targetSum],
                           [YGTools sqlStringForInt:operation.targetCurrencyId],
                           [YGTools sqlStringForDateAbsoluteOrNull:operation.day],
                           [YGTools sqlStringForDouble:[operation.day timeIntervalSince1970]],
                           [YGTools sqlStringForDateLocalOrNull:operation.created],
                           [YGTools sqlStringForDouble:[operation.created timeIntervalSince1970]],
                           [YGTools sqlStringForDateLocalOrNull:operation.modified],
                           [YGTools sqlStringForDouble:[operation.modified timeIntervalSince1970]],
                           [YGTools sqlStringForStringOrNull:operation.comment],
                           [YGTools sqlStringForStringNotNull:[operation.uuid UUIDString]],
                           [YGTools sqlStringForInt:operation.rowId]
                           ];
    
    [_sqlite execSQL:updateSQL];
    
    // update memory cache
    YGOperation *replacedOperation = [self operationById:operation.rowId];
    NSUInteger index = [self.operations indexOfObject:replacedOperation];
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

    NSPredicate *operPredicate = [NSPredicate predicateWithFormat:@"(type = 2 AND sourceId = %ld) OR (type = 1 AND targetId = %ld) OR (type = 4 AND (sourceId = %ld OR targetId = %ld))", accountId, accountId, accountId, accountId];
    
    return [self.operations filteredArrayUsingPredicate:operPredicate];
}


- (NSArray <YGOperation *> *)operationsWithAccountId:(NSInteger)accountId sinceAccountActual:(YGOperation *)operation {
    
    NSPredicate *operPredicate = [NSPredicate predicateWithFormat:@"(day >= %@ AND modified >= %@) AND ((type = 2 AND sourceId = %ld) OR (type = 1 AND targetId = %ld) OR (type = 4 AND (sourceId = %ld OR targetId = %ld)))", operation.day, operation.modified, accountId, accountId, accountId, accountId];
    
    return [self.operations filteredArrayUsingPredicate:operPredicate];
}


- (NSArray <YGOperation *> *)operationsWithTargetId:(NSInteger)targetId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation WHERE target_id=%ld ORDER BY created_unix DESC;", (long)targetId];

    return [self operationsBySqlQuery:sqlQuery];
}


- (NSArray <YGOperation *> *)operationsOfType:(YGOperationType)type withSourceId:(NSInteger)sourceId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation WHERE operation_type_id=%ld AND source_id=%ld ORDER BY created_unix DESC;", (long)type, (long)sourceId];
    
    return [self operationsBySqlQuery:sqlQuery];
}


- (NSArray <YGOperation *> *)listOperations{
    
    NSString *sqlQuery = @"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation ORDER BY created_unix DESC;";
    
    return [self operationsBySqlQuery:sqlQuery];
}


- (NSArray <YGOperation *> *)operationsBySqlQuery:(NSString *)sqlQuery {
    
    NSArray *rawList = [_sqlite selectWithSqlQuery:sqlQuery];
    
    if(rawList){
        
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
            NSDate *day = [arr[8] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[8]];
            NSDate *created = [arr[9] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[9]];
            NSDate *modified = [arr[10] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[10]];
            NSString *comment = [arr[11] isEqual:[NSNull null]] ? nil : arr[11];
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:arr[12]];
            
            YGOperation *operation = [[YGOperation alloc] initWithRowId:rowId type:type sourceId:sourceId targetId:targetId sourceSum:sourceSum sourceCurrencyId:sourceCurrencyId targetSum:targetSum targetCurrencyId:targetCurrencyId day:day created:created modified:modified comment:comment uuid:uuid];
            
            [result addObject:operation];
        }
        
        return [result copy];
    }
    else
        return nil;
}


/**
 Wrapper on operationBySqlQuery:.
 */
- (YGOperation *)lastOperationForType:(YGOperationType)type {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation WHERE operation_type_id=%ld ORDER BY created_unix DESC LIMIT 1;", (long)type];
    
    return [self operationBySqlQuery:sqlQuery];
}


- (YGOperation *)lastOperationOfType:(YGOperationType)type withTargetId:(NSInteger)targetId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id, operation_type_id, source_id, target_id, source_sum, source_currency_id, target_sum, target_currency_id, day, created, modified, comment, uuid FROM operation WHERE operation_type_id=%ld AND target_id=%ld ORDER BY created_unix DESC LIMIT 1;", (long)type, (long)targetId];
    
    return [self operationBySqlQuery:sqlQuery];
}


- (YGOperation *)operationBySqlQuery:(NSString *)sqlQuery {
    
    NSArray *rawList = [_sqlite selectWithSqlQuery:sqlQuery];
    
    if(rawList){
        
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
            NSDate *day = [arr[8] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[8]];
            NSDate *created = [arr[9] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[9]];
            NSDate *modified = [arr[10] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[10]];
            NSString *comment = [arr[11] isEqual:[NSNull null]] ? nil : arr[11];
            NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:arr[12]];
            
            YGOperation *operation = [[YGOperation alloc] initWithRowId:rowId type:type sourceId:sourceId targetId:targetId sourceSum:sourceSum sourceCurrencyId:sourceCurrencyId targetSum:targetSum targetCurrencyId:targetCurrencyId day:day created:created modified:modified comment:comment uuid:uuid];
            
            [result addObject:operation];
        }
        
        if([result count] == 0)
            return nil;
        else if([result count] > 1)
            @throw [NSException exceptionWithName:@"-[YGOperationManager operationBySqlQuery]" reason:[NSString stringWithFormat:@"Undefined choice for operation. Sql query: %@", sqlQuery]  userInfo:nil];
        else
            return [result objectAtIndex:0];
    }
    else
        return nil;
}

@end
