//
//  YYGEntityRepository.h
//  Ledger
//
//  Created by Ян on 08.11.2021.
//  Copyright © 2021 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGEntityRepositoryInput.h"

@protocol YYGEntityRepositoryOutput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGEntityRepository: NSObject <YYGEntityRepositoryInput>

@property (nonatomic, strong) id<YYGEntityRepositoryOutput> output;

@end

NS_ASSUME_NONNULL_END
