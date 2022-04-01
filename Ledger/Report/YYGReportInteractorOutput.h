//
//  YYGReportInteractorOutput.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReport.h"


@protocol YYGReportInteractorOutput

- (void)reportListAddButtonPressed;

- (void)didAddedReport:(YYGReport *)report;

- (void)didSelectReport:(YYGReport *)report;

@end
