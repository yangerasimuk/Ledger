//
//  YYGReport.h
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYGReportParameter;

typedef NS_ENUM(NSInteger, YYGReportType) {
	YYGReportTypeAccountBalances		= 1,	/**< Остаток по счетам */
};

NSString * _Nonnull NSStringFromReportType(YYGReportType type);


NS_ASSUME_NONNULL_BEGIN


@interface YYGReport : NSObject <NSCopying>

// Сырые свойства из базы данных
@property (nonatomic, assign) NSInteger rowId;
@property (nonatomic, assign) YYGReportType type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, copy) NSDate *created;
@property (nonatomic, copy) NSDate *modified;
@property (nonatomic, assign) NSInteger sort;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSUUID *uuid;

// Комплексный объект - параметры и их значения
@property (nonatomic, copy) NSMutableArray <YYGReportParameter *> *parameters;

- (instancetype)initWithRowId:(NSInteger)rowId type:(YYGReportType)type name:(NSString *)name
					   active:(BOOL)active created:(NSDate *)created modified:(NSDate *)modified
						 sort:(NSInteger)sort comment:(NSString *)comment uuid:(NSUUID *)uuid;

@end

NS_ASSUME_NONNULL_END