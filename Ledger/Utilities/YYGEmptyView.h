//
//  YYGEmptyView.h
//  Ledger
//
//  Created by Ян on 02.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN


@interface YYGEmptyView : NSObject

- (instancetype)initWithParentView:(UIView *)parentView
				  navBarController:(UINavigationController *)navBarController
				  tabBarController:(UITabBarController *)tabBarController;

/// Показать пустой экран с сообщением
/// @param message Текст сообщения
- (void)showWithMessage:(NSString *)message;

/// Скрыть экран
- (void)hide;

@end

NS_ASSUME_NONNULL_END
