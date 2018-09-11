//
//  YYGEntitiesViewModel.m
//  Ledger
//
//  Created by Ян on 26.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGEntitiesViewModel.h"
#import "YYGAccountsViewModel.h"
#import "YYGDebtsViewModel.h"
#import "YGCategory.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"

@interface YYGEntitiesViewModel () {
    YGEntityManager *p_entityManager;
    YGCategoryManager *p_categoryManager;
}
@end

@implementation YYGEntitiesViewModel

@synthesize entities = _entities;

+ (id<YYGEntitiesViewModelable>)viewModelWith:(YGEntityType)type {
    id<YYGEntitiesViewModelable> viewModel;
    switch(type){
        case YGEntityTypeAccount:
            viewModel = [[YYGAccountsViewModel alloc] init];
            viewModel.type = YGEntityTypeAccount;
            break;
        case YGEntityTypeDebt:
            viewModel = [[YYGDebtsViewModel alloc] init];
            viewModel.type = YGEntityTypeDebt;
            break;
        default:
            @throw [NSException exceptionWithName:@"YYGEntitiesViewModel.viewModelWith: fails" reason:@"Unknown entity type" userInfo:nil];
    }
    return viewModel;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        p_entityManager = [YGEntityManager sharedInstance];
        p_categoryManager = [YGCategoryManager sharedInstance];
    }
    return self;
}

- (NSString *)currencyNameWithId:(NSInteger)currencyId {
    YGCategory *currency = [p_categoryManager categoryById:currencyId type:YGCategoryTypeCurrency];
    return [currency shorterName];
}

- (NSString *)title {
    @throw [NSException exceptionWithName:@"YYGEntitiesViewModel title fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (NSString *)noDataMessage {
    @throw [NSException exceptionWithName:@"YYGEntitiesViewModel noDataMessage fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (BOOL)showDebtType {
    @throw [NSException exceptionWithName:@"YYGEntitiesViewModel showDebtType fails" reason:@"Method must be realized in subclass." userInfo:nil];
}

- (NSMutableArray<YGEntity *> *)entities {
    if(!_entities){
        _entities = [p_entityManager.entities valueForKey:NSStringFromEntityType(self.type)];
    }
    return _entities;
}

- (BOOL)hasActiveCategoryWith:(YGCategoryType)type {
    NSArray *categories = [p_categoryManager categoriesByType:type onlyActive:YES];
    if([categories count] > 0)
        return YES;
    else
        return NO;
}

@end
