//
//  YYGCategoryRows.h
//  Ledger
//
//  Created by Ян on 14/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYGCategoryRow;

@interface YYGCategoryRows : NSObject

@property (strong, nonatomic, readonly) NSMutableArray <YYGCategoryRow *> *list;

/**
 Init YYGCategoryRows by array of categories.
 @warning categories must be just one type
 
 @categories Array of YGCategory objects.
 
 @return YYGCategoryRows object.
 */
- (instancetype)initWithCategories:(NSArray *)categories;

@end
