//
//  YGOptionViewController.m
//  Ledger
//
//  Created by Ян on 13/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOptionViewController.h"
#import "YGCategoryViewController.h"
#import "YGCategory.h"
#import "YGConfig.h"
#import "YGTools.h"

@interface YGOptionViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchHideDecimalFraction;
@property (weak, nonatomic) IBOutlet UISwitch *switchPullRefreshAddElement;

- (IBAction)switchHideDecimalFractionValueChanged:(UISwitch *)sender;
- (IBAction)switchPullRefreshAddElementValueChanged:(UISwitch *)sender;
@end

@implementation YGOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    YGConfig *config = [YGTools config];
    
    // switch HideDecimalFraction
    BOOL isHideDecimalFraction = NO;
    if([[config valueForKey:@"HideDecimalFraction"] isEqualToString:@"Y"])
        isHideDecimalFraction = YES;
    self.switchHideDecimalFraction.on = isHideDecimalFraction;
    
    // switch PullRefreshToAddElement
    BOOL isPullRefreshToAddElement = NO;
    if([[config valueForKey:@"PullRefreshToAddElement"] isEqualToString:@"Y"])
        isPullRefreshToAddElement = YES;
    self.switchPullRefreshAddElement.on = isPullRefreshToAddElement;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
//    NSLog(@"%@", [self.tableView indexPathForCell:sender]);
//    NSLog(@"%@", [sender description]);
    
    NSInteger section = [self.tableView indexPathForCell:sender].section;
    
    if(section == 0){ // Dictionaries
        
        NSInteger typeId = [self.tableView indexPathForCell:sender].row + 1;
        YGCategoryType type = (YGCategoryType)typeId;
        
        YGCategoryViewController *vc = segue.destinationViewController;
        
        // set type of category list
        vc.categoryType = type;
        
        switch (typeId) {
            case YGCategoryTypeCurrency:
                vc.title = @"Currency";
                break;
            case YGCategoryTypeExpense:
                vc.title = @"Expense";
                break;
            case YGCategoryTypeIncome:
                vc.title = @"Income";
                break;
            case YGCategoryTypeCreditorOrDebtor:
                vc.title = @"Creditor/debtor";
                break;
            case YGCategoryTypeTag:
                vc.title = @"Tag";
                break;
        }
        
    } // if(section == 0){
    
}

- (IBAction)switchHideDecimalFractionValueChanged:(UISwitch *)sender {
    
    YGConfig *config = [YGTools config];
    
    if(sender.isOn)
        [config setValue:@"Y" forKey:@"HideDecimalFraction"];
    else
        [config setValue:@"N" forKey:@"HideDecimalFraction"];
}

- (IBAction)switchPullRefreshAddElementValueChanged:(UISwitch *)sender {
    
    YGConfig *config = [YGTools config];
    
    if(sender.isOn)
        [config setValue:@"Y" forKey:@"PullRefreshToAddElement"];
    else
        [config setValue:@"N" forKey:@"PullRefreshToAddElement"];
}

@end
