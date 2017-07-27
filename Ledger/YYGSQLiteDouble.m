//
//  YYGSQLiteDouble.m
//  Ledger
//
//  Created by Ян on 27/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGSQLiteDouble.h"

@implementation YYGSQLiteDouble

- (instancetype)initWithDouble:(double)doubleValue {
    self = [super init];
    if(self){
        _doubleValue = doubleValue;
    }
    return self;
}

+ (YYGSQLiteDouble *)objectWithDouble:(double)doubleValue {
    
    YYGSQLiteDouble *d = [[YYGSQLiteDouble alloc] initWithDouble:doubleValue];
    return d;
}

@end


