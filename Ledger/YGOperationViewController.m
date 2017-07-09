//
//  YGOperationViewController.m
//  Ledger
//
//  Created by Ян on 12/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationViewController.h"
#import "YGOperationCell.h"
#import "YGOperationInTwoRowsCell.h"
#import "YGOperationExpenseCell.h"
#import "YGOperationAccountActualCell.h"
#import "YGSections.h"
#import "YGCategoryManager.h"
#import "YGOperationManager.h"
#import "YGEntityManager.h"
#import "YGEntity.h"

#import "YGExpenseEditController.h"
#import "YGAccountActualEditController.h"
#import "YGIncomeEditController.h"
#import "YGTransferEditController.h"

#import "YGTools.h"
#import "YGConfig.h"

#define USE_MEMORY_CACHE

static NSString *const kOperationCellIdentifier = @"OperationCellIdentifier";
static NSString *const kOperationInTwoRowsCellIdentifier = @"OperationInTwoRowsCellIdentifier";
static NSString *const kExpenseCellIdentifier = @"ExpenseCellIdentifier";
static NSString *const kAccountActualCellIdentifier = @"AccountActualCellIdentifier";

@interface YGOperationViewController (){
    YGSections *_sections;
    
    NSArray <YGCategory *> *_currencies;
    NSArray <YGCategory *> *_expenseCategories;
    NSArray <YGCategory *> *_incomeSources;
    NSArray <YGCategory *> *_creditorsOrDebtors;
    NSArray <YGCategory *> *_tags;
    NSArray <YGEntity *> *_accounts;
    NSArray <YGEntity *> *_debts;
    
    YGOperationManager *_om;
    YGCategoryManager *_cm;
    YGEntityManager *_em;
    
    BOOL _isHideDecimalFraction;
    BOOL _isPullRefreshToAddElement;
    
    UIRefreshControl *_refresh;
}

@end

@implementation YGOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _om = [YGOperationManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
    _em = [YGEntityManager sharedInstance];
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddBarButton)];
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    // expense cell
    [self.tableView registerClass:[YGOperationExpenseCell class]
           forCellReuseIdentifier:kExpenseCellIdentifier];
    
    // base 1 row cell, ex.: income cell
    [self.tableView registerClass:[YGOperationCell class] forCellReuseIdentifier:kOperationCellIdentifier];
    
    // base 2 rows cell, ex.: transfer cell
    [self.tableView registerClass:[YGOperationInTwoRowsCell class] forCellReuseIdentifier:kOperationInTwoRowsCellIdentifier];
    
    // account actual cell
    [self.tableView registerClass:[YGOperationAccountActualCell class] forCellReuseIdentifier:kAccountActualCellIdentifier];
    
    // get list of operations
    NSArray *operations = [_om listOperations];
    
    _sections = [[YGSections alloc] initWithOperations:operations];
    
    // get list of currencies
    _currencies = [_cm listCategoriesByType:YGCategoryTypeCurrency];
    
    // get list of expense categories
    _expenseCategories = [_cm listCategoriesByType:YGCategoryTypeExpense];
    
    // get list of income sources
    _incomeSources = [_cm listCategoriesByType:YGCategoryTypeIncome];
    
    // get list of creditors/debtors
    _creditorsOrDebtors = [_cm listCategoriesByType:YGCategoryTypeCreditorOrDebtor];
    
    // get list of tags
    _tags = [_cm listCategoriesByType:YGCategoryTypeTag];
    
    // get list of accounts
    _accounts = [_em.entities valueForKey:NSStringFromEntityType(YGEntityTypeAccount)];
    
    // get list of credits
    //_debts = [_em.entities valueForKey:NSStringFromEntityType(YGEntityTypeDebt)];
    
    [self updateUI];
    
    
}

- (void)pullRefreshSwipe:(UIRefreshControl *)refresh {
    
    [refresh beginRefreshing];
    [refresh endRefreshing];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addOperation];
    });
}


