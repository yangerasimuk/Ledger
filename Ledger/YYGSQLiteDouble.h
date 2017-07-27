//
//  YYGSQLiteDouble.h
//  Ledger
//
//  Created by Ян on 27/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYGSQLiteDouble : NSObject

@property (assign, nonatomic) double doubleValue;

+ (YYGSQLiteDouble *)objectWithDouble:(double)doubleValue;

@end
