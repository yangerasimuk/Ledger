//
//  YYGReportAssembly.m
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportAssembly.h"

@implementation YYGReportAssembly

- (YYGReportListViewController *)reportViewController
{
	YYGReportListViewController *viewController = [YYGReportListViewController new];
	YYGReportListPresenter *presenter = [YYGReportListPresenter new];
	
	viewController.output = presenter;
	presenter.view = viewController;
	
	return viewController;
}

@end
