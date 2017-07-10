//
//  YGOperationSectionHeader.m
//  Ledger
//
//  Created by Ян on 10/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationSectionHeader.h"
#import "YGOperationSection.h"
#import "YGTools.h"

@implementation YGOperationSectionHeader

-(instancetype) initWithSection:(YGOperationSection *)section {
    
    CGFloat width = [YGTools deviceScreenWidth];
    CGFloat height = [YGOperationSectionHeader heightSectionHeader];
    
    self = [super initWithFrame:CGRectMake(0.0, 0.0, width, height)];
    if(self){
        
        self.backgroundColor = [UIColor whiteColor]; //clearColor
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
        
        headerLabel.backgroundColor = [UIColor colorWithRed:(float)247/255 green:(float)247/255 blue:(float)247/255 alpha:1.0f];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor blackColor];
        headerLabel.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = section.name;
        
        [self addSubview:headerLabel];
        
    }
    return self;
}

+ (CGFloat)heightSectionHeader {
    
    static CGFloat heightSectionHeader = 0.f;
    
    if(heightSectionHeader == 0){
        
        NSInteger width = [YGTools deviceScreenWidth];
        
        switch(width){
            case 320:
                heightSectionHeader = 26.f;
                break;
            case 375:
                heightSectionHeader = 30.f;
                break;
            case 414:
                heightSectionHeader = 34.f;
                break;
            default:
                heightSectionHeader = 26.f;
        }
    }
    return heightSectionHeader;
}

@end
