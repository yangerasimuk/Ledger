//
//  YGOperationAccountActualCell.m
//  Ledger
//
//  Created by Ян on 20/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationAccountActualCell.h"

@interface YGOperationAccountActualCell()

@property (strong, nonatomic) UILabel *labelSum;
@property (strong, nonatomic) UILabel *labelAccount;

@end


@implementation YGOperationAccountActualCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){
        
        _accountName = @"";
        _sumValue = @"";
        
        CGRect labelAccountRect = CGRectMake(24, 4, 160, 36);
        self.labelAccount = [[UILabel alloc] initWithFrame:labelAccountRect];
        self.labelAccount.textAlignment = NSTextAlignmentLeft;
        
        NSDictionary *categoryAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],
                                             };
        NSAttributedString *categoryAttributed = [[NSAttributedString alloc] initWithString:self.accountName attributes:categoryAttributes];
        
        self.labelAccount.attributedText = categoryAttributed;
        [self.contentView addSubview:self.labelAccount];
        
        
        // label for sum of operation
        CGRect labelSumRect = CGRectMake(194, 4, 160, 36);
        self.labelSum = [[UILabel alloc] initWithFrame:labelSumRect];
        //        self.labelSum.backgroundColor = [UIColor grayColor];
        //        self.labelSum.opaque = 0.5f;
        self.labelSum.textAlignment = NSTextAlignmentRight;
        
        NSDictionary *sumAttributes = @{
                                        NSFontAttributeName:[UIFont boldSystemFontOfSize:30],
                                        };
        NSAttributedString *sumAttributed = [[NSAttributedString alloc] initWithString:_sumValue attributes:sumAttributes];
        
        self.labelSum.attributedText = sumAttributed;
        
        [self.contentView addSubview:self.labelSum];
        
    }
    
    return self;
}

- (void)setAccountName:(NSString *)categoryName {
    if(![categoryName isEqualToString:_accountName]){
        _accountName = [categoryName copy];
        self.labelAccount.text = _accountName;
    }
}


- (void)setSumValue:(NSString *)sumValue {
    if(![sumValue isEqualToString:_sumValue]){
        _sumValue = [sumValue copy];
        self.labelSum.text = _sumValue;
    }
}


@end
