//
//  YYGReportSelectTypeViewController.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportSelectTypeViewController.h"
#import "YYGReportSelectTypeViewControllerOutput.h"
#import "YYGReportSelectTypeViewCell.h"
#import "YYGReportSelectTypeViewModel.h"


@interface YYGReportSelectTypeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end


@implementation YYGReportSelectTypeViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.output viewDidLoad];
}


#pragma mark - YYGReportSelectTypeViewControllerInput

- (void)setupUI
{
	self.view.backgroundColor = [UIColor whiteColor];
	
	[self setupNavBar];
	[self setupTableView];
}

- (void)setupNavBar
{
	self.title = @"Выбрать тип отчёта";
}

- (void)setupTableView
{
	self.tableView = [UITableView new];
	self.tableView.tableFooterView = [UIView new];
	[self.view addSubview:self.tableView];
	
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints: @[
	 [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
	 [self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
	 [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
	 [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]]];
	
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	
	[self.tableView registerClass:[YYGReportSelectTypeViewCell class] forCellReuseIdentifier:kReportSelectTypeViewCellId];
}


#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	YYGReportSelectTypeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportSelectTypeViewCellId];
	if (!cell)
	{
		cell = [[YYGReportSelectTypeViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReportSelectTypeViewCellId];
	}
	
	cell.viewModel = [self.output viewModelForIndexPath:indexPath];
	
	return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
//	return [self.output numberOfRowsInSection:section];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self.tableView isEqual:tableView])
	{
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		YYGReportSelectTypeViewCell *selectTypeViewCell = (YYGReportSelectTypeViewCell *)cell;
		
		[self.output didSelectReportWithType:selectTypeViewCell.viewModel.reportType];
	}
}

@end
