//
//  YYGDebtorCell.m
//  Ledger
//
//  Created by Ян on 20.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDebtorCell.h"

@implementation YYGDebtorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if(self){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setViewModel:(YYGDebtorCellViewModel *)viewModel {
    _viewModel = viewModel;
    [self updateUI];
}

- (void)updateUI {
    NSAttributedString *attributed;
    if(_viewModel.isActive){
        attributed = [[NSAttributedString alloc] initWithString:_viewModel.name
                                                     attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    } else {
        attributed = [[NSAttributedString alloc] initWithString:_viewModel.name
                                                     attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    }
    self.textLabel.attributedText = attributed;
}

@end
