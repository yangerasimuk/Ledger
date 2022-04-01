//
//  YYGReportRepositoryOutput.h
//  Ledger
//
//  Created by Ян on 08.11.2021.
//  Copyright © 2021 Yan Gerasimuk. All rights reserved.
//


#import "YYGReport.h"

/// Протокол сообщений репозитория отчётов
@protocol YYGReportRepositoryOutput

/// Отчёт добавлен в бд
/// @param report Отчёт
- (void)reportDidAdd:(YYGReport *)report;

/// Отчёт обновлен
/// @param report Отчёт
- (void)reportDidUpdate:(YYGReport *)report;

@end
