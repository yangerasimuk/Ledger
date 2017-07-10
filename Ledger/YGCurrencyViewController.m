//
//  YGCurrencyViewController.m
//  Ledger
//
//  Created by Ян on 01/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCurrencyViewController.h"
#import "YGCurrencyEditController.h"
#import "YGCategoryManager.h"

@interface YGCurrencyViewController (){
    BOOL _makeNewCurrency;
}

@property (strong, nonatomic) NSMutableArray <YGCategory *> *currencies;

@end

@implementation YGCurrencyViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    _currencies = [[manager listCategoriesByType:YGCategoryTypeCurrency] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
#ifndef FUNC_DEBUG
#define FUNC_DEBUG
#endif
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    _currencies = [[manager listCategoriesByType:YGCategoryTypeCurrency] mutableCopy];
    [self.tableView reloadData];
    
#ifdef FUNC_DEBUG
    NSLog(@"Currency count: %ld", [_currencies count]);
#endif
    
    // flag
    _makeNewCurrency = NO;
}

- (void)addButtonPressed {

    // flag of creation new currency, bullshit
    _makeNewCurrency = YES;
    [self performSegueWithIdentifier:@"ToCurrencyEditController" sender:self];
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
    
    static NSString *const kCurrencyItemId = @"kCurrencyItemId";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCurrencyItemId forIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kCurrencyItemId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:kCurrencyItemId];
    }
    
    cell.textLabel.text = self.currencies[indexPath.row].name;
        
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ToCurrencyEditController"]){

        YGCurrencyEditController *ec = (YGCurrencyEditController *)segue.destinationViewController;
        
        if(!_makeNewCurrency){

            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            
            YGCategory *item = self.currencies[indexPath.row];
            
            ec.currency = item;
            ec.isNewCurrency = NO;
            
        }
        else{
            ec.isNewCurrency = YES;
            _makeNewCurrency = NO;
        }
        ec.categoryType = YGCategoryTypeCurrency;
        
    }
}


#pragma mark - Actions on rows: delete and deactivate

/**
*/
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if([_currencies count] > 1)
        return YES;
    else
        return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        // save rowId of item to delete from db
        NSInteger rowId = _currencies[indexPath.row].rowId;
        
        [_currencies removeObjectAtIndex:indexPath.row];
        
        // remove from self.currencies
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // remove from db
        YGCategoryManager *manager = [YGCategoryManager sharedInstance];
        
        //[manager removeCategoryItemWithId:rowId];
        [manager removeCategoryWithId:rowId];
        
    }
}




@end
