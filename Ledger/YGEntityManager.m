//
//  YGEntityManager.m
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGEntityManager.h"
#import "YGSQLite.h"
#import "YGTools.h"
#import "YGOperationManager.h"

#define YGBooleanValueNO    0
#define YGBooleanValueYES   1

@interface YGEntityManager (){
    YGSQLite *_sqlite;
}

- (YGEntity *)entityBySqlQuery:(NSString *)sqlQuery;

@end

@implementation YGEntityManager

#pragma mark - Init

+ (instancetype)sharedInstance{
    static YGEntityManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YGEntityManager alloc] init];
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

#pragma mark - Actions on entity(s)

- (void)addEntity:(YGEntity *)entity{
    
    @try {
        
        NSArray *entityArr = [NSArray arrayWithObjects:
                              [NSNumber numberWithInteger:entity.type], // entity_type_id
                              entity.name ? entity.name : [NSNull null], // name
                              entity.ownerId != -1 ? [NSNumber numberWithInteger:entity.ownerId] : [NSNull null], // owner_id
                              [NSNumber numberWithDouble:entity.sum], // sum
                              [NSNumber numberWithInteger:entity.currencyId], //currencyId
                              [NSNumber numberWithBool:entity.isActive], // active
                              [YGTools stringFromDate:entity.activeFrom], // active_from,
                              entity.activeTo ? [YGTools stringFromDate:entity.activeTo] : [NSNull null], // active_to,
                              [NSNumber numberWithBool:entity.isAttach], // attach,
                              [NSNumber numberWithInteger:entity.sort], // sort,
                              entity.comment ? entity.comment : [NSNull null], //comment,
                              nil];
        
        NSString *insertSQL = @"INSERT INTO entity (entity_type_id, name, owner_id, sum, currency_id, active, active_from, active_to, attach, sort, comment) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        
        // db
        [_sqlite addRecord:entityArr insertSQL:insertSQL];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", [exception description]);
    }
    
}

- (YGEntity *)entityById:(NSInteger)entityId {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT entity_id, entity_type_id, name, owner_id, sum, currency_id, active, active_from, active_to, attach, sort, comment  FROM entity WHERE entity_id = %ld;", entityId];
    
    return [self entityBySqlQuery:sqlQuery];
}

/**
 Return only one attached entity for type. Terms for entity: equals type, active, attach, and must be only one. Else return nil.
 
 */
- (YGEntity *)entityAttachedForType:(YGEntityType)type {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT entity_id, entity_type_id, name, owner_id, sum, currency_id, active, active_from, active_to, attach, sort, comment  FROM entity WHERE entity_type_id = %ld AND active = %d AND attach = %d;", type, YGBooleanValueYES, YGBooleanValueYES];
    
    return [self entityBySqlQuery:sqlQuery];
}

- (YGEntity *)entityOnTopForType:(YGEntityType)type {
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT entity_id, entity_type_id, name, owner_id, sum, currency_id, active, active_from, active_to, attach, sort, comment  FROM entity WHERE entity_type_id = %ld AND active = %d ORDER BY sort ASC LIMIT 1;", type, YGBooleanValueYES];
    
    return [self entityBySqlQuery:sqlQuery];
}


/**
 Inner func for entityById:, entity
 */
- (YGEntity *)entityBySqlQuery:(NSString *)sqlQuery {
    
    NSMutableArray <YGEntity *> *result = [[NSMutableArray alloc] init];
    
    NSArray *classes = [NSArray arrayWithObjects:
                        [NSNumber class], // entity_id
                        [NSNumber class], // entity_type_id
                        [NSString class], // name
                        [NSNumber class], // owner_id
                        [NSNumber class], // sum
                        [NSNumber class], // currency_id
                        [NSNumber class], // active
                        [NSString class], // active_from
                        [NSString class], // active_to
                        [NSNumber class], // attach
                        [NSNumber class], // sort
                        [NSString class], // comment
                        nil];
    
    YGSQLite *sql = [YGSQLite sharedInstance];
    
    NSArray *rawCategories = [sql selectWithSqlQuery:sqlQuery bindClasses:classes];
    
    for(NSArray *arr in rawCategories){
        
        NSInteger rowId = [arr[0] integerValue];
        YGEntityType type = [arr[1] integerValue];
        NSString *name = arr[2];
        NSInteger ownerId = arr[3] > 0 ? [arr[3] integerValue] : -1;
        NSInteger sum = [arr[4] integerValue];
        NSInteger currencyId = [arr[5] integerValue];
        BOOL active = [arr[6] boolValue];
        NSDate *activeFrom = [YGTools dateFromString:arr[7]];
        NSDate *activeTo = [arr[8] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[8]];
        BOOL attach = [arr[9] boolValue];
        NSInteger sort = [arr[10] integerValue];
        NSString *comment = [arr[11] isEqual:[NSNull null]] ? nil : arr[11];
        
        YGEntity *entity = [[YGEntity alloc] initWithRowId:rowId type:type name:name ownerId:ownerId sum:sum currencyId:currencyId active:active activeFrom:activeFrom activeTo:activeTo attach:attach sort:sort comment:comment];
        
        [result addObject:entity];
    }
    
    if([result count] == 0)
        return nil;
    else if([result count] > 1)
        @throw [NSException exceptionWithName:@"-[YGEntityManager entityBySqlQuery]" reason:[NSString stringWithFormat:@"Undefined choice for entity. Sql query: %@", sqlQuery]  userInfo:nil];
    else
        return [result objectAtIndex:0];
}


