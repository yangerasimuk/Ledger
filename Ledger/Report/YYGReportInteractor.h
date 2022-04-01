//
//  YYGReportInteractor.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportInteractorInput.h"
#import "YYGReportRepositoryOutput.h"
#import "YYGReportListPresenterOutput.h"

@protocol YYGReportInteractorOutput;
@protocol YYGEntityRepositoryInput;
@protocol YYGReportRepositoryInput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportInteractor : NSObject
<
YYGReportInteractorInput,
YYGReportRepositoryOutput,
YYGReportListPresenterOutput
>

@property (nonatomic, strong) id<YYGReportInteractorOutput> output; /**< FlowCoordinator */
@property (nonatomic, strong) id<YYGEntityRepositoryInput> entityRepository; /**< Репозиторий сущностей */
@property (nonatomic, strong) id<YYGReportRepositoryInput> reportRepository; /**< Репозиторий отчётов */

@end

NS_ASSUME_NONNULL_END
