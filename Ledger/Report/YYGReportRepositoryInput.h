//
//  YYGReportRepositoryInput.h
//  Ledger
//
//  Created by Ян on 08.11.2021.
//  Copyright © 2021 Yan Gerasimuk. All rights reserved.
//

#import "YYGReport.h"
#import "YGEntity.h"


NS_ASSUME_NONNULL_BEGIN


/// Входящие сообщения репозитория отчётов
@protocol YYGReportRepositoryInput

/// Отчёты
- (NSArray <YYGReport *> *)reports;

/// Добавить отчёт "Остатки по счетам"
/// @param date Дата, если отсутствует, то текущая
/// @param accounts Счета, если отсутствует, то все счета
- (void)addAccountBalancesWithDate:(nullable NSDate *)date
						  accounts:(nullable NSArray <YGEntity *> *)accounts;

/// Обновить отчёт "Остатки по счетам"
/// @param report Счёт
- (void)updateAccountBalancesWithReport:(nonnull YYGReport *)report;

@end

NS_ASSUME_NONNULL_END
