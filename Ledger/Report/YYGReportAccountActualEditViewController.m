//
//  YYGReportAccountActualEditViewController.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportAccountActualEditViewController.h"
#import "YYGReportAccountActualEditViewControllerOutput.h"
#import "YYGReportSelectAccountViewModel.h"
#import "YYGReportSelectAccountViewCell.h"

// TODO: make other method
#import "YYGApplication.h"


@interface YYGReportAccountActualEditViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *dateView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UISegmentedControl *dateSegment;
@property (nonatomic, strong) NSLayoutConstraint *dateHeightConstraint;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UILabel *accountLabel;
@property (nonatomic, strong) UITableView *tableView;

@end


@implementation YYGReportAccountActualEditViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.output viewDidLoad];
}

#pragma mark - YYGReportAccountActualViewControllerInput

- (void)setupUI
{
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.view.frame = self.view.superview.bounds;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.view.translatesAutoresizingMaskIntoConstraints = YES;
	
//	tableVC.View.Frame = rootVC.View.Bounds
//	tableVC.View.Autoresizingmask = UIViewAutoresizing.FlexibleWidth
//	tableVC.View.TranslatesAutoresizingMaskIntoConstraints = true/
	
	[self setupNavBar];
	[self setupDateView];
	[self setupDateLabel];
	[self setupDateSegment];
	[self setupDatePicker];
	[self setupAccountLabel];
	[self setupTableView];
}


#pragma mark - UI

- (void)setupNavBar
{
	self.title = @"Новый отчёт";
	
//	if ([self.output isNewReportMode])
//	{
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
		self.navigationItem.rightBarButtonItem = saveButton;
//	}
}

- (void)setupDateView
{
	self.dateView = [UIView new];
	[self.view addSubview:self.dateView];
	
//	self.dateView.backgroundColor = [UIColor lightGrayColor];
	
	CGFloat statusBarHeight = [YYGApplication statusBarHeightWithApplication:[UIApplication sharedApplication]];
	CGFloat navBarHeight = [YYGApplication navBarHeightWithNavController:self.navigationController];
	CGFloat topOffset = statusBarHeight + navBarHeight + 10.0;
	
	self.dateView.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[self.dateView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:topOffset],
		[self.dateView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:10.0],
		[self.dateView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-10.0],
		[self.dateView.heightAnchor constraintEqualToConstant:300.0]
	]];
}

- (void)setupDateLabel
{
	self.dateLabel = [UILabel new];
	[self.dateView addSubview:self.dateLabel];
	self.dateLabel.numberOfLines = 1;
	self.dateLabel.text = @"Выбор даты";
	
//	self.dateLabel.backgroundColor = [UIColor redColor];
	
	self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[self.dateLabel.topAnchor constraintEqualToAnchor:self.dateView.topAnchor constant:10],
		[self.dateLabel.leftAnchor constraintEqualToAnchor:self.dateView.leftAnchor constant:10.0],
		[self.dateLabel.rightAnchor constraintEqualToAnchor:self.dateView.rightAnchor constant:-10.0],
		[self.dateLabel.heightAnchor constraintEqualToConstant:20.0]
	]];
}

- (void)setupDateSegment
{
	NSArray *titles = @[@"Всегда текущая", @"Конкретная дата"];
	self.dateSegment = [[UISegmentedControl alloc] initWithItems:titles];
	self.datePicker.datePickerMode = UIDatePickerModeDate;
	self.datePicker.userInteractionEnabled = NO;
	self.dateSegment.selectedSegmentIndex = 0;
	[self.dateView addSubview:self.dateSegment];
	
	[self.dateSegment addTarget:self
						 action:@selector(selectDate) forControlEvents:UIControlEventValueChanged];
	
//	self.dateSegment.backgroundColor = [UIColor greenColor];
	
	self.dateSegment.translatesAutoresizingMaskIntoConstraints = NO;
	self.dateHeightConstraint = [NSLayoutConstraint constraintWithItem:self.dateSegment attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:40.0];
	
	[NSLayoutConstraint activateConstraints:@[
		[self.dateSegment.topAnchor constraintEqualToAnchor:self.dateLabel.bottomAnchor constant:10.0],
		[self.dateSegment.leftAnchor constraintEqualToAnchor:self.dateView.leftAnchor constant:10.0],
		[self.dateSegment.rightAnchor constraintEqualToAnchor:self.dateView.rightAnchor constant:-10.0],
		[self.dateSegment.heightAnchor constraintEqualToConstant:40.0]
//		self.dateHeightConstraint
	]];
}

- (void)setupDatePicker
{
	self.datePicker = [UIDatePicker new];
	[self.dateView addSubview:self.datePicker];
	
	self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints:@[
		[self.datePicker.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
		[self.datePicker.topAnchor constraintEqualToAnchor:self.dateSegment.bottomAnchor constant:10.0],
		[self.datePicker.heightAnchor constraintEqualToConstant:200.0]
	]];
}
- (void)setupAccountLabel
{
	
}

- (void)setupTableView
{
	self.tableView = [UITableView new];
	self.tableView.tableFooterView = [UIView new];
	self.tableView.hidden = NO;
	[self.view addSubview:self.tableView];
	
//	self.tableView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
	
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[NSLayoutConstraint activateConstraints: @[
		[self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
		[self.tableView.topAnchor constraintEqualToAnchor:self.dateView.bottomAnchor constant:10.0],
		[self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
		[self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
	]];
	
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
}


#pragma mark - Actions

- (void)selectDate
{
	switch (self.dateSegment.selectedSegmentIndex)
	{
		case 0:
			self.datePicker.userInteractionEnabled = NO;
			break;
		case 1:
			self.datePicker.userInteractionEnabled = YES;
			break;
		default:
			break;
	}
}

- (void)saveButtonPressed
{
	[self.output addReportWithDate:self.datePicker.date];
//	[self.output back];
}


#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	YYGReportSelectAccountViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReportSelectAccountViewCellId];
	if (!cell)
	{
		cell = [[YYGReportSelectAccountViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReportSelectAccountViewCellId];
	}
	
	cell.viewModel = [self.output viewModelForIndex:indexPath.row];
	
	return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.output numberOfRowsInSection:section];
}


#pragma mark - UITableViewDelegate


@end
