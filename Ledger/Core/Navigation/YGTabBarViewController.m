//
//  YGTabBarViewController.m
//  Ledger
//
//  Created by Ян on 28/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGTabBarViewController.h"
#import "YGOperationViewController.h"
#import "YGEntityViewController.h"
#import "YYGReportListViewController.h"
#import "YGOptionViewController.h"
#import "YYGReportAssembly.h"

@interface YGTabBarViewController ()

@end

// TODO: добавить локализацию строк
@implementation YGTabBarViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UINavigationController *operationNC = [self navControllerForOperation];
	UINavigationController *reportNC = [self navControllerForReport];
	UINavigationController *accountNC = [self navControllerForAccount];
	UINavigationController *debtNC = [self navControllerForDebt];
	UINavigationController *optionNC = [self navControllerForOption];
	
	self.viewControllers = @[operationNC, reportNC, accountNC, debtNC, optionNC];
}

- (UINavigationController *)navControllerForOperation
{
	UINavigationController *operationNC = [self navControllerWithIdentifier:@"OperationsNavController"];
	UIViewController *operationVC = [self viewControllerWithIdentifier:@"OperationsViewController"];
	
	operationNC.viewControllers = @[operationVC];
	UIImage *accountImage = [UIImage imageNamed:@"tabItemOperations"];
	operationNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Операции"
														 image:accountImage
														   tag:0];
	
	return operationNC;
}

- (UINavigationController *)navControllerForReport
{
	UINavigationController *navController = [UINavigationController new];
	YYGReportListViewController *reportVC = [[YYGReportAssembly new] reportViewController];
	
	navController.viewControllers = @[reportVC];
	navController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Отчёты" image:[UIImage imageNamed:@"tabItemReports"] tag:1];
	return navController;
}

- (UINavigationController *)navControllerForAccount
{
	UINavigationController *accountNC = [self navControllerWithIdentifier:@"AccountsNavController"];
	UIViewController *vc = [self viewControllerWithIdentifier:@"EntitiesViewController"];
	YGEntityViewController *accountVC = (YGEntityViewController *)vc;
	
	accountVC.type = YGEntityTypeAccount;
	accountNC.viewControllers = @[accountVC];
	UIImage *accountImage = [UIImage imageNamed:@"tabItemAccounts"];
	accountNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Счёта"
														 image:accountImage
														   tag:2];
	
	return accountNC;
}

- (UINavigationController *)navControllerForDebt
{
	UINavigationController *debtNC = [self navControllerWithIdentifier:@"DebtsNavController"];
	UIViewController *vc = [self viewControllerWithIdentifier:@"EntitiesViewController"];
	YGEntityViewController *debtVC = (YGEntityViewController *)vc;
	
	debtVC.type = YGEntityTypeDebt;
	debtNC.viewControllers = @[debtVC];
	UIImage *accountImage = [UIImage imageNamed:@"tabItemDebts"];
	debtNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Долги"
														 image:accountImage
														   tag:3];
	
	return debtNC;
}

- (UINavigationController *)navControllerForOption
{
	UINavigationController *optionNC = [self navControllerWithIdentifier:@"OptionsNavController"];
	UIViewController *optionVC = [self viewControllerWithIdentifier:@"OptionsViewController"];
	
	optionNC.viewControllers = @[optionVC];
	UIImage *accountImage = [UIImage imageNamed:@"tabItemOptions"];
	optionNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Настройки"
														 image:accountImage
														   tag:4];
	
	return optionNC;
}


#pragma mark - Private

- (UINavigationController *)navControllerWithIdentifier:(NSString *)identifier
{
	UIViewController *vc = [self viewControllerWithIdentifier:identifier];
	
	if (!vc)
	{
		return nil;
	}
	
	UINavigationController *nc = (UINavigationController *)vc;
	if (!nc)
	{
		return nil;
	}
	else
	{
		return nc;
	}
}

- (UIViewController *)viewControllerWithIdentifier:(NSString *)identifier
{
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	UIViewController *vc = [sb instantiateViewControllerWithIdentifier:identifier];
	
	if (!vc)
	{
		return nil;
	}
	else
	{
		return vc;
	}
}


#pragma mark - Lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