- (void)addOperation {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Choose operation" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *addExpenseAction = [UIAlertAction actionWithTitle:@"Expense" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddExpense];
    }];
    [controller addAction:addExpenseAction];
    
    UIAlertAction *addIncomeAction = [UIAlertAction actionWithTitle:@"Income" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddIncome];
    }];
    [controller addAction:addIncomeAction];
    
    
    
    UIAlertAction *addAccountActualAction = [UIAlertAction actionWithTitle:@"Balance" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddAccountActual];
    }];
    [controller addAction:addAccountActualAction];
    
    UIAlertAction *addTransferAction = [UIAlertAction actionWithTitle:@"Transfer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddTransfer];
    }];
    [controller addAction:addTransferAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:cancelAction];
    
    [self presentViewController:controller animated:YES completion:nil];


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateUI];
    
    // get list of operations
    NSArray *operations = [_om listOperations];
    
    _sections = [[YGSections alloc] initWithOperations:operations];
    
    [self.tableView reloadData];
}

- (void)updateUI {
    YGConfig *config = [YGTools config];
    
    // Hide decimal fraction
    _isHideDecimalFraction = NO;
    if([[config valueForKey:@"HideDecimalFraction"] isEqualToString:@"Y"])
        _isHideDecimalFraction = YES;
    
    // Pull refresh add new element
    _isPullRefreshToAddElement = NO;
    if([[config valueForKey:@"PullRefreshToAddElement"] isEqualToString:@"Y"]){
        _isPullRefreshToAddElement = YES;
        
        _refresh = [[UIRefreshControl alloc] init];
        [_refresh addTarget:self action:@selector(pullRefreshSwipe:) forControlEvents:UIControlEventValueChanged];
        
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:@"New operation" attributes:nil];
        _refresh.attributedTitle = attr;
        
        self.refreshControl = _refresh;
    }
    else{
        _refresh = nil;
        self.refreshControl = nil;
    }
}

#pragma mark - Object from dictionaries: categories and entities

- (YGCategory *)categoryByType:(YGCategoryType)type rowId:(NSInteger)rowId {
    
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"rowId = %ld", rowId];
    
    NSArray *filteredArray = nil;
    
    if(type == YGCategoryTypeCurrency)
        filteredArray = [_currencies filteredArrayUsingPredicate:idPredicate];
    else if(type == YGCategoryTypeExpense)
        filteredArray = [_expenseCategories filteredArrayUsingPredicate:idPredicate];
    else if(type == YGCategoryTypeIncome)
        filteredArray = [_incomeSources filteredArrayUsingPredicate:idPredicate];
    else if(type == YGCategoryTypeCreditorOrDebtor)
        filteredArray = [_creditorsOrDebtors filteredArrayUsingPredicate:idPredicate];
    else
        @throw [NSException exceptionWithName:@"-[YGOperationViewController categoryByType:rowId:]" reason:@"Unknown category type" userInfo:nil];
    
    if([filteredArray count] > 1)
        @throw [NSException exceptionWithName:@"-[YGOperationViewController categoryByRowId" reason:@"Undefined choice of category by id" userInfo:nil];
    else if ([filteredArray count] < 1)
        @throw [NSException exceptionWithName:@"-[YGOperationViewController categoryByRowId" reason:[NSString stringWithFormat:@"Can not get category by id. Type: %ld, Id: %ld", (long)type, rowId] userInfo:nil];
    
    return filteredArray[0];
}

- (YGEntity *)entityByType:(YGEntityType)type rowId:(NSInteger)rowId {
    
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"rowId = %ld", rowId];
    
    NSArray *filteredArray = nil;
    
    if(type == YGEntityTypeAccount)
        filteredArray = [_accounts filteredArrayUsingPredicate:idPredicate];
    else if(type == YGEntityTypeDebt)
        filteredArray = [_debts filteredArrayUsingPredicate:idPredicate];
    else
        @throw [NSException exceptionWithName:@"-[YGOperationViewController entityByType:rowId:]" reason:@"Unknown entity type" userInfo:nil];
    
    if([filteredArray count] > 1)
        @throw [NSException exceptionWithName:@"-[YGOperationViewController entityByRowId" reason:@"Undefined choice of entity by id" userInfo:nil];
    else if ([filteredArray count] < 1)
        @throw [NSException exceptionWithName:@"-[YGOperationViewController entityByRowId" reason:@"Can not get entity by id" userInfo:nil];

    return filteredArray[0];
}


