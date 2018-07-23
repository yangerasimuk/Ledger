//
//  YYGDebtorsViewModel.m
//  Ledger
//
//  Created by Ян on 20.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDebtorsViewModel.h"
#import "YGCategoryManager.h"

@interface YYGDebtorsViewModel() {
    YGCategoryManager *p_manager;
}
@end

@implementation YYGDebtorsViewModel

- (instancetype)init {
    self = [super init];
    if(self){
        p_manager = [[YGCategoryManager alloc] init];
        _debtors = nil;
        _debtorsLoaded = NO;
    }
    return self;
}

- (void)loadDebtors {
    _debtors = [p_manager categoriesByType:YGCategoryTypeCreditorOrDebtor];
    if([_debtors count] > 0)
        self.debtorsLoaded = YES; //_debtorsLoaded = YES; is not works
}

@end
