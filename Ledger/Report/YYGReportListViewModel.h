//
//  YYGReportListViewModel.h
//  Ledger
//
//  Created by Ян on 08.11.2021.
//  Copyright © 2021 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYGReport;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportListViewModel : NSObject

@property (nonatomic, strong) YYGReport *report;

@end

NS_ASSUME_NONNULL_END
