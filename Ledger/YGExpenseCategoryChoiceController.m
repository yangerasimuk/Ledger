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

#import "YYGCategorySection.h"
#import "YYGCategoryRow.h"
#import "YYGCategoryOneRowCell.h"
#import "YGTools.h"


@interface YGExpenseCategoryChoiceController (){
    
    YGCategoryManager *p_manager;
    YYGCategorySection *p_section;
}

@end

@implementation YGExpenseCategoryChoiceController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"EXPENSE_CATEGORY_CHOICE_FORM_TITLE", @"Title of Expense choice form.");
    
    [self.tableView registerClass:[YYGCategoryOneRowCell class] forCellReuseIdentifier:kCategoryOneRowCellId];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(reloadDataFromCache) name:@"CategoryManagerExpenseCacheUpdateEvent" object:nil];
    
    [self reloadDataFromCache];

}

/**
 Reload tableView to update outdated cache. Method generated by observer when updated cache in category manager.
 */
- (void) reloadDataFromCache {
    
    // fill inner db
    p_manager = [YGCategoryManager sharedInstance];
    
    p_section = [[YYGCategorySection alloc] initWithCategories:[p_manager categoriesByType:YGCategoryTypeExpense onlyActive:YES]];
    
    [self.tableView reloadData];
}


/**
Dealloc of object. Remove all notifications.
*/
-(void)dealloc {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
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

    return [p_section.rows count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YYGCategoryRow *row = p_section.rows[indexPath.row];
    
    YYGCategoryOneRowCell *cellCategory = (YYGCategoryOneRowCell *)cell;
    
    NSString *indent = @"";
    for(NSInteger i = 0; i < row.nestedLevel; i++){
        indent = [NSString stringWithFormat:@"\t%@", indent];
    }
    
    cellCategory.textLeft = [NSString stringWithFormat:@"%@%@", indent, row.name];
    
    if([self.sourceCategory isEqual:row.category]){
        cellCategory.colorTextLeft = [YGTools colorGreen];
    }
    else{
        cellCategory.colorTextLeft = [UIColor blackColor];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YYGCategoryOneRowCell *cell = [tableView dequeueReusableCellWithIdentifier:kCategoryOneRowCellId];
    
    if(cell == nil){
        cell = [[YYGCategoryOneRowCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCategoryOneRowCellId];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGCategory *category = p_section.rows[indexPath.row].category;
    
    self.targetCategory = category;
    
    [self performSegueWithIdentifier:@"unwindFromExpenseCategoryChoiceToExpenseEdit" sender:self];
}

@end
