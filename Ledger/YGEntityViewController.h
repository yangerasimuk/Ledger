//
//  YGEntityViewController.h
//  Ledger
//
//  Created by Ян on 15/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

/*
 Контроллер отвечает за работу со списком Entity (Сущностей): счета, долги и т.д.
 */

#import <UIKit/UIKit.h>
#import "YGEntity.h"

@interface YGEntityViewController : UITableViewController

@property (assign, nonatomic) YGEntityType type;

@end
