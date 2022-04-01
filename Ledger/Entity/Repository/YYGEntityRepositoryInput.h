//
//  YYGEntityRepositoryInput.h
//  Ledger
//
//  Created by Ян on 08.11.2021.
//  Copyright © 2021 Yan Gerasimuk. All rights reserved.
//

#import "YGEntity.h"


@protocol YYGEntityRepositoryInput

- (NSArray <YGEntity *> *)accounts;

@end
