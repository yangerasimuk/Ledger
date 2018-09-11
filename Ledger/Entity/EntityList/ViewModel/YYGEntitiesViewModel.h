//
//  YYGEntitiesViewModel.h
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGEntity.h"
#import "YGCategory.h"

@protocol YYGEntitiesViewModelable

@property (assign, nonatomic) YGEntityType type;
@property (strong, nonatomic) NSMutableArray<YGEntity *> *entities;

- (NSString *)title;
- (NSString *)noDataMessage;
- (NSString *)currencyNameWithId:(NSInteger)currencyId;
- (BOOL)isEnoughConditionsWithFeedback:(void(^)(NSString *message))feedback;
- (BOOL)showDebtType;
@end

@interface YYGEntitiesViewModel : NSObject <YYGEntitiesViewModelable>

+ (id<YYGEntitiesViewModelable>)viewModelWith:(YGEntityType)type;

@property (assign, nonatomic) YGEntityType type;

- (instancetype)init;

- (NSString *)currencyNameWithId:(NSInteger)currencyId;
- (BOOL)hasActiveCategoryWith:(YGCategoryType)type;
@end
