//
//  YYGReportManager+YYGReportValue.m
//  Ledger
//
//  Created by Ян on 04.04.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportManager+YYGReportValue.h"
#import "YGSQLite.h"


@interface YYGReportManager ()

@property (nonatomic, strong) YGSQLite *sqlite;

@end


@implementation YYGReportManager (YYGReportValue)

/*
createSql = @"CREATE TABLE IF NOT EXISTS report_value "
	"(report_value_id INTEGER PRIMARY KEY AUTOINCREMENT, "
	"report_value_type_id INTEGER NOT NULL, "
	"report_parameter_id INTEGER NOT NULL, "
	"value_text TEXT NULL, "
	"value_bool INTEGER NULL, "
	"value_integer INTEGER NULL, "
	"value_float REAL NULL, "
	"uuid TEXT NOT NULL"
	");";
 
 @property (nonatomic, assign) NSInteger rowId;
 @property (nonatomic, assign) YYGReportValueType type;
 @property (nonatomic, assign) NSInteger parameterId;
 @property (nonatomic, copy) NSString *valueText;
 @property (nonatomic, assign) NSInteger valueBool;
 @property (nonatomic, assign) NSInteger valueInteger;
 @property (nonatomic, assign) double valueFloat;
 @property (nonatomic, copy) NSUUID *uuid;
*/

- (NSInteger)addValue
:(YYGReportValue *)value
{
	NSInteger rowId = -1;
	@try
	{
		NSArray *valueArr = [NSArray arrayWithObjects:
			[NSNumber numberWithInteger:value.type], // entity_type_id
			[NSNumber numberWithInteger:value.parameterId], // entity_type_id
			value.valueText ? value.valueText : [NSNull null],
			[NSNumber numberWithBool:value.valueBool],
			[NSNumber numberWithInteger:value.valueInteger],
			[NSNumber numberWithDouble:value.valueFloat],
			[value.uuid UUIDString],
			nil];

		NSString *insertSQL = @"INSERT INTO report_value "
		"(report_value_type_id, report_parameter_id, "
		"value_text, value_bool, value_integer, value_float, uuid) VALUES "
		"(?, ?, ?, ?, ?, ?, ?);";

		rowId = [self.sqlite addRecord:valueArr insertSQL:insertSQL];
	}
	@catch (NSException *exception)
	{
		NSLog(@"Fail in -[YYGReportManager addValue]. Exception: %@", [exception description]);
	}
	@finally {
		return rowId;
	}
}

@end
