//
//  YYGSemanticColor.h
//  Ledger
//
//  Created by Ян on 03.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN


@interface YYGSemanticColor : NSObject

@property(class, nonatomic, readonly) UIColor *emptyViewBackground; /**< Цвет фота на экране без данных */
@property(class, nonatomic, readonly) UIColor *emptyViewMessage; /**< Цвет текста на экране без данных */

@end

NS_ASSUME_NONNULL_END
