//
//  YYGReportAssembly.h
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReport.h"


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportAssembly : NSObject

/// Навигационный контроллер для Отчётов.
/// Запускается первым в сценариях работы с отчётами.
///
/// @param navController Навигационный контроллер
- (UIViewController *)reportListViewControllerWithNavController:(UINavigationController *)navController;

- (UIViewController *)selectReportTypeViewController;

- (UIViewController *)addReportViewControllerForType:(YYGReportType)reportType;

- (UIViewController *)viewControllerWithReport:(YYGReport *)report;

@end

NS_ASSUME_NONNULL_END
