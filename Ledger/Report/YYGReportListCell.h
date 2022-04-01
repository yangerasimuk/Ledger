//
//  YYGReportListCell.h
//  Ledger
//
//  Created by Ян on 08.11.2021.
//  Copyright © 2021 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YYGReportListViewModel;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportListCell : UITableViewCell

@property (nonatomic, strong) YYGReportListViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
