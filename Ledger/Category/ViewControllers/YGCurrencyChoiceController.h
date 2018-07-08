//
//  YGCurrencyChoiceController.h
//  Ledger
//
//  Created by Ян on 15/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCategory.h"

@interface YGCurrencyChoiceController : UITableViewController

/// currencyId from main form
@property (copy, nonatomic) YGCategory *sourceCurrency;

/// currencyId choosen by user on current form
@property (copy, nonatomic) YGCategory *targetCurrency;

@end
