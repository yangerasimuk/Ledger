//
//  YYGReport.m
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReport.h"


@implementation YYGReport

- (instancetype)initWithRowId:(NSInteger)rowId type:(YYGReportType)type name:(NSString *)name active:(BOOL)active created:(NSDate *)created modified:(NSDate *)modified sort:(NSInteger)sort comment:(NSString *)comment uuid:(NSUUID *)uuid
{
	self = [super init];
	if (self)
	{
		_rowId = rowId;
		_type = type;
		_name = [name copy];
		_active = active;
		_created = [created copy];
		_modified = [modified copy];
		_sort = sort;
		_comment = [comment copy];
		_uuid = [uuid copy];
	}
	return self;
}

#pragma mark - Override system methods: Description, isEqual, hash

- (BOOL)isEqual:(id)object {

	if(self == object) return YES;

	if([self class] != [object class]) return NO;
	
	YYGReport *otherReport = (YYGReport *)object;
	if (self.rowId != otherReport.rowId)
		return NO;
	if (self.type != otherReport.type)
		return NO;
	if (![self.name isEqualToString:otherReport.name])
		return NO;
	if (![self.uuid isEqual:otherReport.uuid])
		return NO;
	
	return YES;
}

- (NSUInteger)hash
{
	NSString *hashString = [NSString stringWithFormat:@"%ld:%ld:%@:%@:%@", (long)_rowId, (long)_type, _name, _created, _uuid];

	return [hashString hash];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Report. RowId:%ld, type:%ld, name:%@, active:%ld created:%@, modified:%@, sort:%ld, comment:%@, uuid:%@", (long)_rowId, (long)_type, _name, (long)_active, _created, _modified, (long)_sort, _comment, _uuid];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	YYGReport *newReport = [[YYGReport alloc] initWithRowId:_rowId type:_type name:_name active:_active created:_created modified:_modified sort:_sort comment:_comment uuid:_uuid];
	return newReport;
}

@end

NSString * NSStringFromReportType(YYGReportType type)
{
	switch (type)
	{
		case YYGReportTypeAccountActual:
			return @"Остаток по счетам";
		default:
			@throw [NSException exceptionWithName:@"YYGReport NSStringFromReportType()" reason:@"Unknown report type." userInfo:nil];
	}
}
