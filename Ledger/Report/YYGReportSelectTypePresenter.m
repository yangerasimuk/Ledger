//
//  YYGReportSelectTypePresenter.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportSelectTypePresenter.h"
#import "YYGReportSelectTypeViewControllerInput.h"
#import "YYGReportSelectTypePresenterOutput.h"


@implementation YYGReportSelectTypePresenter


#pragma mark - YYGReportSelectTypeViewControllerOutput

- (void)viewDidLoad
{
	[self.view setupUI];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
	return [self.output selectTypeNumberOfRowsInSection:section];
}

- (YYGReportSelectTypeViewModel *)viewModelForIndexPath:(NSIndexPath *)indexPath
{
	return [self.output viewModelForIndexPath:indexPath];
}

- (void)didSelectReportWithType:(YYGReportType)reportType
{
	return [self.output selectType:reportType];
}

@end
