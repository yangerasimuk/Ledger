//
//  YGExpenseParentChoiseController.h
//  Ledger
//
//  Created by Ян on 14/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGExpenseParentChoiseController : UITableViewController

/// Id of expense category for which we choose new parent
@property (assign, nonatomic) NSInteger expenseCategoryId;

/// Source parent id
@property (assign, nonatomic) NSInteger sourceParentId;

/// Target parent id
@property (assign, nonatomic) NSInteger targetParentId;

@end