- (void)actionAddBarButton {
    [self addOperation];
}

#pragma mark - Add actions

- (void)actionAddExpense {
    
    YGExpenseEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGExpenseEditScene"];
    
    vc.isNewExpense = YES;
    vc.expense = nil;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionAddIncome {
    
    YGIncomeEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGIncomeEditScene"];
    
    vc.isNewIncome = YES;
    vc.income = nil;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)actionAddAccountActual {
    
    YGAccountActualEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGAccountActualEditScene"];
    
    vc.isNewAccountAcutal = YES;
    vc.accountActual = nil;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionAddTransfer {
    
    YGTransferEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGTransferEditScene"];
    
    vc.isNewTransfer = YES;
    vc.transfer = nil;
    
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGOperation *operation = _sections.list[indexPath.section].operations[indexPath.row];

    if(operation.type == YGOperationTypeExpense){
        
        YGExpenseEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGExpenseEditScene"];
        
        vc.isNewExpense = NO;
        vc.expense = [operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operation.type == YGOperationTypeAccountActual){
        
        YGAccountActualEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGAccountActualEditScene"];
        
        vc.isNewAccountAcutal = NO;
        vc.accountActual = [operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if(operation.type == YGOperationTypeIncome){
        
        YGIncomeEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGIncomeEditScene"];
        
        vc.isNewIncome = NO;
        vc.income = [operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operation.type == YGOperationTypeTransfer){
        
        YGTransferEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGTransferEditScene"];
        
        vc.isNewTransfer = NO;
        vc.transfer = [operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}


// 320x22
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGRect superViewRect =  [tableView.superview frame];
    
    // create the parent view that will hold header Label
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, superViewRect.size.width, 22.0f)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, superViewRect.size.width, 22.0f)];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    
    float rgb = (float)247/255;
    
    UIColor *backColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0f];
    headerLabel.backgroundColor = backColor;
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = [YGTools humanViewOfDate:_sections.list[section].date];

    [headerView addSubview:headerLabel];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGOperation *operation = _sections.list[indexPath.section].operations[indexPath.row];
    
    if(operation.type == YGOperationTypeTransfer)
        return 76;
    else
        return 44;
}


#pragma mark - UITableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sections.list count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_sections.list[section].operations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *formatForIncomeNumbers;
    static NSString *formatForExpenseNumbers;
    static NSString *formatForEqualNumbers;
    if(_isHideDecimalFraction){
        formatForIncomeNumbers = @"+ %.f %@";
        formatForExpenseNumbers = @"- %.f %@";
        formatForEqualNumbers = @"= %.f %@";
    }
    else{
        formatForIncomeNumbers = @"+ %.2f %@";
        formatForExpenseNumbers = @"- %.2f %@";
        formatForEqualNumbers = @"= %.2f %@";
    }
    
    
    // check class
    YGOperation *operation = _sections.list[indexPath.section].operations[indexPath.row];
    
    if(operation.type == YGOperationTypeExpense){
        
        // if Expense -> source == account and target == expenseCategory
        
        YGOperationExpenseCell *cell = [tableView dequeueReusableCellWithIdentifier:kExpenseCellIdentifier];
        if (cell == nil) {
            cell = (YGOperationExpenseCell *)[[UITableViewCell alloc]
                                              initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:kExpenseCellIdentifier];
        }

        // account
        YGEntity *account = [self entityByType:YGEntityTypeAccount rowId:operation.sourceId];
        
        // category
        YGCategory *expenseCategory = [self categoryByType:YGCategoryTypeExpense rowId:operation.targetId];
        cell.categoryName = expenseCategory.name;
        
        // currency
        YGCategory *currency = [self categoryByType:YGCategoryTypeCurrency rowId:account.currencyId];
        
        // sum
        // !!!!! cell.sumValue = [NSString stringWithFormat:formatForNumbers, operation.sourceSum];
        
        NSString *stringForSumValue = [NSString stringWithFormat:formatForExpenseNumbers, operation.sourceSum, [currency shorterName]];
        
        cell.sumValue = stringForSumValue;
        
        return cell;
        
    }
    else if(operation.type == YGOperationTypeAccountActual){
        
        // if Account actual -> source == account and target == account
        
        YGOperationAccountActualCell *cell = [tableView dequeueReusableCellWithIdentifier:kAccountActualCellIdentifier];
        if (cell == nil) {
            cell = (YGOperationAccountActualCell *)[[UITableViewCell alloc]
                                              initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:kAccountActualCellIdentifier];
        }
        
        // account
        YGEntity *account = [self entityByType:YGEntityTypeAccount rowId:operation.sourceId];
        
        cell.accountName = account.name;
        
        // currency
        YGCategory *currency = [self categoryByType:YGCategoryTypeCurrency rowId:account.currencyId];
        
        // sum
        //cell.sumValue = [NSString stringWithFormat:@"%.2f", operation.targetSum];
        
        NSString *stringForSumValue = [NSString stringWithFormat:formatForEqualNumbers, operation.targetSum, [currency shorterName]];
        
        cell.sumValue = stringForSumValue;
        
        return cell;

    }
    else if(operation.type == YGOperationTypeIncome){
        
        // what is income?
        // it is transfer from IncomeSource to Account
        
        YGOperationCell *cell = [tableView dequeueReusableCellWithIdentifier:kOperationCellIdentifier];
        if (cell == nil) {
            cell = (YGOperationCell *)[[UITableViewCell alloc]
                                                    initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:kOperationCellIdentifier];
        }
        
        // get incomeSource
        YGCategory *incomeSource = [self categoryByType:YGCategoryTypeIncome rowId:operation.sourceId];
        
        // account
        YGEntity *account = [self entityByType:YGEntityTypeAccount rowId:operation.targetId];
        
        //cell.accountName = account.name;
        cell.descriptionText = incomeSource.name;
        
        // currency
        YGCategory *currency = [self categoryByType:YGCategoryTypeCurrency rowId:account.currencyId];
        
        NSString *stringForSumText = [NSString stringWithFormat:formatForIncomeNumbers, operation.targetSum, [currency shorterName]];
        
        cell.sumText = stringForSumText;
        
        return cell;
        
    }
    else if(operation.type == YGOperationTypeTransfer){
        
        // what is transfer?
        // it is transfer from sourceAccount to targetAccount
        
        YGOperationInTwoRowsCell *cell = [tableView dequeueReusableCellWithIdentifier:kOperationInTwoRowsCellIdentifier];
        if (cell == nil) {
            cell = (YGOperationInTwoRowsCell *)[[UITableViewCell alloc]
                                       initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kOperationInTwoRowsCellIdentifier];
        }
                
        // source account
        YGEntity *sourceAccount = [self entityByType:YGEntityTypeAccount rowId:operation.sourceId];
        // source currency
        YGCategory *sourceCurrency = [self categoryByType:YGCategoryTypeCurrency rowId:operation.sourceCurrencyId];
        
        // target account
        YGEntity *targetAccount = [self entityByType:YGEntityTypeAccount rowId:operation.targetId];
        // target currency
        YGCategory *targetCurrency = [self categoryByType:YGCategoryTypeCurrency rowId:operation.targetCurrencyId];
        
        cell.firstRowLeftSideText = sourceAccount.name;
        cell.secondRowLeftSideText = targetAccount.name;
        
        cell.firstRowRightSideText = [NSString stringWithFormat:formatForExpenseNumbers, operation.sourceSum, [sourceCurrency shorterName]];
        cell.secondRowRightSideText = [NSString stringWithFormat:formatForIncomeNumbers, operation.targetSum, [targetCurrency shorterName]];
        
        return cell;
        
    }

    return nil;

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
