//
//  YYGStorage.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGStorage.h"
#import "YYGStorageDropbox.h"
#import "YYGStorageLocal.h"

@implementation YYGStorage

+ (id<YYGStoraging>)storageWithType:(YYGStorageType) type {
    
    switch(type){
        case YYGStorageTypeDropbox:
            return [[YYGStorageDropbox alloc] init];
            break;
        case YYGStorageTypeLocal:
            return [[YYGStorageLocal alloc] init];
            break;
        default:
            @throw [NSException exceptionWithName:@"Unknown storage type" reason:@"Can not create storage with unknown type." userInfo:nil];
    }
}

@end
