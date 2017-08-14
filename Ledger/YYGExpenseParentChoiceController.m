//
//  YYGExpenseParentChoiceController.m
//  Ledger
//
//  Created by Ян on 15/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGExpenseParentChoiceController.h"
#import "YGExpenseCategoryEditController.h"
#import "YGCategoryManager.h"
#import "YGCategory.h"
#import "YYGCategorySection.h"
#import "YYGCategoryRow.h"
#import "YYGCategoryOneRowCell.h"
#import "YGTools.h"

@interface YYGExpenseParentChoiceController (){
    YGCategoryManager *p_manager;
    YYGCategorySection *p_section;
}

//@property (strong, nonatomic) NSArray <YGCategory *> *categories;

@end

@implementation YYGExpenseParentChoiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // cell classes for one and two rows
    [self.tableView registerClass:[YYGCategoryOneRowCell class] forCellReuseIdentifier:kCategoryOneRowCellId];
    
    // load data
    [self reloadDataFromCache];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
 
    // load data
    [self reloadDataFromCache];
}

/**
 Reload tableView to update outdated cache. Method generated by observer when updated cache in category manager.
 */
- (void) reloadDataFromCache {
    
    // fill inner db
    p_manager = [YGCategoryManager sharedInstance];

    p_section = [[YYGCategorySection alloc] initWithCategories:[p_manager categoriesByType:YGCategoryTypeExpense onlyActive:YES exceptCategory:self.expenseCategory]];
    
    NSDate *now = [NSDate date];
    
    if(_sourceParentCategory){
        YGCategory *category = [[YGCategory alloc]
                                initWithRowId:-1
                                categoryType:YGCategoryTypeExpense
                                name:NSLocalizedString(@"ROOT_CATEGORY_NAME", @"Name of Root category")
                                active:YES
                                created:now
                                modified:now
                                sort:99
                                symbol:nil
                                attach:NO
                                parentId:-1
                                comment:nil
                                uuid:[NSUUID UUID]];
        
        YYGCategoryRow *row = [[YYGCategoryRow alloc] initWithCategory:category nestedLevel:0];
        
        NSMutableArray *sectionRows = [p_section.rows mutableCopy];
        [sectionRows insertObject:row atIndex:0];
        p_section.rows = [sectionRows copy];
    }

    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [p_section.rows count];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YYGCategoryOneRowCell *cellCategory = (YYGCategoryOneRowCell *)cell;
    
    YYGCategoryRow *row = p_section.rows[indexPath.row];
    
    if(indexPath.row == 0 && row.category.rowId == -1){
        
        cellCategory.colorTextLeft = [UIColor blueColor];
    }
    else if([_expenseCategory isEqual:row.category]){
        cellCategory.colorTextLeft = [YGTools colorRed];
    }
    else if(_sourceParentCategory && [_sourceParentCategory isEqual:row.category]){
        cellCategory.colorTextLeft = [YGTools colorGreen];
    }
    else
        cellCategory.colorTextLeft = [UIColor blackColor];
    
    
    if(self.sourceParentCategory.parentId == -1
       && row.category.parentId != -1){
        cellCategory.colorTextLeft = [YGTools colorRed];
    }
    
    NSLog(@"name: %@, nestedLevel: %ld", row.category.name, row.nestedLevel);
    
    
    NSString *indent = @"";
    for(NSInteger i = 0; i < row.nestedLevel; i++){
        indent = [NSString stringWithFormat:@"\t%@", indent];
    }
    
    cellCategory.textLeft = [NSString stringWithFormat:@"%@%@", indent, row.name];

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YYGCategoryOneRowCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kCategoryOneRowCellId];
    if (cell == nil) {
        cell = [[YYGCategoryOneRowCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:kCategoryOneRowCellId];
    }
    
    return cell;
}


-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YYGCategoryRow *row = p_section.rows[indexPath.row];
    
    if([_expenseCategory isEqual:row.category]){
        return nil;
    }
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //self.targetParentCategory = _categories[indexPath.row];
    self.targetParentCategory = p_section.rows[indexPath.row].category;
    
    [self performSegueWithIdentifier:@"unwindToExpenseCategoryEdit" sender:self];
}

@end
