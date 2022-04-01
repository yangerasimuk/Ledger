//
//  YYGReportSelectTypePresenterOutput.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportSelectTypeViewModel.h"


@protocol YYGReportSelectTypePresenterOutput

- (NSInteger)selectTypeNumberOfRowsInSection:(NSInteger)section;

- (YYGReportSelectTypeViewModel *)viewModelForIndexPath:(NSIndexPath *)indexPath;

- (void)selectType:(YYGReportType)reportType;

@end
