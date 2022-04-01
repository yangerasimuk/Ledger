//
//  YYGReportSelectTypeViewModel.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReport.h"


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportSelectTypeViewModel : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, assign) YYGReportType reportType;

@end

NS_ASSUME_NONNULL_END
