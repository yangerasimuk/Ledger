//
//  YYGDebtorCellViewModel.m
//  Ledger
//
//  Created by Ян on 20.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDebtorCellViewModel.h"

@interface YYGDebtorCellViewModel() {
    YGCategory *p_debtor;
}
@end

@implementation YYGDebtorCellViewModel

- (instancetype)initWithDebtor:(YGCategory *)debtor {
    self = [super init];
    if(self){
        p_debtor = debtor;
        _name = debtor.name;
        _isActive = debtor.isActive;
    }
    return self;
}

@end
