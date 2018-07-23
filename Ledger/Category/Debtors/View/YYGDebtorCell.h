//
//  YYGDebtorCell.h
//  Ledger
//
//  Created by Ян on 20.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGDebtorCellViewModel.h"

@interface YYGDebtorCell : UITableViewCell

@property (strong, nonatomic) YYGDebtorCellViewModel *viewModel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)identifier;

@end
