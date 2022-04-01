//
//  YYGReportInteractorInput.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YGEntity.h"


@protocol YYGReportInteractorInput

- (NSInteger)selectTypeNumberOfRowsInSection:(NSInteger)section;

- (NSArray <YGEntity *> *)loadAccounts;

- (void)addReportActualAccountWithDate:(NSDate *)date accounts:(NSArray <YGEntity *> *)accounts;

@end
