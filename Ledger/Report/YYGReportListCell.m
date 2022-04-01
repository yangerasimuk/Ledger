//
//  YYGReportListCell.m
//  Ledger
//
//  Created by Ян on 08.11.2021.
//  Copyright © 2021 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportListCell.h"
#import "YYGReportListViewModel.h"
#import "YYGReport.h"

NSString *const kReportListCellId = @"kReportListCellId";


@interface YYGReportListCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation YYGReportListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kReportListCellId];

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

- (void)setupUI
{
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.titleLabel.numberOfLines = 1;
	[self.contentView addSubview:self.titleLabel];

	[NSLayoutConstraint activateConstraints:@[
		[self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
		[self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10],
		[self.titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10],
		[self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10]
	]];


}

-(void)setViewModel:(YYGReportListViewModel *)viewModel
{
	_viewModel = viewModel;
	self.titleLabel.text = self.viewModel.report.name;
}

@end
