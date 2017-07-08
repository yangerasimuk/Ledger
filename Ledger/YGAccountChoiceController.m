//
//  YGAccountChoiceController.m
//  Ledger
//
//  Created by Ян on 19/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGAccountChoiceController.h"
#import "YGEntityManager.h"
#import "YGEntity.h"

@interface YGAccountChoiceController (){
    NSArray <YGEntity *> *_accounts;
}

@end

@implementation YGAccountChoiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Account";
    
    YGEntityManager *em = [YGEntityManager sharedInstance];
    
    if(self.sourceAccount){
        _accounts = [em listEntitiesByType:YGEntityTypeAccount exceptForId:self.sourceAccount.rowId];
    }
    else{
        _accounts = [em listEntitiesByType:YGEntityTypeAccount];
    }
    

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
    return [_accounts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kAccountCellIdentifier = @"AccountCellIdentifier";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kAccountCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:kAccountCellIdentifier];
    }
    
    cell.textLabel.text = _accounts[indexPath.row].name;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.targetAccount = _accounts[indexPath.row];
    
    if(self.customer == YGAccountChoiceCustomerExpense){
        [self performSegueWithIdentifier:@"unwindFromAccountChoiceToExpenseEdit" sender:self];
    }
    else if(self.customer == YGAccountChoiceCustomerAccountActual){
        [self performSegueWithIdentifier:@"unwindFromAccountChoiceToAccountActualEdit" sender:self];
    }
    else if(self.customer == YGAccountChoiceCustomerIncome){
        [self performSegueWithIdentifier:@"unwindFromAccountChoiceToIncomeEdit" sender:self];
    }
    else if(self.customer == YGAccountChoiceCustomerTransferSource){
        [self performSegueWithIdentifier:@"unwindFromSourceAccountChoiceToTransferEdit" sender:self];
    }
    else if(self.customer == YGAccountChoiceCustomerTransferTarget){
        [self performSegueWithIdentifier:@"unwindFromTargetAccountChoiceToTransferEdit" sender:self];
    }
    else
        @throw [NSException exceptionWithName:@"-[YGAccountChoiceController tableView:didSelectRowAtIndexPath:" reason:@"Can not choose customer of account choice" userInfo:nil];
}


@end
