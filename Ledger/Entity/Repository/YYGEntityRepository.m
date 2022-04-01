//
//  YYGEntityRepository.m
//  Ledger
//
//  Created by Ян on 08.11.2021.
//  Copyright © 2021 Yan Gerasimuk. All rights reserved.
//

#import "YYGEntityRepository.h"
#import "YYGEntityRepositoryOutput.h"
#import "YGEntityManager.h"


@implementation YYGEntityRepository

- (NSArray<YGEntity *> *)accounts
{
	YGEntityManager *manager = [YGEntityManager sharedInstance];
	return [manager entitiesByType:YGEntityTypeAccount];
}

@end
