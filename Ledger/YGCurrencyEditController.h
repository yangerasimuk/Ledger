//
//  YGCurrencyEditController.h
//  Ledger
//
//  Created by Ян on 01/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCategory.h"

@interface YGCurrencyEditController : UITableViewController

@property (copy, nonatomic) YGCategory *currency;
@property (assign, nonatomic) BOOL isNewCurrency;
@property (assign, nonatomic) YGCategoryType categoryType;

@end
