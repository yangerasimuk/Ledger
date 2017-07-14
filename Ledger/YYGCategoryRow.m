//
//  YYGCategoryRow.m
//  Ledger
//
//  Created by Ян on 14/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategoryRow.h"
#import "YGCategory.h"

@implementation YYGCategoryRow

- (instancetype)initWithCategory:(YGCategory *)category {
    self = [super init];
    if(self){
        _category = [category copy];
    }
    return self;
}

@end
