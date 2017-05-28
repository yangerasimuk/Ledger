//
//  YGSQLite.h
//  Ledger
//
//  Created by Ян on 28/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGSQLite : NSObject

- (instancetype) init;
+ (YGSQLite *)sharedInstance;

@end
