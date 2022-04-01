//
//  YYGReportListViewController.m
//  Ledger
//
//  Created by Ян on 18/08/2019.
//  Copyright © 2019 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportListViewController.h"
#import "YYGReportListViewControllerOutput.h"
#import "YYGEmptyView.h"
#import "YYGReportListViewModel.h"
#import "YYGReportListCell.h"


@interface YYGReportListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) YYGEmptyView *emptyView;
@property (nonatomic, strong) UITableView *tableView;

@end


@implementation YYGReportListViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
	NSLog(@"-[YYGReportListViewController viewDidLoad]");
	[super viewDidLoad];
	[self.output viewDidLoad];
}


#pragma mark - YYGReportListViewControllerInput

- (void)setupUI
{
	self.view.backgroundColor = [UIColor whiteColor];
	
	[self createNavBar];
	[self createTableView];
	[self createEmptyView];
}


#pragma mark - User inerface

- (void)createNavBar
{
	self.title = @"Отчёты";
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
	self.navigationItem.rightBarButtonItem = addButton;
}

- (void)createTableView
{
	self.tableView = [UITableView new];
	self.tableView.tableFooterView = [UIView new];
	self.tableView.hidden = NO;
	[self.view addSubview:self.tableView];

	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints: @[
	 [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
	 [self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
	 [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
	 [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]]];
}

- (void)createEmptyView
{
	self.emptyView = [[YYGEmptyView alloc] initWithParentView:self.view
											 navBarController:self.navigationController
											 tabBarController:self.tabBarController];
}

- (void)showReports:(NSArray<YYGReport *> *)reports
{
	NSLog(@"-[YYGReportListViewController showReports];");
	[self.tableView reloadData];
}


#pragma mark - Show/hide empty view

- (void)showEmptyView
{
	[self.emptyView showWithMessage:@"No reports"];
}

- (void)hideEmptyView
{
	[self.emptyView hide];
}


#pragma mark - Actions

- (void)addButtonPressed
{
	[self.output addButtonPressed];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 64;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
				 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

	NSLog(@"-[YYGReportListViewController tableView:cellForRowAtIndexPath:]");
	YYGReportListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kReportListCellId"];
	if (!cell) {
		cell = [[YYGReportListCell alloc] initWithStyle:UITableViewCellStyleDefault
										reuseIdentifier:@"kReportListCellId"];
	}

	cell.viewModel = [self.output viewModelForIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.output numberOfRowsInSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.output didSelectRowAtIndexPath:indexPath];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
