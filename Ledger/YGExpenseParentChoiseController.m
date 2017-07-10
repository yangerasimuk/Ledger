//
//  YGExpenseParentChoiseController.m
//  Ledger
//
//  Created by Ян on 14/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGExpenseParentChoiseController.h"
#import "YGCategoryManager.h"
#import "YGCategory.h"
#import "YGExpenseCategoryEditController.h"

@interface YGExpenseParentChoiseController ()

@property (strong, nonatomic) NSArray <YGCategory *> *categories;

@end

@implementation YGExpenseParentChoiseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"expenseCategoryId: %ld", self.expenseCategoryId);
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    _categories = [manager listCategoriesByType:YGCategoryTypeExpense exceptForId:self.expenseCategoryId];
    
    if(self.sourceParentId > 0){
        YGCategory *category = [[YGCategory alloc]
                                initWithRowId:-1
                                categoryType:YGCategoryTypeExpense
                                name:@"No parent"
                                active:YES
                                activeFrom:[NSDate date]
                                activeTo:nil
                                sort:99
                                shortName:nil
                                symbol:nil
                                attach:NO
                                parentId:-1
                                comment:nil];
        
        NSMutableArray *arr = [_categories mutableCopy];
        [arr insertObject:category atIndex:0];
        _categories = [arr copy];
    }
    
    [self.tableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"expenseCategoryId: %ld", self.expenseCategoryId);
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    _categories = [manager listCategoriesByType:YGCategoryTypeExpense exceptForId:self.expenseCategoryId];
    
    if(self.sourceParentId > 0){
        YGCategory *category = [[YGCategory alloc]
                                initWithRowId:-1
                                categoryType:YGCategoryTypeExpense
                                name:@"No parent"
                                active:YES
                                activeFrom:[NSDate date]
                                activeTo:nil
                                sort:99
                                shortName:nil
                                symbol:nil
                                attach:NO
                                parentId:-1
                                comment:nil];
        
        NSMutableArray *arr = [_categories mutableCopy];
        [arr insertObject:category atIndex:0];
        _categories = [arr copy];
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
    return [_categories count];
}

/**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    static NSString *const kCategoryCellId = @"CategoryCellID";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCurrencyItemId forIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kCategoryCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:kCategoryCellId];
    }
    
    cell.textLabel.text = _categories[indexPath.row].name;
    
    return cell;
}
/**/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"-[YGExpenseParentChoiseController tableView:didSelectRowAtIndexPath:]...");
    
    //NSLog(@"Choosen indexPath.row: %ld", indexPath.row);
    
    YGCategory *category = _categories[indexPath.row];
    
    //NSLog(@"Choosen category: %@", [category description]);
    
    self.targetParentId = category.rowId;
    
    [self performSegueWithIdentifier:@"unwindToExpenseCategoryEdit" sender:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
