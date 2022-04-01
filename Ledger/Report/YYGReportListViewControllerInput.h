//
//  YYGReportListViewControllerInput.h
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReport.h"


@protocol YYGReportListViewControllerInput

- (void)setupUI;
- (void)showEmptyView;
- (void)hideEmptyView;

- (void)showReports:(NSArray <YYGReport *> *)reports;

@end