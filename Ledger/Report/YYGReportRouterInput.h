//
//  YYGReportRouterInput.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReport.h"

@protocol YYGReportRouterInput

- (void)routeToSelectTypeScene;

- (void)routeToAddReportSceneWithType:(YYGReportType)reportType;

- (void)routeToShowReportSceneWithReport:(YYGReport *)report;

- (void)showReport:(YYGReport *)report;

@end
