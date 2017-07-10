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

@interface YGCurrencyChoiceController ()

@property (strong, nonatomic) NSArray <YGCategory *> *currencies;

@end

@implementation YGCurrencyChoiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    if(self.sourceCurrency)
        self.currencies = [manager listCategoriesByType:YGCategoryTypeCurrency exceptForId:self.sourceCurrency.rowId];
    else
        self.currencies = [manager listCategoriesByType:YGCategoryTypeCurrency];
    
    [self.tableView reloadData];
    
    self.navigationItem.title = @"Currency";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    if(self.sourceCurrency)
        self.currencies = [manager listCategoriesByType:YGCategoryTypeCurrency exceptForId:self.sourceCurrency.rowId];
    else
        self.currencies = [manager listCategoriesByType:YGCategoryTypeCurrency];
    
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
    
    cell.textLabel.text = self.currencies[indexPath.row].name;
    cell.detailTextLabel.text = [self.currencies[indexPath.row] shorterName];
    
    return cell;
}

#pragma mark - didSelectRowAtIndexPath and go to YGAccountEditController

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGCategory *currency = self.currencies[indexPath.row];
    
    self.targetCurrency = currency;
    
    [self performSegueWithIdentifier:@"unwindToAccountEdit" sender:self];
}

@end
