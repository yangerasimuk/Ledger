//
//  YGAccountEditController.h
//  Ledger
//
//  Created by Ян on 15/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGEntity, YGCategory;

@interface YGAccountEditController : UITableViewController

@property (strong, nonatomic) YGEntity *account;
@property (copy, nonatomic) YGCategory *currency;
@property (assign, nonatomic) BOOL isNewAccount;

@end
