//
//  YYGReportAccountActualEditPresenterOutput.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

//#import "YYGReportSelectAccountViewModel.h"
#import "YGEntity.h"


@protocol YYGReportAccountActualEditPresenterOutput

//- (YYGReportSelectAccountViewModel *)viewModelForIndexPath:(NSIndexPath *)indexPath;

- (NSArray <YGEntity *> *)loadAccounts;

- (void)addReportActualAccountWithDate:(NSDate *)date accounts:(NSArray <YGEntity *> *)accounts;

- (void)backFromAccountActualEdit;

@end
