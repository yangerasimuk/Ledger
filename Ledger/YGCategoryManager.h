//
//  YGCategoryManager.h
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCategory.h"

@interface YGCategoryManager : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init;

- (void)addCategory:(YGCategory *)category;
- (YGCategory *)categoryById:(NSInteger)categoryId;
- (YGCategory *)categoryAttachedForType:(YGCategoryType)type;
- (YGCategory *)categoryOnTopForType:(YGCategoryType)type;
- (void)updateCategory:(YGCategory *)category;
- (void)setOnlyOneDefaultCategory:(YGCategory *)category;
- (void)deactivateCategory:(YGCategory *)category;
- (void)activateCategory:(YGCategory *)category;
- (void)removeCategoryWithId:(NSInteger)rowId;
- (void)removeCategory:(YGCategory *)category;

- (BOOL)isExistRecordsForCategory:(YGCategory *)category;

- (NSArray <YGCategory *> *)listCategoriesByType:(YGCategoryType)type;
- (NSArray <YGCategory *> *)listCategoriesByType:(YGCategoryType)type exceptForId:(NSInteger)categoryId;

@end
