//
//  YGOperationOneRowCell.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationOneRowCell.h"
#import "YGTools.h"

@implementation YGOperationOneRowCell

@synthesize text = _text, detailText = _detailText;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.accessoryType = UITableViewCellAccessoryNone;
    
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    // crutch, else cell created with default style
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    
    if(self){
        
        //self.styl
        
        NSLog(@"style: %ld", style);
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setText:(NSString *)text {
    _text = text;
    
    NSInteger fontSize = [YGTools defaultFontSize];
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                                     NSForegroundColorAttributeName:[UIColor blackColor],
                                     };
    NSAttributedString *textAttributed = [[NSAttributedString alloc] initWithString:self.text attributes:textAttributes];
    
    self.textLabel.attributedText = textAttributed;
}

-(void)setDetailText:(NSString *)detailText {
    
    _detailText = detailText;
    
    NSInteger fontSize = [YGTools defaultFontSize];
    
    NSDictionary *textAttributes = @{
                                    NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                                    NSForegroundColorAttributeName:[self colorForOperationType:_type],
                                    };
    NSAttributedString *textAttributed = [[NSAttributedString alloc] initWithString:self.detailText attributes:textAttributes];
    
    self.detailTextLabel.attributedText = textAttributed;
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
