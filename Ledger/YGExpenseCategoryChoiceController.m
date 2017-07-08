//
//  YGExpenseCategoryChoiceController.m
//  Ledger
//
//  Created by Ян on 19/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGExpenseCategoryChoiceController.h"
#import "YGCategoryManager.h"
#import "YGCategory.h"

@interface YGExpenseCategoryChoiceController (){
    NSArray <YGCategory *> *_categories;
}

@end

@implementation YGExpenseCategoryChoiceController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Expense category";
    
    YGCategoryManager *cm = [YGCategoryManager sharedInstance];
    
    if(self.sourceCategory)
        _categories = [cm listCategoriesByType:YGCategoryTypeExpense exceptForId:self.sourceCategory.rowId];
    else
        _categories = [cm listCategoriesByType:YGCategoryTypeExpense];

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
    return [_categories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *const kCategoryCellIdentifier = @"CategoryCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCategoryCellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCategoryCellIdentifier];
    }
    
    cell.textLabel.text = _categories[indexPath.row].name;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGCategory *category = _categories[indexPath.row];
    
    self.targetCategory = category;
    
    [self performSegueWithIdentifier:@"unwindFromExpenseCategoryChoiceToExpenseEdit" sender:self];
}

@end
