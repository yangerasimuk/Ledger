//
//  YYGReportAssembly.m
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportAssembly.h"
#import "YYGReportListViewController.h"
#import "YYGReportSelectTypeViewController.h"
#import "YYGReportAccountActualEditViewController.h"
#import "YYGReportAccountActualViewController.h"
#import "YYGReportListPresenter.h"
#import "YYGReportSelectTypePresenter.h"
#import "YYGReportAccountActualEditPresenter.h"
#import "YYGReportAccountActualPresenter.h"
#import "YYGReportFlowCoordinator.h"
#import "YYGReportInteractor.h"
#import "YYGReportRouter.h"
#import "YYGEntityRepository.h"
#import "YYGReportRepository.h"


@interface YYGReportAssembly ()

@property (nonatomic, weak) YYGReportFlowCoordinator *flowCoordinator;

@end


@implementation YYGReportAssembly

- (UIViewController *)reportListViewControllerWithNavController:(UINavigationController *)navController
{
	YYGReportListViewController *viewController = [YYGReportListViewController new];
	YYGReportListPresenter *presenter = [YYGReportListPresenter new];
	
	viewController.output = presenter;
	presenter.view = viewController;
	
	YYGReportFlowCoordinator *flowCoordinator = [YYGReportFlowCoordinator new];
	flowCoordinator.listPresenter = presenter;
//	presenter.output = flowCoordinator;
	self.flowCoordinator = flowCoordinator;
	
	YYGReportInteractor *interactor = [YYGReportInteractor new];
	interactor.output = self.flowCoordinator;

	// Передалать на weak
	self.flowCoordinator.interactor = interactor;

	presenter.output = interactor;
	
	YYGEntityRepository *entityRepository = [YYGEntityRepository new];
	interactor.entityRepository = entityRepository;
	YYGReportRepository *reportRepository = [YYGReportRepository new];
	interactor.reportRepository = reportRepository;
	reportRepository.output = interactor;
	
	YYGReportRouter *router = [[YYGReportRouter alloc] initWithNavController:navController];
	router.assembly = self;
	flowCoordinator.router = router;
	
	return viewController;
}

- (UIViewController *)selectReportTypeViewController
{
	YYGReportSelectTypeViewController *viewController = [YYGReportSelectTypeViewController new];
	YYGReportSelectTypePresenter *presenter = [YYGReportSelectTypePresenter new];
	
	viewController.output = presenter;
	presenter.view = viewController;
	presenter.output = self.flowCoordinator;
	self.flowCoordinator.selectTypePresenter = presenter;
	
	return viewController;
}

- (UIViewController *)addReportViewControllerForType:(YYGReportType)reportType
{
	UIViewController *viewController;
	
	switch (reportType)
	{
		case YYGReportTypeAccountBalances:
			viewController = [self reportAccountActualEditViewController];
			break;
		default:
			@throw [NSException exceptionWithName:@"-[YYGReportAssembly reportAddViewControllerWithType]" reason:@"Unknown report type." userInfo:nil];
	}
	
	return viewController;
}

- (UIViewController *)viewControllerWithReport:(YYGReport *)report
{
	switch (report.type)
	{
		case YYGReportTypeAccountBalances:
			return [self reportAccountActualViewControllerWithReport:report];
		default:
			@throw [NSException exceptionWithName:@"Unknown report type" reason:@"Can not assembly unknown report type" userInfo:nil];
	}
	
	return nil;
}


#pragma mark - Private

- (UIViewController *)reportAccountActualViewControllerWithReport:(YYGReport *)report
{
	YYGReportAccountActualViewController *view = [[YYGReportAccountActualViewController alloc] initWithReport:report];
	YYGReportAccountActualPresenter *presenter = [YYGReportAccountActualPresenter new];
	
	view.output = presenter;
	presenter.view = view;
	presenter.output = self.flowCoordinator;
	self.flowCoordinator.accountActualPresenter = presenter;
	
	return view;
}


- (UIViewController *)reportAccountActualEditViewController
{
	YYGReportAccountActualEditViewController *view = [YYGReportAccountActualEditViewController new];
	YYGReportAccountActualEditPresenter *presenter = [[YYGReportAccountActualEditPresenter alloc] initWithReport:nil];
	
	view.output = presenter;
	presenter.view = view;
	presenter.output = self.flowCoordinator;
	self.flowCoordinator.accountActualEditPresenter = presenter;
	
	return view;
}

@end
