//
//  YYGReportAccountActualEditViewControllerOutput.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGReportSelectAccountViewModel.h"

@protocol YYGReportAccountActualEditViewControllerOutput

- (void)viewDidLoad;

//- (void)back;

- (BOOL)isNewReportMode;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (YYGReportSelectAccountViewModel *)viewModelForIndex:(NSInteger)index;

- (void)addReportWithDate:(NSDate *)date;

- (void)addReportWithDate:(NSDate *)date accounts:(NSArray<YGEntity *> *)accounts;

@end
