//
//  YGExpenseCategoryEditController.h
//  Ledger
//
//  Created by Ян on 14/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCategory.h"

@interface YGExpenseCategoryEditController : UITableViewController

// ? for what?
@property (assign, nonatomic) YGCategoryType categoryType;
@property (copy, nonatomic) YGCategory *expenseCategory;
@property (copy, nonatomic) YGCategory *expenseParent;
@property (assign, nonatomic) BOOL isNewExpenseCategory;

@end
