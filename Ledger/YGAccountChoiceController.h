//
//  YGAccountChoiceController.h
//  Ledger
//
//  Created by Ян on 19/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGEntity;

typedef NS_ENUM(NSInteger, YGAccountChoiceCustomer){
    YGAccountChoiceCustomerExpense,
    YGAccountChoiceCustomerIncome,
    YGAccountChoiceCustomerAccountActual,
    YGAccountChoiceCustomerTransferSource,
    YGAccountChoiceCustomerTransferTarget
};

@interface YGAccountChoiceController : UITableViewController

@property (assign, nonatomic) YGAccountChoiceCustomer customer;
@property (copy, nonatomic) YGEntity *sourceAccount;
@property (copy, nonatomic) YGEntity *targetAccount;

@end
