//
//  YYGReportSelectTypeViewController.h
//  Ledger
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGReportSelectTypeViewControllerInput.h"

@protocol YYGReportSelectTypeViewControllerOutput;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportSelectTypeViewController : UIViewController
<
YYGReportSelectTypeViewControllerInput
>

@property (nonatomic, strong) id<YYGReportSelectTypeViewControllerOutput> output;	/**< Презентер */

@end

NS_ASSUME_NONNULL_END