- (void)updateEntity:(YGEntity *)entity{
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET entity_type_id=%@, name=%@, owner_id=%@, sum=%@, currency_id=%@, active=%@, active_from=%@, active_to=%@, attach=%@, sort=%@, comment=%@ WHERE entity_id=%@;",
                           [YGTools sqlStringForIntOrNull:entity.type],
                           [YGTools sqlStringForStringOrNull:entity.name],
                           [YGTools sqlStringForIntOrNull:entity.ownerId],
                            [YGTools sqlStringForDecimal:entity.sum],
                           [YGTools sqlStringForIntOrNull:entity.currencyId],
                           [YGTools sqlStringForBool:entity.isActive],
                           [YGTools sqlStringForDateOrNull:entity.activeFrom],
                           [YGTools sqlStringForDateOrNull:entity.activeTo],
                           [YGTools sqlStringForBool:entity.attach],
                            [YGTools sqlStringForIntOrDefault:entity.sort],
                           [YGTools sqlStringForStringOrNull:entity.comment],
                           [YGTools sqlStringForIntOrNull:entity.rowId]];
    

    [_sqlite execSQL:updateSQL];
}


- (void)setOnlyOneDefaultEntity:(YGEntity *)entity {
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET attach=0 WHERE entity_type_id = %ld AND entity_id != %ld;",
                           entity.type,
                           entity.rowId];
    
    [_sqlite execSQL:updateSQL];
}


- (void)deactivateEntity:(YGEntity *)entity{

    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET active=0, active_to='%@' WHERE entity_id=%ld;", [YGTools stringFromDate:[NSDate date]], entity.rowId];
    
    [_sqlite execSQL:updateSQL];
}

- (void)activateEntity:(YGEntity *)entity{
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET active=1, active_to=NULL WHERE entity_id=%ld;", entity.rowId];
    
    [_sqlite execSQL:updateSQL];
}

- (void)removeEntity:(YGEntity *)entity{
    
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM entity WHERE entity_id = %ld;", entity.rowId];
    
    [_sqlite removeRecordWithSQL:deleteSQL];
}

- (NSArray <YGEntity *> *)listEntitiesByType:(YGEntityType)type exceptForId:(NSInteger)exceptId {
    
    NSString *sqlQuery = nil;
    
    if(exceptId == -1){
        sqlQuery = [NSString stringWithFormat:@"SELECT entity_id, entity_type_id, name, owner_id, sum, currency_id, active, active_from, active_to, attach, sort, comment FROM entity WHERE entity_type_id = %ld ORDER BY active DESC, sort ASC;", type];
    }
    else{
        sqlQuery = [NSString stringWithFormat:@"SELECT entity_id, entity_type_id, name, owner_id, sum, currency_id, active, active_from, active_to, attach, sort, comment FROM entity WHERE entity_type_id = %ld AND entity_id != %ld ORDER BY active DESC, sort ASC;", type, exceptId];

    }
    
    NSArray *classes = [NSArray arrayWithObjects:
                        [NSNumber class],   // entity_id
                        [NSNumber class],   // entity_type_id
                        [NSString class],   // name
                        [NSNumber class],   // owner_id
                        [NSNumber class],   // sum
                        [NSNumber class],   // currency_id
                        [NSNumber class],   // active
                        [NSString class],   // active_from
                        [NSString class],   // active_to
                        [NSNumber class],   // attach
                        [NSNumber class],   // sort
                        [NSString class],   // comment
                        nil];
    
    NSArray *rawList = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
    
    NSMutableArray <YGEntity *> *result = [[NSMutableArray alloc] init];
    
    for(NSArray *arr in rawList){
        
        NSInteger rowId = [arr[0] integerValue];
        YGEntityType type = [arr[1] integerValue];
        NSString *name = [arr[2] isEqual:[NSNull null]] ? nil : arr[2];
        NSInteger ownerId = [arr[3] integerValue];
        double sum = [arr[4] doubleValue];
        NSInteger currencyId = [arr[5] integerValue];
        BOOL active = [arr[6] boolValue];
        NSDate *activeFrom = [arr[7] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[7]];
        NSDate *activeTo = [arr[8] isEqual:[NSNull null]] ? nil : [YGTools dateFromString:arr[8]];
        BOOL attach = [arr[9] boolValue];
        NSInteger sort = [arr[10] integerValue];
        NSString *comment = [arr[11] isEqual:[NSNull null]] ? nil : arr[11];
        
        YGEntity *entity = [[YGEntity alloc] initWithRowId:rowId type:type name:name ownerId:ownerId  sum:sum currencyId:currencyId active:active activeFrom:activeFrom activeTo:activeTo attach:attach sort:sort comment:comment];
        
        //NSLog(@"%@", [entity description]);
        
        [result addObject:entity];
    }
    
    return [result copy];
}

