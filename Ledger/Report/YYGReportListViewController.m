//
//  YYGReportListViewController.m
//  Ledger
//
//  Created by Ян on 18/08/2019.
//  Copyright © 2019 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportListViewController.h"
#import "YYGNoDataView.h"
#import "YYGReportListViewControllerOutput.h"


@interface YYGReportListViewController ()

@property (nonatomic, strong) YYGNoDataView *noDataView;
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
	[self createTableView];
}


#pragma mark - User inerface
- (void)createTableView
{
	self.tableView = [UITableView new];
	[self.view addSubview:self.tableView];
	
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints: @[
	 [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
	 [self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
	 [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
	 [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]]];
}

#pragma mark - Show/hide No operation view

- (void)showNoDataView
{
    if(!self.noDataView) {
        self.noDataView = [[YYGNoDataView alloc] initWithFrame:self.tableView.frame forView:self.tableView];
    }
    [self.noDataView showMessage:@"Нет отчётов"];
}

- (void)hideNoDataView {
    [self.noDataView hide];
}

@end
