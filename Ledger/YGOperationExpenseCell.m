//
//  YGOperationExpenseCell.m
//  Ledger
//
//  Created by Ян on 16/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationExpenseCell.h"

@interface YGOperationExpenseCell ()
 
@property (strong, nonatomic) UILabel *labelSum;
@property (strong, nonatomic) UILabel *labelCategory;

@end

@implementation YGOperationExpenseCell

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
        
        _categoryName = @"";
        _sumValue = @"";
        
        CGRect labelCategoryRect = CGRectMake(24, 4, 160, 36);
        self.labelCategory = [[UILabel alloc] initWithFrame:labelCategoryRect];
        self.labelCategory.textAlignment = NSTextAlignmentLeft;
        
        NSDictionary *categoryAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],
                                         };
        NSAttributedString *categoryAttributed = [[NSAttributedString alloc] initWithString:self.categoryName attributes:categoryAttributes];
        
        self.labelCategory.attributedText = categoryAttributed;
        [self.contentView addSubview:self.labelCategory];
        
        
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
        
        //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self.contentView addSubview:self.labelSum];
        
    }
    
    return self;
}

- (void)setCategoryName:(NSString *)categoryName {
    if(![categoryName isEqualToString:_categoryName]){
        _categoryName = [categoryName copy];
        self.labelCategory.text = _categoryName;
    }
}


- (void)setSumValue:(NSString *)sumValue {
    if(![sumValue isEqualToString:_sumValue]){
        _sumValue = [sumValue copy];
        self.labelSum.text = _sumValue;
    }
}

@end
