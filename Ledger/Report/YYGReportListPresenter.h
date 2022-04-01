//
//  YYGReportListPresenter.h
//  Ledger
//
//  Created by Ян on 01.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportListViewControllerOutput.h"
#import "YYGReportListPresenterInput.h"

@protocol YYGReportListViewControllerInput;
@protocol YYGReportListPresenterOutput;


NS_ASSUME_NONNULL_BEGIN



@interface YYGReportListPresenter : NSObject
<
YYGReportListPresenterInput,
YYGReportListViewControllerOutput
>

//@property (nonatomic, strong) id<YYGReportListPresenterOutput> output;	/**< FlowCoordinator */

@property (nonatomic, strong) id<YYGReportListPresenterOutput> output;	/**< Interactor */

@property (nonatomic, weak) id<YYGReportListViewControllerInput> view;	/**< View */

@end

NS_ASSUME_NONNULL_END
