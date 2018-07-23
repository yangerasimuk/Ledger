//
//  YYGDebtorCellViewModel.h
//  Ledger
//
//  Created by Ян on 20.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCategory.h"

@interface YYGDebtorCellViewModel : NSObject

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL isActive;

- (instancetype)initWithDebtor:(YGCategory *)debtor;

@end
