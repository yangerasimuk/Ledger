//
//  YYGReportManager.h
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReport.h"


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportManager : NSObject

//@property (strong, nonatomic, readonly) NSMutableDictionary <NSString *, NSMutableArray <YYGReport *>*> *reports;
@property (strong, nonatomic, readonly) NSMutableArray <YYGReport *> *reports;

+ (instancetype)shared;

- (instancetype)init;

- (NSInteger)addReport:(YYGReport *)report;
- (YYGReport *)reportById:(NSInteger)reportId type:(YYGReportType)type;
- (void)updateReport:(YYGReport *)report;
- (void)deactivateReport:(YYGReport *)report;
- (void)activateReport:(YYGReport *)report;
- (void)removeReport:(YYGReport *)report;

- (NSArray <YYGReport *> *)reportsByType:(YYGReportType)type onlyActive:(BOOL)onlyActive exceptReport:(YYGReport *)exceptReport;
- (NSArray <YYGReport *> *)reportsByType:(YYGReportType)type onlyActive:(BOOL)onlyActive;
- (NSArray <YYGReport *> *)reportsByType:(YYGReportType)type;

@end

NS_ASSUME_NONNULL_END
