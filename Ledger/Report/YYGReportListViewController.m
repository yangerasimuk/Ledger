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


@interface YYGReportListViewController ()

@property (nonatomic, strong) YYGEmptyView *emptyView;
@property (nonatomic, strong) UITableView *tableView;

@end


@implementation YYGReportListViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.output didLoad];
}


#pragma mark - YYGReportListViewControllerInput

- (void)setupUI
{
	self.view.backgroundColor = [UIColor whiteColor];
	
	[self createTableView];
	[self createEmptyView];
}


#pragma mark - User inerface

- (void)createTableView
{
	self.tableView = [UITableView new];
	self.tableView.tableFooterView = [UIView new];
	self.tableView.hidden = YES;
	[self.view addSubview:self.tableView];
	
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


#pragma mark - Show/hide empty view

- (void)showEmptyView
{
	[self.emptyView showWithMessage:@"No reports"];
}

- (void)hideEmptyView
{
	[self.emptyView hide];
}

@end
