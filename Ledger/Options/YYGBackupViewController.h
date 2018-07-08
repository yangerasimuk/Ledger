//
//  YYGBackupViewController.h
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGStorage.h"
#import "YYGBackuper.h"

@interface YYGBackupViewController : UITableViewController <YYGStorageOwning, YYGBackuperOwner>

@property (assign, nonatomic) YYGStorageType storageType;

@end
