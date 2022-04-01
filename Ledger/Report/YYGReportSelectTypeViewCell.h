//
//  YYGReportSelectTypeViewCell.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportSelectTypeViewModel.h"


extern NSString * _Nonnull const kReportSelectTypeViewCellId;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportSelectTypeViewCell : UITableViewCell

@property (nonatomic, strong) YYGReportSelectTypeViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
