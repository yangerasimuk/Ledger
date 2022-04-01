//
//  YYGReportAccountActualViewController.h
//  Ledger
//
//  Created by Ян on 08.04.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportAccountActualViewControllerInput.h"
#import "YYGReport.h"


@protocol YYGReportAccountActualViewControllerOutput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportAccountActualViewController : UIViewController
<
YYGReportAccountActualViewControllerInput
>

@property (nonatomic, nullable, strong) id<YYGReportAccountActualViewControllerOutput> output;

- (instancetype)initWithReport:(YYGReport *)report;

@end

NS_ASSUME_NONNULL_END
