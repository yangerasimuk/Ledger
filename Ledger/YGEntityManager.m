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

@interface YGEntityManager (){
    YGSQLite *_sqlite;
}
- (NSArray <YGEntity *> *)entitiesFromDb;
- (NSMutableDictionary <NSString *, NSMutableArray <YGEntity *> *> *)entitiesForCache;
- (void)sortEntitiesInArray:(NSMutableArray <YGEntity *>*)array;
- (NSInteger)idAddEntity:(YGEntity *)entity;
@end

@implementation YGEntityManager

@synthesize entities = _entities;

#pragma mark - Singleton, init & accessors

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
        _entities = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (NSMutableDictionary <NSString *, NSMutableArray <YGEntity *> *> *)entities {

    if([_entities count] == 0) {
        _entities = [self entitiesForCache];
    }
    return _entities;
}

#pragma mark - Inner methods for memory cache process

- (NSArray <YGEntity *> *)entitiesFromDb {
    
    NSString *sqlQuery = @"SELECT entity_id, entity_type_id, name, owner_id, sum, currency_id, active, active_from, active_to, attach, sort, comment FROM entity ORDER BY active DESC, sort ASC;";
    
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
        
        [result addObject:entity];
    }
    
    return [result copy];
}


- (NSMutableDictionary <NSString *, NSMutableArray <YGEntity *> *> *)entitiesForCache {
    
    NSArray *entitiesRaw = [self entitiesFromDb];
    
    NSMutableDictionary <NSString *, NSMutableArray <YGEntity *> *> *entitiesResult = [[NSMutableDictionary alloc] init];
    
    NSString *typeString = nil;
    for(YGEntity *entity in entitiesRaw){
        
        typeString = NSStringFromEntityType(entity.type);
        
        if([entitiesResult valueForKey:typeString]){
            [[entitiesResult valueForKey:typeString] addObject:entity];
        }
        else{
            [entitiesResult setValue:[[NSMutableArray alloc] init] forKey:typeString];
            [[entitiesResult valueForKey:typeString] addObject:entity];
        }
        
    }
    
    // sort entities in each inner array
    NSArray *types = [entitiesResult allKeys];
    for(NSString *type in types)
        [self sortEntitiesInArray:entitiesResult[type]];
    
    return entitiesResult;
}



/**
 @warning It will be better if in table entities we have colomn date_unix for sort.
 */
- (void)sortEntitiesInArray:(NSMutableArray <YGEntity *>*)array {
    
    NSSortDescriptor *sortOnActiveByDesc = [[NSSortDescriptor alloc] initWithKey:@"active" ascending:NO];
    NSSortDescriptor *sortOnSortByAsc = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortOnActiveFromByAsc = [[NSSortDescriptor alloc] initWithKey:@"activeFrom"  ascending:YES];
    
    [array sortUsingDescriptors:@[sortOnActiveByDesc, sortOnSortByAsc, sortOnActiveFromByAsc]];
}


#pragma mark - Actions on entity(s)

- (NSInteger)idAddEntity:(YGEntity *)entity {
    
    NSInteger rowId = -1;
    
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
        rowId = [_sqlite addRecord:entityArr insertSQL:insertSQL];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", [exception description]);
    }
    @finally {
        return rowId;
    }
}



#pragma mark - Extern methods - Actions on one entity

- (void)addEntity:(YGEntity *)entity{
    
    // add entity to db
    NSInteger rowId = [self idAddEntity:entity];
    YGEntity *newEntity = [entity copy];
    newEntity.rowId = rowId;
    
    // add entity to memory cache
    [[_entities valueForKey:NSStringFromEntityType(newEntity.type)] addObject:newEntity];
    [self sortEntitiesInArray:[_entities valueForKey:NSStringFromEntityType(newEntity.type)]];
}


#warning May be throw exception when return array count > 1?
- (YGEntity *)entityById:(NSInteger)entityId type:(YGEntityType)type {
    
    NSArray <YGEntity *> *entitiesByType = [_entities valueForKey:NSStringFromEntityType(type)];
    
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"rowId = %ld", entityId];
    
    return [[entitiesByType filteredArrayUsingPredicate:idPredicate] firstObject];
}



#warning Is entity needs to update in inner storage?
/**
 @warning It seems entity updated in EditController edit by reference, so...
 */
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


- (void)deactivateEntity:(YGEntity *)entity{
    
    NSString *activeTo = [YGTools stringFromDate:[NSDate date]];

    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET active=0, active_to='%@' WHERE entity_id=%ld;", activeTo, entity.rowId];
    
    [_sqlite execSQL:updateSQL];

    // update memory cache
    NSMutableArray <YGEntity *> *entitiesByType = [_entities valueForKey:NSStringFromEntityType(entity.type)];
    YGEntity *updateEntity = [entitiesByType objectAtIndex:[entitiesByType indexOfObject:entity]];
    updateEntity.active = NO;
    updateEntity.activeTo = [YGTools dateFromString:activeTo];
    
    // sort memory cache
    [self sortEntitiesInArray:entitiesByType];
}

- (void)activateEntity:(YGEntity *)entity{
    
    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET active=1, active_to=NULL WHERE entity_id=%ld;", entity.rowId];
    
    [_sqlite execSQL:updateSQL];
    
    // update memory cache
    NSMutableArray <YGEntity *> *entitiesByType = [_entities valueForKey:NSStringFromEntityType(entity.type)];
    YGEntity *updateEntity = [entitiesByType objectAtIndex:[entitiesByType indexOfObject:entity]];
    updateEntity.active = YES;
    updateEntity.activeTo = nil;
    
    [self sortEntitiesInArray:entitiesByType];
}