- (NSArray <YGEntity *> *)listEntitiesByType:(YGEntityType)type{
    return [self listEntitiesByType:type exceptForId:-1];
}


- (void)recalcSumOfAccount:(YGEntity *)account forOperation:(YGOperation *)operation {
    
    // check for entity type
    if(account.type != YGEntityTypeAccount)
        @throw [NSException exceptionWithName:@"-[YGEntityManager recalcSumOfAccount:forOperation" reason:@"Recalc can not be made for this entity type" userInfo:nil];
    
    // check for operation type
    if(operation.type == YGOperationTypeAccountActual)
        @throw [NSException exceptionWithName:@"-[YGEntityManager recalcSumOfAccount:forOperation" reason:@"Recalc can not be made for this operation type" userInfo:nil];
    
    // check for more near date of actual account operation
    YGOperationManager *om = [YGOperationManager sharedInstance];
    YGOperation *lastActualAccount = [om lastOperationOfType:YGOperationTypeAccountActual withTargetId:account.rowId];
    
    if(lastActualAccount){
        if([lastActualAccount.date compare:operation.date] == NSOrderedDescending){
            NSLog(@"Exist more latest operation of actual for this account, recalc for sum for the account do not need");
            return;
        }
    }
    
    // get source sum
    double targetSum = 0.0;
    
    if(lastActualAccount)
        targetSum = lastActualAccount.targetSum;
    
    //NSArray <YGOperation *>*operations = [om operationsWithTargetId:account.rowId];
    NSArray <YGOperation *>*operations = [om operationsWithAccountId:account.rowId];
    
    if([operations count] > 0){
        for(YGOperation *oper in operations){
            if(oper.type == YGOperationTypeIncome){
                targetSum += oper.targetSum;
            }
            else if(oper.type == YGOperationTypeExpense){
                targetSum -= oper.sourceSum;
            }
            else if(oper.type == YGOperationTypeTransfer){
                if(oper.sourceId == account.rowId){
                    targetSum -= oper.sourceSum;
                }
                else if(oper.targetId == account.rowId){
                    targetSum += oper.targetSum;
                }
                else{
                    @throw [NSException exceptionWithName:@"-[YGEntityManager recalcSumOfAccount:forOperation:" reason:@"Calc behavior for this transfer" userInfo:nil];
                }
            }
            else if(oper.type == YGOperationTypeAccountActual){
                ;
            }
            else
                @throw [NSException exceptionWithName:@"-[YGEntityManager recalcSumOfAccount:forOperation:" reason:@"Calc behavior for this type of operation does not implement" userInfo:nil];
        }
    }

    // is account needs to update?
    if(account.sum != targetSum){
        // save to db
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET sum=%@ WHERE entity_id=%@;",
                               [YGTools sqlStringForDecimal:targetSum],
                               [YGTools sqlStringForIntOrNull:account.rowId]];
        
        [_sqlite execSQL:updateSQL];
    }
}



- (BOOL)isExistRecordsForEntity:(YGEntity *)entity {
    
    if(entity.type == YGEntityTypeAccount){
        
        // in operations
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT operation_id FROM operation WHERE source_id = %ld OR target_id = %ld LIMIT 1;", entity.rowId, entity.rowId];
        NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
        
        NSArray *categories = [_sqlite selectWithSqlQuery:sqlQuery bindClasses:classes];
        
        if([categories count] > 0)
            return YES;
    }
    return NO;
}


@end
