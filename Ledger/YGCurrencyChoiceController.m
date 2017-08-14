//
//  YGCurrencyChoiceController.m
//  Ledger
//
//  Created by Ян on 15/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCurrencyChoiceController.h"
#import "YGCategoryManager.h"
#import "YGCategory.h"
#import "YGAccountEditController.h"
#import "YGTools.h"

@interface YGCurrencyChoiceController ()

@property (strong, nonatomic) NSArray <YGCategory *> *currencies;

@end

@implementation YGCurrencyChoiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    if(self.sourceCurrency){

        self.currencies = [manager categoriesByType:YGCategoryTypeCurrency onlyActive:YES exceptCategory:self.sourceCurrency];
    }
    else{

        self.currencies = [manager categoriesByType:YGCategoryTypeCurrency onlyActive:YES];
        
    }
    
    [self.tableView reloadData];
    
    self.navigationItem.title = NSLocalizedString(@"CURRENCY_CHOICE_FORM_TITLE", @"Title of Currency choice form.");
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    if(self.sourceCurrency){

        self.currencies = [manager categoriesByType:YGCategoryTypeCurrency onlyActive:YES exceptCategory:self.sourceCurrency];
    }
    else{

        self.currencies = [manager categoriesByType:YGCategoryTypeCurrency onlyActive:YES];
        
    }
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.currencies count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *const kCurrencyCellId = @"CurrencyCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kCurrencyCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:kCurrencyCellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]};
    
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:self.currencies[indexPath.row].name attributes:attributes];
    
    cell.textLabel.attributedText = attributed;
    
    NSDictionary *symbolAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]};
    
    NSAttributedString *symbolAttributed = [[NSAttributedString alloc] initWithString:[self.currencies[indexPath.row] shorterName] attributes:symbolAttributes];
    
    cell.detailTextLabel.attributedText = symbolAttributed;
    
    return cell;
}


#pragma mark - didSelectRowAtIndexPath and go to YGAccountEditController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.targetCurrency = self.currencies[indexPath.row];
    
    [self performSegueWithIdentifier:@"unwindToAccountEdit" sender:self];
}

@end
