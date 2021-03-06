//
//  YYGCounterpartyViewModel.h
//  Ledger
//
//  Created by Ян on 03.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGCategoryViewModel.h"

@interface YYGCounterpartyViewModel : YYGCategoryViewModel <YYGCategoryViewModelable>

- (instancetype)init;

- (NSString *)title;
- (BOOL)isActivateButtonMustBeHide;
- (BOOL)isDeleteButtonMustBeHide;
- (BOOL)letDeactivateAction;
- (BOOL)letDeleteAction;
- (NSString *)canNotDeleteReason;
- (void)add:(YGCategory *)category;
- (void)remove:(YGCategory *)category;
- (void)activate:(YGCategory *)category;
- (void)deactivate:(YGCategory *)category;
- (void)update:(YGCategory *)category;

@end
