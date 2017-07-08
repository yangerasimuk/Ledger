//
//  YGOperationCell.h
//  Ledger
//
//  Created by Ян on 22/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGOperationCell : UITableViewCell

@property (copy, nonatomic) NSString *descriptionText;
@property (copy, nonatomic) NSString *sumText;
@property (copy, nonatomic) UIColor *cellTextColor;

@end
