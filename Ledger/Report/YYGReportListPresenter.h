//
//  YYGReportListPresenter.h
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportListViewControllerOutput.h"

@protocol YYGReportListViewControllerInput;


NS_ASSUME_NONNULL_BEGIN

@interface YYGReportListPresenter : NSObject <YYGReportListViewControllerOutput>

@property (nonatomic, weak) id<YYGReportListViewControllerInput> view;

@end

NS_ASSUME_NONNULL_END
