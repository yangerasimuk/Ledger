//
//  YYGReportAccountActualEditViewController.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportAccountActualEditViewControllerInput.h"


@protocol YYGReportAccountActualEditViewControllerOutput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportAccountActualEditViewController : UIViewController
<
YYGReportAccountActualEditViewControllerInput
>

@property (nonatomic, strong) id<YYGReportAccountActualEditViewControllerOutput> output;


@end

NS_ASSUME_NONNULL_END
