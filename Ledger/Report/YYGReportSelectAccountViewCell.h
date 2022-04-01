//
//  YYGReportSelectAccountViewCell.h
//  Ledger
//
//  Created by Ян on 09.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportSelectAccountViewModel.h"

extern NSString * _Nonnull const kReportSelectAccountViewCellId;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportSelectAccountViewCell : UITableViewCell

@property (nonatomic, strong) YYGReportSelectAccountViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
