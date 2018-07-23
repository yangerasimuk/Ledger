//
//  YYGDebtorsViewModel.h
//  Ledger
//
//  Created by Ян on 20.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCategory.h"

@interface YYGDebtorsViewModel : NSObject

@property (strong, nonatomic, readonly) NSArray <YGCategory *> *debtors;
@property (assign, nonatomic) BOOL debtorsLoaded;

- (instancetype)init;
- (void)loadDebtors;

@end
