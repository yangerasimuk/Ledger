//
//  YGStorage.m
//  Ledger
//
//  Created by Ян on 07/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGStorage.h"
#import "YGStorageLocal.h"
#import "YGBackup.h"

@interface YGStorage ()

@end

@implementation YGStorage

- (instancetype)initWithName:(NSString *)name type:(YGStorageType)type {
    self = [super init];
    if(self){
        self.name = name;
        self.type = type;
    }
    return self;
}

+ (id<YGStoraging>)storageWithName:(NSString *)name {

    id<YGStoraging> storage = nil;
    
    if([name isEqualToString:@"Local"])
        storage = [[YGStorageLocal alloc] init];
    else
        @throw [NSException exceptionWithName:@"-[YGStorage initWithName]" reason:[NSString stringWithFormat:@"Unknown storage type name: %@", name] userInfo:nil];
    
    return storage;

}

@end
