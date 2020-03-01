//
//  YYGReportAssembly.h
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportListViewController.h"
#import "YYGReportListPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYGReportAssembly : NSObject

- (YYGReportListViewController *)reportViewController;

@end

NS_ASSUME_NONNULL_END
