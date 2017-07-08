//
//  YGSections.h
//  Ledger
//
//  Created by Ян on 16/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class YGSection, YGOperation;
#import "YGSection.h"
#import "YGOperation.h"

@interface YGSections : NSObject

@property (strong, nonatomic, readonly) NSMutableArray <YGSection *> *list;

-(instancetype)initWithOperations:(NSArray <YGOperation *>*)operations;

@end
