//
//  YYGReportSelectAccountViewCell.m
//  Ledger
//
//  Created by Ян on 09.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportSelectAccountViewCell.h"

NSString *const kReportSelectAccountViewCellId = @"kReportSelectAccountViewCellId";


@interface YYGReportSelectAccountViewCell ()

@property (nonatomic, strong) UISwitch *accountSwitch;

@end


@implementation YYGReportSelectAccountViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReportSelectAccountViewCellId];
	
	if (self)
	{
		[self setupUI];
	}
	return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setViewModel:(YYGReportSelectAccountViewModel *)viewModel
{
	if (!_viewModel)
	{
		_viewModel = viewModel;
		[self configUI];
	}
}

- (void)setupUI
{
	[self setupAccountSwitch];
}

- (void)configUI
{
	self.textLabel.text = self.viewModel.account.name;
}

- (void)setupAccountSwitch
{
	_accountSwitch = [UISwitch new];
	_accountSwitch.on = YES;
	[self.contentView addSubview:_accountSwitch];
	[_accountSwitch addTarget:self action:@selector(accountSwitchChanged) forControlEvents:UIControlEventValueChanged];
	
	_accountSwitch.translatesAutoresizingMaskIntoConstraints = NO;
	
	[NSLayoutConstraint activateConstraints:@[
		[_accountSwitch.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
		[_accountSwitch.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-10.0]
	]];
}

#pragma mark - Actions

- (void)accountSwitchChanged
{
	NSLog(@"yyg [YYGReportSelectAccountViewCell accountSwitchChanged]");
	self.viewModel.selected = _accountSwitch.on;
}

@end
