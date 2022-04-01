//
//  YYGReportFlowCoordinator.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportInteractorOutput.h"
#import "YYGReportListPresenterOutput.h"
#import "YYGReportSelectTypePresenterOutput.h"
#import "YYGReportAccountActualEditPresenterOutput.h"
#import "YYGReportAccountActualPresenterOutput.h"

@protocol YYGReportRouterInput;
@protocol YYGReportInteractorInput;
@protocol YYGReportListPresenterInput;
@protocol YYGReportSelectTypePresenterInput;
@protocol YYGReportAccountActualEditPresenterInput;
@protocol YYGReportAccountActualPresenterInput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportFlowCoordinator : NSObject
<
YYGReportInteractorOutput,
YYGReportListPresenterOutput,
YYGReportSelectTypePresenterOutput,
YYGReportAccountActualEditPresenterOutput,
YYGReportAccountActualPresenterOutput
>

@property (nonatomic, weak) id<YYGReportListPresenterInput> listPresenter;
@property (nonatomic, weak) id<YYGReportSelectTypePresenterInput> selectTypePresenter;
@property (nonatomic, weak) id<YYGReportAccountActualEditPresenterInput> accountActualEditPresenter;
@property (nonatomic, weak) id<YYGReportAccountActualPresenterInput> accountActualPresenter;
@property (nonatomic, strong) id<YYGReportInteractorInput> interactor;
@property (nonatomic, strong) id<YYGReportRouterInput> router;

@end

NS_ASSUME_NONNULL_END
