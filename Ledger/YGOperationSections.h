//
//  YGOperationSections.h
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGOperationSection.h"
#import "YGOperation.h"

@interface YGOperationSections : NSObject

@property (strong, nonatomic, readonly) NSMutableArray <YGOperationSection *> *list;

-(instancetype)initWithOperations:(NSArray <YGOperation *>*)operations;

@end
