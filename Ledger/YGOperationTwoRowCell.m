//
//  YGOperationTwoRowCell.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationTwoRowCell.h"
#import "YGTools.h"

@interface YGOperationTwoRowCell (){
    NSInteger _width;
    NSInteger _fontSizeText;
    NSInteger _fontSizeDetailText;
    UIColor *_colorText;
    UIColor *_colorDetailText;
}
@property (strong, nonatomic) UILabel *labelFirstRowText;
@property (strong, nonatomic) UILabel *labelFirstRowDetailText;
@property (strong, nonatomic) UILabel *labelSecondRowText;
@property (strong, nonatomic) UILabel *labelSecondRowDetailText;
@end

@implementation YGOperationTwoRowCell

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
        
        _width = [YGTools deviceScreenWidth];
        _fontSizeText = [YGTools defaultFontSize];
        _fontSizeDetailText = _fontSizeText;
        
        _colorText = [UIColor blackColor];
        _colorDetailText = [self colorForOperationType:_type];
        
        _firstRowText = @"";
        _firstRowDetailText = @"";
        _secondRowText = @"";
        _secondRowDetailText = @"";
        
        
        // First row text
        self.labelFirstRowText = [[UILabel alloc] initWithFrame:[self rectFirstRowTextLabel]];
        self.labelFirstRowText.textAlignment = NSTextAlignmentLeft;
        self.labelFirstRowText.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.labelFirstRowText];
        
        
        // First row detail text
        self.labelFirstRowDetailText = [[UILabel alloc] initWithFrame:[self rectFirstRowDetailTextLabel]];
        self.labelFirstRowDetailText.textAlignment = NSTextAlignmentRight;
        self.labelFirstRowDetailText.backgroundColor = [UIColor whiteColor];

        [self.contentView addSubview:self.labelFirstRowDetailText];
        
        // Second row text
        self.labelSecondRowText = [[UILabel alloc] initWithFrame:[self rectSecondRowTextLabel]];
        self.labelSecondRowText.textAlignment = NSTextAlignmentLeft;
        self.labelSecondRowText.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.labelSecondRowText];
        
        // Second row detail text
        self.labelSecondRowDetailText = [[UILabel alloc] initWithFrame:[self rectSecondRowDetailTextLabel]];
        self.labelSecondRowDetailText.textAlignment = NSTextAlignmentRight;
        self.labelSecondRowDetailText.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.labelSecondRowDetailText];
         
    }
    return self;
}

- (CGRect)rectFirstRowTextLabel {
    
    static CGRect rectFirstRowTextLabel;
    
    if(rectFirstRowTextLabel.size.width == 0){
        
        switch(_width){
            case 320:
                rectFirstRowTextLabel = CGRectMake(16, 4, 160, 36); // x + width = 160 - 10
                break;
            case 375:
                rectFirstRowTextLabel = CGRectMake(16, 4, 187, 40); // x + width = 187
                break;
            case 414:
                rectFirstRowTextLabel = CGRectMake(20, 6, 207, 42); // x + width = 207
                break;
        }
    }
    return rectFirstRowTextLabel;
}

- (CGRect)rectFirstRowDetailTextLabel {
    
    static CGRect rectFirstRowDetailTextLabel;
    
    if(rectFirstRowDetailTextLabel.size.width == 0){
        switch(_width){
            case 320:
                rectFirstRowDetailTextLabel = CGRectMake(180, 4, 125, 36); // x + width = 320
                break;
            case 375:
                rectFirstRowDetailTextLabel = CGRectMake(210, 6, 150, 40); // x + width = 375
                break;
            case 414:
                rectFirstRowDetailTextLabel = CGRectMake(230, 4, 165, 42);  // x +
                break;
        }
    }
    return rectFirstRowDetailTextLabel;
}

- (CGRect)rectSecondRowTextLabel {
    
    static CGRect rectSecondRowTextLabel;
    
    if(rectSecondRowTextLabel.size.width == 0){
        switch(_width){
            case 320:
                rectSecondRowTextLabel = CGRectMake(16, 40, 160, 36); // x + width = 160
                break;
            case 375:
                rectSecondRowTextLabel = CGRectMake(16, 42, 187, 40); // x + width = 187
                break;
            case 414:
                rectSecondRowTextLabel = CGRectMake(20, 48, 207, 42); // x + width = 207
                break;
        }
    }
    return rectSecondRowTextLabel;
}

- (CGRect)rectSecondRowDetailTextLabel {
    
    static CGRect rectSecondRowDetailTextLabel;
    
    if(rectSecondRowDetailTextLabel.size.width == 0){
        switch(_width){
            case 320:
                rectSecondRowDetailTextLabel = CGRectMake(180, 40, 125, 36); // x + width = 320
                break;
            case 375:
                rectSecondRowDetailTextLabel = CGRectMake(210, 42, 150, 40); // x + width = 375
                break;
            case 414:
                rectSecondRowDetailTextLabel = CGRectMake(230, 48, 165, 42);  // x +
                break;
        }
    }
    return rectSecondRowDetailTextLabel;
}

-(void)setFirstRowText:(NSString *)firstRowText {
    
    if(firstRowText && ![_firstRowText isEqualToString:firstRowText]){
        _firstRowText = firstRowText;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeText],
                                     NSForegroundColorAttributeName:[UIColor blackColor],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_firstRowText
                                              attributes:attributes];
        
        self.labelFirstRowText.attributedText = textAttributed;
    }
}

-(void)setFirstRowDetailText:(NSString *)firstRowDetailText {
    
    if(firstRowDetailText && ![_firstRowDetailText isEqualToString:firstRowDetailText]){
        _firstRowDetailText = firstRowDetailText;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeDetailText],
                                     NSForegroundColorAttributeName:[self colorForOperationType:_type],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_firstRowDetailText
                                              attributes:attributes];
        
        self.labelFirstRowDetailText.attributedText = textAttributed;
    }
    
}

-(void)setSecondRowText:(NSString *)secondRowText {
    
    if(secondRowText && ![_secondRowText isEqualToString:secondRowText]){
        _secondRowText = secondRowText;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeText],
                                     NSForegroundColorAttributeName:[UIColor blackColor],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_secondRowText
                                              attributes:attributes];
        
        self.labelSecondRowText.attributedText = textAttributed;
    }
}

-(void)setSecondRowDetailText:(NSString *)secondRowDetailText {
    
    if(secondRowDetailText && ![_secondRowDetailText isEqualToString:secondRowDetailText]){
        _secondRowDetailText = secondRowDetailText;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeDetailText],
                                     NSForegroundColorAttributeName:[self colorForOperationType:_type],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc]
                                              initWithString:_secondRowDetailText
                                              attributes:attributes];
        
        self.labelSecondRowDetailText.attributedText = textAttributed;
    }
    
}

-(void)setType:(YGOperationType)type {
    _type = type;
}

- (UIColor *)colorForOperationType:(YGOperationType)type {
    
    switch(type){
        case YGOperationTypeExpense: return [UIColor redColor];
        case YGOperationTypeIncome: return [UIColor greenColor];
        case YGOperationTypeAccountActual: return [UIColor grayColor];
        case YGOperationTypeTransfer: return [UIColor grayColor];
        default: return [UIColor blackColor];
    }
}

@end