- (void)removeEntity:(YGEntity *)entity{
    
    // update db
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM entity WHERE entity_id = %ld;", entity.rowId];
    
    [_sqlite removeRecordWithSQL:deleteSQL];
    
    // update memory cache
    NSMutableArray <YGEntity *> *entitiesByType = [_entities valueForKey:NSStringFromEntityType(entity.type)];
    [entitiesByType removeObject:entity];
}


/**
 Return only one attached entity for type. Terms for entity: equals type, active, attach, and must be only one. Else return nil.
 
 */
- (YGEntity *)entityAttachedForType:(YGEntityType)type {
    
    NSArray <YGEntity *> *entitiesByType = [_entities valueForKey:NSStringFromEntityType(type)];
    
    NSPredicate *attachPredicate = [NSPredicate predicateWithFormat:@"active = YES && attach = YES"];
    
    NSArray <YGEntity *> *entitiesResult = [entitiesByType filteredArrayUsingPredicate:attachPredicate];
    
    if(entitiesResult && [entitiesResult count] > 0)
        return [entitiesResult firstObject];
    else
        return nil;
}

/**
 NSString *sqlQuery = [NSString stringWithFormat:@"SELECT entity_id, entity_type_id, name, owner_id, sum, currency_id, active, active_from, active_to, attach, sort, comment  FROM entity WHERE entity_type_id = %ld AND active = %d ORDER BY sort ASC LIMIT 1;", type, YGBooleanValueYES];
 */
- (YGEntity *)entityOnTopForType:(YGEntityType)type {
    
    NSArray <YGEntity *> *entitiesByType = [_entities valueForKey:NSStringFromEntityType(type)];
    
    NSPredicate *attachPredicate = [NSPredicate predicateWithFormat:@"active = YES"];
    
    NSArray <YGEntity *> *entitiesResult = [entitiesByType filteredArrayUsingPredicate:attachPredicate];
    
    if(entitiesResult && [entitiesResult count] > 0)
        return [entitiesResult firstObject];
    else
        return nil;
}



- (void)setOnlyOneDefaultEntity:(YGEntity *)entity {
    
    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET attach=0 WHERE entity_type_id = %ld AND entity_id != %ld;",
                           entity.type,
                           entity.rowId];
    
    [_sqlite execSQL:updateSQL];
    
    // update inner storage
    NSPredicate *unAttachedPredicate = [NSPredicate predicateWithFormat:@"type = %ld && rowId != %ld", entity.type, entity.rowId];
    
    NSArray <YGEntity *> *updateEntities = [[_entities valueForKey:NSStringFromEntityType(entity.type)]filteredArrayUsingPredicate:unAttachedPredicate];
    
    for(YGEntity *ent in updateEntities){
        ent.attach = NO;
    }
}




#pragma mark - Extern methods - Getting lists of entitites

- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type onlyActive:(BOOL)onlyActive exceptEntity:(YGEntity *)exceptEntity {
    
    NSArray <YGEntity *> *entitiesResult = [_entities valueForKey:NSStringFromEntityType(type)];
    
    if(onlyActive){
        NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"active = YES"];
        entitiesResult = [entitiesResult filteredArrayUsingPredicate:activePredicate];
    }
    
    if(exceptEntity){
        NSPredicate *exceptPredicate = [NSPredicate predicateWithFormat:@"rowId != %ld", exceptEntity.rowId];
        entitiesResult = [entitiesResult filteredArrayUsingPredicate:exceptPredicate];
    }
    
    return entitiesResult;
}

- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type onlyActive:(BOOL)onlyActive {
    
    return [self entitiesByType:type onlyActive:onlyActive exceptEntity:nil];
}

- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type {
    
    return [self entitiesByType:type onlyActive:NO exceptEntity:nil];
}




#pragma mark - Working with Operations: reculc and check of exist operations for entity

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
        // update db
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET sum=%@ WHERE entity_id=%@;",
                               [YGTools sqlStringForDecimal:targetSum],
                               [YGTools sqlStringForIntOrNull:account.rowId]];
        
        [_sqlite execSQL:updateSQL];
        
        // update memory cache
        NSMutableArray <YGEntity *> *entitiesByType = [_entities valueForKey:NSStringFromEntityType(YGEntityTypeAccount)];
        YGEntity *updateAccount = [entitiesByType objectAtIndex:[entitiesByType indexOfObject:account]];
        updateAccount.sum = targetSum;
    }
}


- (BOOL)isExistLinkedOperationsForEntity:(YGEntity *)entity {
    
    if(entity.type == YGEntityTypeAccount){
        
        // search in operations
        NSString *selectSql = [NSString stringWithFormat:@"SELECT operation_id FROM operation "
                               "WHERE "
                               "(operation_type_id IN (%ld,%ld,%ld,%ld,%ld) AND source_id = %ld) OR "
                               "(operation_type_id IN (%ld,%ld,%ld,%ld,%ld) AND target_id = %ld) "
                               "LIMIT 1;",
                               YGOperationTypeExpense, YGOperationTypeAccountActual, YGOperationTypeTransfer, YGOperationTypeReturnCredit, YGOperationTypeGiveDebt, entity.rowId,
                               YGOperationTypeIncome, YGOperationTypeAccountActual, YGOperationTypeTransfer, YGOperationTypeGetCredit, YGOperationTypeReturnDebt, entity.rowId
                               ];
        
        NSArray *classes = [NSArray arrayWithObjects:[NSNumber class], nil];
        
        NSArray *categories = [_sqlite selectWithSqlQuery:selectSql bindClasses:classes];
        
        if([categories count] > 0)
            return YES;
        
    }
    
    return NO;
}


@end