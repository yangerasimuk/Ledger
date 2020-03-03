//
//  YYGReportListPresenter.m
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportListPresenter.h"
#import "YYGReportListViewControllerInput.h"

@implementation YYGReportListPresenter

- (void)didLoad
{
	[self.view setupUI];
	[self.view showEmptyView];
}

@end
