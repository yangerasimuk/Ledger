//
//  YGCategoryViewController.m
//  Ledger
//
//  Created by Ян on 13/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCategoryViewController.h"
#import "YGCurrencyEditController.h"
#import "YGExpenseCategoryEditController.h"
#import "YGCategoryDefaultEditController.h"
#import "YGCategoryManager.h"

@interface YGCategoryViewController ()

@property (strong, nonatomic) NSArray <YGCategory *> *categories;

@end

@implementation YGCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // fill inner db
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    self.categories = [manager listCategoriesByType:self.categoryType];
    
    [self.tableView reloadData];
    
    // add button on nav bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddButtonPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    _categories = [manager listCategoriesByType:self.categoryType];
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)actionAddButtonPressed {
    
    if(self.categoryType == YGCategoryTypeCurrency){
        YGCurrencyEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CurrencyDetailScene"];
        
        vc.isNewCurrency = YES;
        vc.currency = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(self.categoryType == YGCategoryTypeExpense){
        
        YGExpenseCategoryEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ExpenseCategoryDetailScene"];
        
        vc.isNewExpenseCategory = YES;
        vc.expenseCategory = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(self.categoryType == YGCategoryTypeIncome
            || (self.categoryType == YGCategoryTypeCreditorOrDebtor)
            || (self.categoryType == YGCategoryTypeTag)){
        
        YGCategoryDefaultEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryDefaultEditScene"];
        
        vc.categoryType = self.categoryType;
        vc.isNewCategory = YES;
        vc.category = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    if(self.categoryType == YGCategoryTypeCurrency){
        YGCurrencyEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CurrencyDetailScene"];
        
        vc.isNewCurrency = NO;
        vc.currency = _categories[indexPath.row];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(self.categoryType == YGCategoryTypeExpense){
        
        YGExpenseCategoryEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ExpenseCategoryDetailScene"];
        
        vc.isNewExpenseCategory = NO;
        vc.expenseCategory = self.categories[indexPath.row];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if(self.categoryType == YGCategoryTypeIncome
            || (self.categoryType == YGCategoryTypeCreditorOrDebtor)
            || (self.categoryType == YGCategoryTypeTag)){
        
        YGCategoryDefaultEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryDefaultEditScene"];
        
        vc.categoryType = self.categoryType;
        vc.isNewCategory = NO;
        vc.category = _categories[indexPath.row];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categories count];
}

/**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *const kCategoryCellId = @"CategoryCellID";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger fontSize = [[defaults objectForKey:@"DefaultFontSize"] integerValue];
    
    YGCategory *category = self.categories[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kCategoryCellId];
    if (cell == nil) {
        
        if(category.type == YGCategoryTypeCurrency){
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:kCategoryCellId];
            
            //cell.detailTextLabel.text = [category shorterName];
            
            NSDictionary *symbolAttributes = @{
                                               NSFontAttributeName:[UIFont systemFontOfSize:fontSize+2],
                                               NSForegroundColorAttributeName:[UIColor grayColor],
                                               };
            NSAttributedString *symbolAttributed = [[NSAttributedString alloc] initWithString:[category shorterName] attributes:symbolAttributes];
            
            cell.detailTextLabel.attributedText = symbolAttributed;
            
        }
        else{
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:kCategoryCellId];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    NSDictionary *nameAttributes = nil;
    

    if(category.active){
        nameAttributes = @{
                           NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                           };
    }
    else{
        nameAttributes = @{
                           NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                           NSForegroundColorAttributeName:[UIColor grayColor],
                           };
    }
    NSAttributedString *nameAttributed = [[NSAttributedString alloc] initWithString:category.name attributes:nameAttributes];
    cell.textLabel.attributedText = nameAttributed;
    
    return cell;
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
