//
//  YYGReportListViewControllerOutput.h
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportListViewModel.h"


@protocol YYGReportListViewControllerOutput

- (void)viewDidLoad;

- (void)addButtonPressed;

- (NSInteger) numberOfRowsInSection:(NSInteger)section;

- (YYGReportListViewModel *)viewModelForIndexPath:(NSIndexPath *)indexPath;

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
