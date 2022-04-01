//
//  YYGReportAccountActualEditPresenter.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportAccountActualEditPresenterInput.h"
#import "YYGReportAccountActualEditViewControllerOutput.h"
#import "YYGReport.h"

@protocol YYGReportAccountActualEditViewControllerInput;
@protocol YYGReportAccountActualEditPresenterOutput;


NS_ASSUME_NONNULL_BEGIN

@interface YYGReportAccountActualEditPresenter : NSObject
<
YYGReportAccountActualEditPresenterInput,
YYGReportAccountActualEditViewControllerOutput
>

@property (nonatomic, strong) id<YYGReportAccountActualEditPresenterOutput> output;
@property (nonatomic, weak) id<YYGReportAccountActualEditViewControllerInput> view;

- (instancetype)initWithReport:(YYGReport *)report;

@end

NS_ASSUME_NONNULL_END
