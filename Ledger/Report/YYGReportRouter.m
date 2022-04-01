//
//  YYGReportRouter.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportRouter.h"
#import "YYGReportAssembly.h"


@interface YYGReportRouter ()

@property (nonatomic, weak) UINavigationController *rootReportNavController;
@property (nonatomic, weak) UIViewController *rootReportViewController;

@end


@implementation YYGReportRouter

- (instancetype)initWithNavController:(UINavigationController *)navController
{
	self = [super init];
	if (self)
	{
		_rootReportNavController = navController;
	}
	return self;
}

- (instancetype)initWithNavController:(UINavigationController *)navController
					listViewConroller:(UIViewController *)viewController
{
	self = [super init];
	if (self)
	{
		_rootReportNavController = navController;
		_rootReportViewController = viewController;
	}
	return self;
}


#pragma mark - YYGReportRouterInput

- (void)routeToSelectTypeScene
{
	UIViewController *selectTypeVC = [self.assembly selectReportTypeViewController];
	[self.rootReportNavController pushViewController:selectTypeVC animated:YES];
}

- (void)routeToAddReportSceneWithType:(YYGReportType)reportType
{
	UIViewController *addVC = [self.assembly addReportViewControllerForType:reportType];
	[self.rootReportNavController pushViewController:addVC animated:YES];
}

- (void)routeToShowReportSceneWithReport:(YYGReport *)report
{
	UIViewController *reportVC = [self.assembly viewControllerWithReport:report];
	[self.rootReportNavController pushViewController:reportVC animated:YES];
}

- (void)showReport:(YYGReport *)report
{
	UIViewController *viewController = [self.assembly viewControllerWithReport:report];
	[self.rootReportNavController pushViewController:viewController animated:YES];


}

@end
