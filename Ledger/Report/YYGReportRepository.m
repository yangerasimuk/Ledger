//
//  YYGReportRepository.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportRepository.h"
#import "YYGReportRepositoryOutput.h"
#import "YYGReportManager.h"
#import "YYGReportParameter.h"
#import "YYGReportValue.h"
#import "YYGReportManager+YYGReportParameter.h"
#import "YYGReportManager+YYGReportValue.h"
#import "YGTools.h"
#import "YYGReport.h"
#import "YGEntity.h"


@implementation YYGReportRepository


#pragma mark - YYGReportRepositoryInput

- (NSArray <YYGReport *> *)reports
{
	NSLog(@"-[YYGReportRepository reports]");
	YYGReportManager *manager = [YYGReportManager shared];
	return [[manager reports] copy];
}

- (void)addAccountBalancesWithDate:(NSDate *)date accounts:(NSArray *)accounts
{
	NSLog(@"yyg [YYGReportRepository addAccountBalancesWithDate:");

	YYGReportManager *reportManager = [YYGReportManager shared];

	NSDate *now = [NSDate date];
	YYGReport *report = [[YYGReport alloc] initWithRowId:-1
													type:YYGReportTypeAccountBalances
													name:@"Остатки по счетам"
												  active:YES
												 created:now
												modified:now
													sort:100
												 comment:nil
													uuid:[NSUUID UUID]];

	// Save report
	NSInteger reportId = [reportManager addReport:report];
	report.rowId = reportId;

	// Save date parameter
	YYGReportParameter *dateParameter = [[YYGReportParameter alloc] initWithRowId:-1
																			 type:YYGReportParameterTypeDate
																	  reportRowId:reportId
																			 uuid:[NSUUID UUID]];
	NSInteger dateParameterId = [reportManager addParameter:dateParameter];
	dateParameter.rowId = dateParameterId;
	[report.parameters addObject:dateParameter];

	// TODO: что делать если parameterId не пришел или вылетело исключение
	YYGReportValue *dateValue = [[YYGReportValue alloc] initWithRowId:-1
		type:YYGReportValueTypeText
		parameterId:dateParameterId
		valueText:[YGTools stringFromDate:date]
		valueBool:NO
		valueInteger:0
		valueFloat:0.0
		uuid:[NSUUID UUID]];
	[reportManager addValue:dateValue];
	[dateParameter.values addObject:dateValue];

	// Save accounts parameter
	YYGReportParameter *accountsParameter = [[YYGReportParameter alloc] initWithRowId:-1 type:YYGReportParameterTypeAccount reportRowId:reportId uuid:[NSUUID UUID]];

	NSInteger accountsParameterId = [reportManager addParameter:accountsParameter];
	accountsParameter.rowId = accountsParameterId;

	for (YGEntity *account in accounts)
	{
		YYGReportValue *accountValue = [[YYGReportValue alloc] initWithRowId:-1
			type:YYGReportValueInteger
			parameterId:accountsParameterId
			valueText:nil
			valueBool:NO
			valueInteger:account.rowId
			valueFloat:0.0
			uuid:[NSUUID UUID]];

		NSInteger valueId = [reportManager addValue:accountValue];
		accountValue.rowId = valueId;
		[accountsParameter.values addObject:accountValue];
	}

	NSLog(@"Add report: %@", report);

	[self.output reportDidAdd:report];
}

- (void)updateAccountBalancesWithReport:(nonnull YYGReport *)report {
	//
}


#pragma mark - Private


@end
