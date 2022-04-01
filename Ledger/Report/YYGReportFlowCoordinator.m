//
//  YYGReportFlowCoordinator.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportFlowCoordinator.h"
#import "YYGReportRouterInput.h"
#import "YYGReportInteractorInput.h"
#import "YYGReportSelectTypeViewModel.h"
#import "YYGReportSelectTypePresenterInput.h"
#import "YYGReportAccountActualPresenterInput.h"


@implementation YYGReportFlowCoordinator



#pragma mark - YYGReportSelectTypePresenterOutput

- (NSInteger)selectTypeNumberOfRowsInSection:(NSInteger)section
{
	return [self.interactor selectTypeNumberOfRowsInSection:section];
}

- (YYGReportSelectTypeViewModel *)viewModelForIndexPath:(NSIndexPath *)indexPath
{
	YYGReportSelectTypeViewModel *viewModel = [YYGReportSelectTypeViewModel new];
	
	viewModel.text = @"Остатки по счетам";
	viewModel.active = YES;
	viewModel.reportType = YYGReportTypeAccountBalances; // YYGReportTypeAccountActual;
	
	return viewModel;
}

- (void)selectType:(YYGReportType)reportType
{
	[self.router routeToAddReportSceneWithType:reportType];
}


#pragma mark - YYGReportAccountActualEditPresenterOutput

- (NSArray <YGEntity *> *)loadAccounts
{
	NSLog(@"[flowCoordinator loadAccounts]");
	return [self.interactor loadAccounts];
}

- (void)addReportActualAccountWithDate:(NSDate *)date accounts:(NSArray <YGEntity *> *)accounts
{
	[self.interactor addReportActualAccountWithDate:date accounts:accounts];
}

//- (void)backFromAccountActualEdit {
//	<#code#>
//}
//
//
//- (void)backFromAccountActualEdit {
//	<#code#>
//}


//- (void)backFromAccountActualEdit
//{
//	self.router routeToShowReportSceneWithReport:<#(YYGReport *)#>
//}


#pragma mark - YYGReportInteractorOutput

- (void)reportListAddButtonPressed
{
	[self.router routeToSelectTypeScene];
}

- (void)didAddedReport:(YYGReport *)report
{
	NSLog(@"-[flowCoordinator didAddedReport:]");
	[self.router routeToShowReportSceneWithReport:report];
}

- (void)didSelectReport:(YYGReport *)report
{
	NSLog(@"-YYGReportFlowCoordinator didSelectReport:]");
	[self.router showReport:report];

}

@end
