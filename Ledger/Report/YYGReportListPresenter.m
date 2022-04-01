//
//  YYGReportListPresenter.m
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportListPresenter.h"
#import "YYGReportListViewControllerInput.h"
#import "YYGReportListPresenterOutput.h"


@interface YYGReportListPresenter ()

@property (nonatomic, strong) NSArray <YYGReport *> *reports;

@end


@implementation YYGReportListPresenter

- (void)viewDidLoad
{
	[self.view setupUI];

	self.reports = [self.output reports];
	if (self.reports.count)
	{
		[self.view hideEmptyView];
	}
	else
	{
		[self.view showEmptyView];
	}
	[self.view showReports:self.reports];
}

- (void)addButtonPressed
{
	[self.output reportListAddButtonPressed];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.output didSelectReport:self.reports[indexPath.row]];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"-[YYGReportListPresenter numberOfRowsInSection:]");
	NSLog(@"\t\treports.count: %@", @(self.reports.count));
	return self.reports.count;
}

- (YYGReportListViewModel *)viewModelForIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"-[YYGReportListPresenter viewModelForIndexPath:]");
	NSLog(@"\t\tindexPath: %@, .row: %@", indexPath, @(indexPath.row));
//	NSLog(@"\t\tindexPath.row: %@", @(indexPath.row));
//	for (YYGReport *report in self.reports)
//	{
//		NSLog(@"\t\treport: %@", report);
//	}
//	indexPath.
	YYGReportListViewModel *viewModel = [YYGReportListViewModel new];
	viewModel.report = self.reports[indexPath.row];
	return viewModel;
}

@end
