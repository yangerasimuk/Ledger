//
//  YYGReportListViewController.h
//  Ledger
//
//  Created by Ян on 18/08/2019.
//  Copyright © 2019 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportListViewControllerInput.h"

@protocol YYGReportListViewControllerOutput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportListViewController : UIViewController <YYGReportListViewControllerInput>

@property (nonatomic, strong) id<YYGReportListViewControllerOutput> output;

@end

NS_ASSUME_NONNULL_END
