//
//  YGOperationOneRowCell.h
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGOperation.h"

@interface YGOperationOneRowCell : UITableViewCell

@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *detailText;

@property (assign, nonatomic) YGOperationType type;


@end
