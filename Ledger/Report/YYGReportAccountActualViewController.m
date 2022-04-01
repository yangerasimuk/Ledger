//
//  YYGReportAccountActualViewController.m
//  Ledger
//
//  Created by Ян on 08.04.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportAccountActualViewController.h"
#import "YYGReportAccountActualViewControllerOutput.h"


@interface YYGReportAccountActualViewController ()

@property (nonatomic, strong) YYGReport *report;

@end


@implementation YYGReportAccountActualViewController


#pragma mark - Lifecycle

- (instancetype)initWithReport:(YYGReport *)report
{
	self = [super init];
	if (self)
	{
		_report = report;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.output viewDidLoad];
}


#pragma mark - YYGReportAccountActualViewControllerInput

- (void)setupUI
{
	self.title = @"Остаток по счёту";
}

@end
