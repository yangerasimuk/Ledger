//
//  YYGReportRepository.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportRepositoryInput.h"

@protocol YYGReportRepositoryOutput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportRepository : NSObject <YYGReportRepositoryInput>

@property (nonatomic, weak) id<YYGReportRepositoryOutput> output;

@end

NS_ASSUME_NONNULL_END
