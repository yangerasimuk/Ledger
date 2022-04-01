//
//  YYGReportSelectTypeViewCell.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportSelectTypeViewCell.h"

NSString *const kReportSelectTypeViewCellId = @"kReportSelectTypeViewCellId";


@implementation YYGReportSelectTypeViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setViewModel:(YYGReportSelectTypeViewModel *)viewModel
{
	if (!_viewModel)
	{
		_viewModel = viewModel;
		[self setupUI];
	}
}

- (void)setupUI
{
	self.textLabel.text = self.viewModel.text;
	if (self.viewModel.isActive)
	{
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		self.accessoryType = UITableViewCellAccessoryNone;
	}
}

@end
