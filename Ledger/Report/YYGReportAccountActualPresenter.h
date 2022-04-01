//
//  YYGReportAccountActualPresenter.h
//  Ledger
//
//  Created by Ян on 08.04.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportAccountActualViewControllerOutput.h"

@protocol YYGReportAccountActualPresenterOutput;
@protocol YYGReportAccountActualViewControllerInput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportAccountActualPresenter : NSObject
<
YYGReportAccountActualViewControllerOutput
>

@property (nonatomic, strong) id<YYGReportAccountActualPresenterOutput> output;
@property (nonatomic, weak) id<YYGReportAccountActualViewControllerInput> view;

@end

NS_ASSUME_NONNULL_END
