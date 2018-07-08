//
//  YGOperationIncomeCell.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationIncomeCell.h"

@implementation YGOperationIncomeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.type = YGOperationTypeIncome;
    }
    return self;
}

@end
