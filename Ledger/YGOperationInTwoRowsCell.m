//
//  YGOperationInTwoRowsCell.m
//  Ledger
//
//  Created by Ян on 23/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationInTwoRowsCell.h"

@interface YGOperationInTwoRowsCell (){
    
}
@property (strong, nonatomic) UILabel *labelFirstRowLeftSide;
@property (strong, nonatomic) UILabel *labelFirstRowRightSide;
@property (strong, nonatomic) UILabel *labelSecondRowLeftSide;
@property (strong, nonatomic) UILabel *labelSecondRowRightSide;

//@property (strong, nonatomic) UILabel *labelArrow;
@end

@implementation YGOperationInTwoRowsCell

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
        
        _firstRowLeftSideText = @"";
        _firstRowRightSideText = @"";
        _secondRowLeftSideText = @"";
        _secondRowRightSideText = @"";
        
        // first line and left side label
        CGRect labelFirstRowLeftSideRect = CGRectMake(24,4,160,36);
        self.labelFirstRowLeftSide = [[UILabel alloc] initWithFrame:labelFirstRowLeftSideRect];
        self.labelFirstRowLeftSide.textAlignment = NSTextAlignmentLeft;
        
        //self.labelFirstRowLeftSide.backgroundColor = [UIColor grayColor];
        
        NSDictionary *descriptionAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],};
        NSAttributedString *descriptionAttributed = [[NSAttributedString alloc] initWithString:_firstRowLeftSideText attributes:descriptionAttributes];
        self.labelFirstRowLeftSide.attributedText = descriptionAttributed;
        [self.contentView addSubview:self.labelFirstRowLeftSide];
        
        // first line and right side label
        CGRect labelFirstRowRightSideRect = CGRectMake(194, 4, 160, 36);
        self.labelFirstRowRightSide = [[UILabel alloc] initWithFrame:labelFirstRowRightSideRect];
        self.labelFirstRowRightSide.textAlignment = NSTextAlignmentRight;
        
        //self.labelFirstRowRightSide.backgroundColor = [UIColor orangeColor];
        
//        NSDictionary *descriptionAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],
//                                                };
        NSAttributedString *firstRowRightSideAttributed = [[NSAttributedString alloc] initWithString:_firstRowRightSideText attributes:descriptionAttributes];
        self.labelFirstRowRightSide.attributedText = firstRowRightSideAttributed;
        [self.contentView addSubview:self.labelFirstRowRightSide];
        
        
        // second line and left side label
        CGRect labelSecondRowLeftSideRect = CGRectMake(24,36,160,36);
        self.labelSecondRowLeftSide = [[UILabel alloc] initWithFrame:labelSecondRowLeftSideRect];
        self.labelSecondRowLeftSide.textAlignment = NSTextAlignmentLeft;
        
        //        NSDictionary *descriptionAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],
        //                                                };
        NSAttributedString *secondRowLeftSideAttributed = [[NSAttributedString alloc] initWithString:_secondRowLeftSideText attributes:descriptionAttributes];
        self.labelSecondRowLeftSide.attributedText = secondRowLeftSideAttributed;
        [self.contentView addSubview:self.labelSecondRowLeftSide];
        
        // second line and right side label
        CGRect labelSecondRowRightSideRect = CGRectMake(194,36,160,36);
        self.labelSecondRowRightSide = [[UILabel alloc] initWithFrame:labelSecondRowRightSideRect];
        self.labelSecondRowRightSide.textAlignment = NSTextAlignmentRight;
        
        //        NSDictionary *descriptionAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],
        //                                                };
        NSAttributedString *secondRowRightSideAttributed = [[NSAttributedString alloc] initWithString:_secondRowRightSideText attributes:descriptionAttributes];
        self.labelSecondRowRightSide.attributedText = secondRowRightSideAttributed;
        [self.contentView addSubview:self.labelSecondRowRightSide];
        
//        // &darr;
//        CGRect labelArrowRect = CGRectMake(174,26,30,40);
//        self.labelArrow = [[UILabel alloc] initWithFrame:labelArrowRect];
//        self.labelArrow.textAlignment = NSTextAlignmentCenter;
//        
//        NSDictionary *arrowAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:24],};
//        
//        NSAttributedString *labelArrowAttributed = [[NSAttributedString alloc] initWithString:@"↓" attributes:arrowAttributes];
//        self.labelArrow.attributedText = labelArrowAttributed;
//        [self.contentView addSubview:self.labelArrow];

    
        
    }
    
    return self;
}

- (void)setFirstRowLeftSideText:(NSString *)firstRowLeftSideText {
    if(![firstRowLeftSideText isEqualToString:_firstRowLeftSideText]){
        _firstRowLeftSideText = [firstRowLeftSideText copy];
        self.labelFirstRowLeftSide.text = _firstRowLeftSideText;
    }
}

- (void)setFirstRowRightSideText:(NSString *)firstRowRightSideText {
    if(![firstRowRightSideText isEqualToString:_firstRowRightSideText]){
        _firstRowRightSideText = [firstRowRightSideText copy];
        self.labelFirstRowRightSide.text = _firstRowRightSideText;
    }
}

- (void)setSecondRowLeftSideText:(NSString *)secondRowLeftSideText {
    if(![secondRowLeftSideText isEqualToString:_secondRowLeftSideText]){
        _secondRowLeftSideText = [secondRowLeftSideText copy];
        self.labelSecondRowLeftSide.text = _secondRowLeftSideText;
    }
}

- (void)setSecondRowRightSideText:(NSString *)secondRowRightSideText {
    if(![secondRowRightSideText isEqualToString:_secondRowRightSideText]){
        _secondRowRightSideText = [secondRowRightSideText copy];
        self.labelSecondRowRightSide.text = _secondRowRightSideText;
    }
}

@end
