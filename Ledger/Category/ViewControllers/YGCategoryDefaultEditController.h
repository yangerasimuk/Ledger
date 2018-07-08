//
//  YGCategoryDefaultEditController.h
//  Ledger
//
//  Created by Ян on 14/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCategory.h"

@interface YGCategoryDefaultEditController : UITableViewController

@property (assign, nonatomic) YGCategoryType categoryType;
@property (assign, nonatomic) BOOL isNewCategory;
@property (copy, nonatomic) YGCategory *category;

@end
