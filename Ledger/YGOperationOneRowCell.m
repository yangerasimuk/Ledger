//
//  YGOperationOneRowCell.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationOneRowCell.h"
#import "YGTools.h"

@interface YGOperationOneRowCell (){
    NSInteger _fontSizeLeftText;
    NSInteger _fontSizeRightText;
    UIColor *_colorLeftText;
    UIColor *_colorRightText;
}
@end

@implementation YGOperationOneRowCell

@synthesize leftText = _leftText, rightText = _rightText;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    // crutch, else cell created with default style
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    
    if(self){
        
        _fontSizeLeftText = [YGTools defaultFontSize];
        _fontSizeRightText = _fontSizeLeftText;
        
        _colorLeftText = [UIColor blackColor];
        _colorRightText = [self colorForOperationType:_type];
        
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

-(void)setLeftText:(NSString *)leftText {
    
    if(leftText && ![_leftText isEqualToString:leftText]){
        _leftText = leftText;
        
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeLeftText],
                                         NSForegroundColorAttributeName:[UIColor blackColor],
                                         };
        NSAttributedString *textAttributed = [[NSAttributedString alloc] initWithString:self.leftText attributes:textAttributes];
        
        self.textLabel.attributedText = textAttributed;
    }
    
}


-(void)setRightText:(NSString *)rightText {
    
    if(rightText && ![_rightText isEqualToString:rightText]){
        _rightText = rightText;
        
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName:[UIFont systemFontOfSize:_fontSizeRightText],
                                         NSForegroundColorAttributeName:[self colorForOperationType:_type],
                                         };
        NSAttributedString *textAttributed = [[NSAttributedString alloc] initWithString:self.rightText attributes:textAttributes];
        
        self.detailTextLabel.attributedText = textAttributed;
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
