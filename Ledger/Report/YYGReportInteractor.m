//
//  YYGReportInteractor.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportInteractor.h"
#import "YGEntity.h"
#import "YYGEntityRepositoryInput.h"
#import "YYGReportRepositoryInput.h"
#import "YYGReportInteractorOutput.h"
#import "YYGReportListPresenterOutput.h"

@protocol YYGReportInteractorOutput;
@protocol YYGEntityRepositoryInput;
@protocol YYGReportRepositoryInput;


@implementation YYGReportInteractor


#pragma mark - YYGReportInteractorInput

- (NSInteger)selectTypeNumberOfRowsInSection:(NSInteger)section
{
	// TODO: переделать на вызов Репозитория
	return 1;
}

- (NSArray <YGEntity *> *)loadAccounts
{
	return [self.entityRepository accounts];
}

//- (void)saveReportActualAccountWithDate:(NSDate *)date accounts:(NSArray <YGEntity *> *)accounts
//{
//	[self.entityRepository saveReportActualAccountWithDate:date accounts:accounts];
//
////	[self.entityRepository saveReportActualAccountWithDate:(NSDate *)date accounts:(NSArray <YGEntity *> *)accounts
//}

- (void)addReportActualAccountWithDate:(NSDate *)date accounts:(NSArray <YGEntity *> *)accounts
{
	NSLog(@"yyg [YYGReportInteractor addReportActualAccountWithDate:accounts:]");
	[self.reportRepository addAccountBalancesWithDate:date accounts:accounts];
}


#pragma mark - YYGReportListPresenterOutput

- (NSArray <YYGReport *> *)reports
{
	NSLog(@"yyg [YYGReportInteractor reports]");
	return [self.reportRepository reports];
}

- (void)reportListAddButtonPressed
{
	[self.output reportListAddButtonPressed];
}

- (void)didSelectReport:(YYGReport *)report
{
	[self.output didSelectReport:report];
}


#pragma mark - YYGEntityRepositoryOutput

- (void)didAddedReport:(YYGReport *)report
{
	[self.output didAddedReport:report];
	
//	[self.output didAddedReport:report];
}

@end
