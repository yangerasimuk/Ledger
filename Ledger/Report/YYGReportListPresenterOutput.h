//
//  YYGReportListPresenterOutput.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReport.h"

@protocol YYGReportListPresenterOutput

- (void)reportListAddButtonPressed;

- (NSArray <YYGReport *> *)reports;

- (void)didSelectReport:(YYGReport *)report;

@end
