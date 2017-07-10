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
    
    _width = [YGTools deviceScreenWidth];
    _fontSizeText = [YGTools defaultFontSize];
    _fontSizeDetailText = _fontSizeText;
    
    _colorText = [UIColor blackColor];
    _colorDetailText = [self colorForOperationType:_type];

    
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    if(self){
        
        _firstRowText = @"";
        _firstRowDetailText = @"";
        _secondRowText = @"";
        _secondRowDetailText = @"";
        
        
        // First row text
        self.labelFirstRowText = [[UILabel alloc] initWithFrame:[self rectFirstRowTextLabel]];
        self.labelFirstRowText.textAlignment = NSTextAlignmentLeft;
        
        /*
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeText],
                                     NSForegroundColorAttributeName:[UIColor blackColor],
                                     };
        NSAttributedString *textAttributed = [[NSAttributedString alloc] initWithString:self.firstRowText attributes:attributes];
        
        self.labelFirstRowText.attributedText = textAttributed;
         */
        [self.contentView addSubview:self.labelFirstRowText];

#ifdef FUNC_DEBUG
        self.labelFirstRowText.backgroundColor = [UIColor greenColor];
#endif
        
        
        // First row detail text
        self.labelFirstRowDetailText = [[UILabel alloc] initWithFrame:[self rectFirstRowDetailTextLabel]];
        self.labelFirstRowDetailText.textAlignment = NSTextAlignmentRight;
                /*
        attributes = @{
                       NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeDetailText],
                       NSForegroundColorAttributeName:[self colorForOperationType:_type],
                       };
        textAttributed = [[NSAttributedString alloc] initWithString:self.firstRowDetailText attributes:attributes];
        self.labelFirstRowText.attributedText = textAttributed;
                 */
        [self.contentView addSubview:self.labelFirstRowDetailText];
        
#ifdef FUNC_DEBUG
        self.labelFirstRowDetailText.backgroundColor = [UIColor brownColor];
#endif
        
        // Second row text
        self.labelSecondRowText = [[UILabel alloc] initWithFrame:[self rectSecondRowTextLabel]];
        self.labelSecondRowText.textAlignment = NSTextAlignmentLeft;
        /*
        attributes = @{
                       NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeText],
                       NSForegroundColorAttributeName:[UIColor blackColor],
                       };
        textAttributed = [[NSAttributedString alloc] initWithString:self.secondRowText attributes:attributes];
        
        self.labelSecondRowText.attributedText = textAttributed;
         */
        [self.contentView addSubview:self.labelSecondRowText];
        
#ifdef FUNC_DEBUG
        self.labelSecondRowText.backgroundColor = [UIColor yellowColor];
#endif
        
        
        // Second row detail text
        self.labelSecondRowDetailText = [[UILabel alloc] initWithFrame:[self rectSecondRowDetailTextLabel]];
        self.labelSecondRowDetailText.textAlignment = NSTextAlignmentRight;
        
        /*
        attributes = @{
                       NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeText],
                       NSForegroundColorAttributeName:[self colorForOperationType:_type],
                       };
        textAttributed = [[NSAttributedString alloc] initWithString:self.secondRowDetailText attributes:attributes];
        self.labelSecondRowDetailText.attributedText = textAttributed;
         */
        [self.contentView addSubview:self.labelSecondRowDetailText];
        
#ifdef FUNC_DEBUG
        self.labelFirstRowDetailText.backgroundColor = [UIColor purpleColor];
#endif
         
        
    }
    return self;
}

- (CGRect)rectFirstRowTextLabel {
    
    switch(_width){
        case 320: return CGRectMake(16, 4, 160, 36); // x + width = 160 - 10
        case 375: return CGRectMake(16, 4, 187, 40); // x + width = 187
        case 414: return CGRectMake(20, 6, 207, 42); // x + width = 207
    }
    
    return CGRectZero;
}

- (CGRect)rectFirstRowDetailTextLabel {
    
    switch(_width){
        case 320: return CGRectMake(180, 4, 125, 36); // x + width = 320
        case 375: return CGRectMake(210, 6, 150, 40); // x + width = 375
        case 414: return CGRectMake(230, 4, 165, 42);  // x +
    }
    return CGRectZero;
}

- (CGRect)rectSecondRowTextLabel {
    
    switch(_width){
        case 320: return CGRectMake(16, 40, 160, 36); // x + width = 160
        case 375: return CGRectMake(16, 42, 187, 40); // x + width = 187
        case 414: return CGRectMake(20, 48, 207, 42); // x + width = 207
    }
    return CGRectZero;
}

- (CGRect)rectSecondRowDetailTextLabel {
    
    switch(_width){
        case 320: return CGRectMake(180, 40, 125, 36); // x + width = 320
        case 375: return CGRectMake(210, 42, 150, 40); // x + width = 375
        case 414: return CGRectMake(230, 48, 165, 42);  // x +
    }
    return CGRectZero;
}

-(void)setFirstRowText:(NSString *)firstRowText {
    
    if(![_firstRowText isEqualToString:firstRowText]){
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
    
    if(![_firstRowDetailText isEqualToString:firstRowDetailText]){
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
    
    if(![_secondRowText isEqualToString:secondRowText]){
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
    
    if(![_secondRowDetailText isEqualToString:secondRowDetailText]){
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
