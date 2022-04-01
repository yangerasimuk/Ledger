//
//  YYGReportManager+YYGReportParameter.m
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportManager+YYGReportParameter.h"
#import "YGTools.h"
#import "YGSQLite.h"


@interface YYGReportManager ()

@property (nonatomic, strong) YGSQLite *sqlite;

@end


@implementation YYGReportManager (YYGReportParameter)

- (NSInteger)addParameter:(YYGReportParameter *)parameter
{
	NSInteger rowId = -1;
	@try
	{
		
		NSArray *parameterArr = [NSArray arrayWithObjects:
			[NSNumber numberWithInteger:parameter.type],
			[NSNumber numberWithInteger:parameter.reportRowId],
			[parameter.uuid UUIDString],
			nil];

		NSString *insertSQL = @"INSERT INTO report_parameter (report_parameter_type_id, report_id, uuid) VALUES (?, ?, ?);";
		
		rowId = [self.sqlite addRecord:parameterArr insertSQL:insertSQL];
	}
	@catch (NSException *exception)
	{
		NSLog(@"Fail in -[YYGReportManager addParameter]. Exception: %@", [exception description]);
	}
	@finally
	{
		return rowId;
	}
}


//- (YYGReportParameter *)parameterById:(NSInteger)parameterId type:(YYGReportParameterType)type
//{
//	return nil;
//}
//
//- (NSArray <YYGReportParameter *> *)parametersByReportId:(NSInteger)reportId
//{
//	return nil;
//}
//
//- (void)updateParameter:(YYGReportParameter *)parameter
//{
//
//}
//
//- (void)removeParameter:(YYGReportParameter *)parameter forReportId:(NSInteger *)reportId
//{
//
//}

@end
