//
//  YYGCategoryRows.m
//  Ledger
//
//  Created by Ян on 14/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

/*
 Class responsible to cache rows for category lists.
 */

#import "YYGCategoryRows.h"
#import "YYGCategoryRow.h"
#import "YGCategoryManager.h"

@interface YYGCategoryRows(){
    NSArray *p_categories;
    
    YGCategoryManager *p_manager;
}

@end

@implementation YYGCategoryRows

- (instancetype)initWithCategories:(NSArray *)categories {
    self = [super init];
    if(self){
        p_manager = [YGCategoryManager sharedInstance];
        
        p_categories = categories;
        
        _list = [self rowsFromCategories:p_categories];
    }
    return self;
}

- (NSMutableArray <YYGCategoryRow *> *)rowsFromCategories:(NSArray <YGCategory *>*)categories {
    
    // check if categories tree or plain
    NSPredicate *treePredicate = [NSPredicate predicateWithFormat:@"parentId > 0"];
    NSArray *nestedCategories = [categories filteredArrayUsingPredicate:treePredicate];
    
    if([nestedCategories count] > 0){
        return [self categoryRowsAsTreeFromCategories:categories];
    }
    else{
        return [self categoryRowsAsListFromCategories:categories];
    }
    
}

- (NSMutableArray <YYGCategoryRow *> *)categoryRowsAsTreeFromCategories:(NSArray <YGCategory *>*)categories {
    
    NSMutableArray *categoryRowsArray = [NSMutableArray array];
    
    return categoryRowsArray;
}

- (NSMutableArray <YYGCategoryRow *> *)categoryRowsAsListFromCategories:(NSArray <YGCategory *>*)categories {
    
    NSMutableArray *categoryRowsArray = [NSMutableArray array];
    
    for(YGCategory *c in categories)
        [categoryRowsArray addObject:[self rowCachedCategory:c]];

    return categoryRowsArray;
}

- (YYGCategoryRow *)rowCachedCategory:(YGCategory *)category {
    
    YYGCategoryRow *row = [[YYGCategoryRow alloc] initWithCategory:category];
    
    row.name = category.name;
    
    if(category.type == YGCategoryTypeCurrency)
        row.symbol = category.symbol;
    row.nestedLevel = 0;
    
    return row;
}
         

@end
