//
//  YGOperationCell.m
//  Ledger
//
//  Created by Ян on 22/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationCell.h"

@interface YGOperationCell(){
    
}
@property (strong, nonatomic) UILabel *labelDescription;
@property (strong, nonatomic) UILabel *labelSum;
@end

@implementation YGOperationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){
        _descriptionText = @"";
        _sumText = @"";
        
        // description label
        CGRect labelDescriptionRect = CGRectMake(24,4,160,36);
        self.labelDescription = [[UILabel alloc] initWithFrame:labelDescriptionRect];
        self.labelDescription.textAlignment = NSTextAlignmentLeft;
        
        NSDictionary *descriptionAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],
                                                };
        NSAttributedString *descriptionAttributed = [[NSAttributedString alloc] initWithString:self.descriptionText attributes:descriptionAttributes];
        self.labelDescription.attributedText = descriptionAttributed;
        [self.contentView addSubview:self.labelDescription];
        
        
        // sum label
        CGRect labelSumRect = CGRectMake(194, 4, 160, 36);
        self.labelSum = [[UILabel alloc] initWithFrame:labelSumRect];
        self.labelSum.textAlignment = NSTextAlignmentRight;
        
        NSDictionary *sumAttributes = @{
                                        NSFontAttributeName:[UIFont boldSystemFontOfSize:30],
                                        };
        NSAttributedString *sumAttributed = [[NSAttributedString alloc] initWithString:self.sumText attributes:sumAttributes];
        
        self.labelSum.attributedText = sumAttributed;
        [self.contentView addSubview:self.labelSum];
    }
    
    return self;
}


- (void)setDescriptionText:(NSString *)descriptionText {
    if(![descriptionText isEqualToString:_descriptionText]){
        _descriptionText = [descriptionText copy];
        self.labelDescription.text = _descriptionText;
    }
}

- (void)setSumText:(NSString *)sumText {
    if(![sumText isEqualToString:_sumText]){
        _sumText = [sumText copy];
        self.labelSum.text = _sumText;
    }
}

- (void)setCellTextColor:(UIColor *)cellTextColor {
    if(![cellTextColor isEqual:_cellTextColor]){
        _cellTextColor = cellTextColor;
        self.labelSum.textColor = cellTextColor;
        self.labelDescription.textColor = cellTextColor;
    }
}

@end
