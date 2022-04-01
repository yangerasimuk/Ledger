//
//  YYGReportSelectTypePresenter.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportSelectTypePresenterInput.h"
#import "YYGReportSelectTypeViewControllerOutput.h"

@protocol YYGReportSelectTypePresenterOutput;
@protocol YYGReportSelectTypeViewControllerInput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportSelectTypePresenter : NSObject
<
YYGReportSelectTypePresenterInput,
YYGReportSelectTypeViewControllerOutput
>

@property (nonatomic, strong) id<YYGReportSelectTypePresenterOutput> output;	/** FlowCoordinator */
@property (nonatomic, weak) id<YYGReportSelectTypeViewControllerInput> view;	/** View */

@end

NS_ASSUME_NONNULL_END
