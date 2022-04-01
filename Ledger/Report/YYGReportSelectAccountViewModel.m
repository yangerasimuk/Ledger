//
//  YYGReportSelectAccountViewModel.m
//  Ledger
//
//  Created by Ян on 09.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportSelectAccountViewModel.h"


@implementation YYGReportSelectAccountViewModel

- (instancetype)initWithAccount:(YGEntity *)account selected:(BOOL)selected
{
	self = [super init];
	if (self)
	{
		_account = account;
		_selected = selected;
	}
	return self;
}

@end
