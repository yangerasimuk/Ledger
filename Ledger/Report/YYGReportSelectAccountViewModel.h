//
//  YYGReportSelectAccountViewModel.h
//  Ledger
//
//  Created by Ян on 09.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGEntity.h"


NS_ASSUME_NONNULL_BEGIN

@interface YYGReportSelectAccountViewModel : NSObject

@property (nonatomic, copy) YGEntity *account;
@property (nonatomic, assign, getter=isSelected) BOOL selected;

- (instancetype)initWithAccount:(YGEntity *)account selected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
