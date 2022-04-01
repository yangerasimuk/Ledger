//
//  YYGReportAccountActualEditPresenter.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportAccountActualEditPresenter.h"
#import "YYGReportAccountActualEditViewControllerInput.h"
#import "YYGReportAccountActualEditPresenterOutput.h"


@interface YYGReportAccountActualEditPresenter ()

@property (nonatomic, strong) YYGReport *report;
@property (nonatomic, strong) NSMutableArray <YGEntity *> *accounts;
@property (nonatomic, strong) NSMutableDictionary <YGEntity *, YYGReportSelectAccountViewModel *> *viewModels;

@end


@implementation YYGReportAccountActualEditPresenter

- (instancetype)initWithReport:(YYGReport *)report
{
	self = [super init];
	if (self)
	{
		_report = report;
		_accounts = [NSMutableArray <YGEntity *> new];
		_viewModels = [NSMutableDictionary <YGEntity *, YYGReportSelectAccountViewModel *> new];
	}
	return self;
}


#pragma mark - YYGReportAccountActualViewControllerOutput

- (void)viewDidLoad
{
	[self.view setupUI];
	[self loadAccounts];
	
}

//- (void)back
//{
//	[self.output backFromAccountActualEdit];
//}

- (BOOL)isNewReportMode
{
	return _report ? YES : NO;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
	return self.accounts.count;
}

- (YYGReportSelectAccountViewModel *)viewModelForIndex:(NSInteger)index
{
	YGEntity *account = self.accounts[index];
	
	YYGReportSelectAccountViewModel *viewModel;
	
	if (self.viewModels[account])
	{
		viewModel = self.viewModels[account];
	}
	else
	{
		viewModel = [YYGReportSelectAccountViewModel new];
		viewModel.account = account;
		viewModel.selected = NO;
		
		self.viewModels[account] = viewModel;
	}
	
	return viewModel;
}

- (void)addReportWithDate:(NSDate *)date
{
	NSLog(@"yyg [YYGReportSelectAccountViewCell addReportWithDate:]");
	NSMutableArray <YGEntity *> *accounts = [NSMutableArray <YGEntity *> new];
	
	[self.viewModels enumerateKeysAndObjectsUsingBlock:^(YGEntity * _Nonnull key, YYGReportSelectAccountViewModel * _Nonnull obj, BOOL * _Nonnull stop) {
		
		YYGReportSelectAccountViewModel *model = (YYGReportSelectAccountViewModel *)obj;
		if (model.selected)
		{
			[accounts addObject:model.account];
		}
	}];
	
	[self.output addReportActualAccountWithDate:date accounts:[accounts copy]];
}


#pragma mark - Private

- (void)loadAccounts
{
	self.accounts = [[self.output loadAccounts] mutableCopy];
}

@end
