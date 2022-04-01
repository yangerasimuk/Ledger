//
//  YYGReportSelectTypeViewControllerOutput.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportSelectTypeViewModel.h"
#import "YYGReport.h"


@protocol YYGReportSelectTypeViewControllerOutput

- (void)viewDidLoad;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (YYGReportSelectTypeViewModel *)viewModelForIndexPath:(NSIndexPath *)indexPath;

- (void)didSelectReportWithType:(YYGReportType)reportType;

@end
