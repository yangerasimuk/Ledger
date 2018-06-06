//
//  YGOperationManager.h
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGOperation.h"

@protocol OperationSectionProtocol
- (void)addOperation:(YGOperation *)operation;
- (void)updateOperation:(YGOperation *)oldOperation withNew:(YGOperation *)newOperation;
- (void)removeOperation:(YGOperation *)operation;
@end

@interface YGOperationManager : NSObject

@property (assign, nonatomic) BOOL hideDecimalFraction;

@property (strong, nonatomic) NSMutableArray <YGOperation *> *operations;
@property (weak, nonatomic) id<OperationSectionProtocol> sectionDelegate;

+ (instancetype)sharedInstance;

- (NSInteger)addOperation:(YGOperation *)operation;

- (YGOperation *)lastOperationForType:(YGOperationType)type;

/**
 For reculc sum of account
 */
- (YGOperation *)lastOperationOfType:(YGOperationType)type withTargetId:(NSInteger)targetId;

- (void)updateOperation:(YGOperation *)oldOperation withNew:(YGOperation *)newOperation;

- (void)removeOperation:(YGOperation *)operation;

- (NSArray <YGOperation *> *)listOperations;

/**
 For reculc sum of account
 */
- (NSArray <YGOperation *> *)operationsWithTargetId:(NSInteger)targetId;
//- (NSArray <YGOperation *> *)operationsOfType:(YGOperationType)type withSourceId:(NSInteger)sourceId;
- (NSArray <YGOperation *> *)operationsWithAccountId:(NSInteger)accountId;


- (NSArray <YGOperation *> *)operationsWithAccountId:(NSInteger)accountId sinceAccountActual:(YGOperation *)accountActual;





@end
