//
//  YGEntityManager.h
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGEntity.h"

@class YGOperation;

@interface YGEntityManager : NSObject

+ (instancetype)sharedInstance;

- (void)addEntity:(YGEntity *)entity;

- (YGEntity *)entityById:(NSInteger)entityId;
- (YGEntity *)entityAttachedForType:(YGEntityType)type;
- (YGEntity *)entityOnTopForType:(YGEntityType)type;

- (void)updateEntity:(YGEntity *)entity;
- (void)setOnlyOneDefaultEntity:(YGEntity *)entity;
- (void)deactivateEntity:(YGEntity *)entity;
- (void)activateEntity:(YGEntity *)entity;
- (void)removeEntity:(YGEntity *)entity;

- (NSArray <YGEntity *> *)listEntitiesByType:(YGEntityType)type;
- (NSArray <YGEntity *> *)listEntitiesByType:(YGEntityType)type exceptForId:(NSInteger)exceptId;

- (BOOL)isExistRecordsForEntity:(YGEntity *)entity;

- (void)recalcSumOfAccount:(YGEntity *)entity forOperation:(YGOperation *)operation;

@end
