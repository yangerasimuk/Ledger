//
//  YGExpenseEditController.m
//  Ledger
//
//  Created by Ян on 17/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGExpenseEditController.h"
#import "YGDateChoiceController.h"
#import "YGAccountChoiceController.h"
#import "YGExpenseCategoryChoiceController.h"
#import "YGTools.h"
#import "YGCategory.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGOperationManager.h"

@interface YGExpenseEditController (){
    NSDate *_date;
    YGEntity *_account;
    YGCategory *_currency;
    YGCategory *_category;
    NSString *_comment;
    
    BOOL _isDateChanged;
    BOOL _isAccountChanged;
    BOOL _isCategoryChanged;
    BOOL _isSumChanged;
    BOOL _isCommentChanged;
    
    NSDate *_initDateValue;
    YGEntity *_initAccountValue;
    YGCategory *_initCategoryValue;
    double _initSumValue;
    NSString *_initCommentValue;
    
    YGEntityManager *_em;
    YGCategoryManager *_cm;
    YGOperationManager *_om;
}

@property (assign, nonatomic) double sum;

@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelCategory;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSum;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrency;
@property (weak, nonatomic) IBOutlet UITextField *textFieldComment;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSaveAndAddNew;

@property (weak, nonatomic) IBOutlet UIButton *buttonSaveAndAddNew;

- (IBAction)textFieldSumEditingChanged:(UITextField *)sender;
- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender;

@end

@implementation YGExpenseEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _em = [YGEntityManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
    _om = [YGOperationManager sharedInstance];
    
    if(self.isNewExpense){
        
        // set date
        _date = [NSDate date];
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_date];
        
        // set account if one sets as default
        _account = [_em entityAttachedForType:YGEntityTypeAccount];
        if(!_account)
            _account = [_em entityOnTopForType:YGEntityTypeAccount];
        if(_account){
            _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
            
            self.labelAccount.text = _account.name;
            self.labelCurrency.text = [_currency shorterName];
        }
        else{
            self.labelAccount.text = @"Select account";
        }
        
        // init
        _initDateValue = [NSDate date];
        _initAccountValue = nil;
        _initCategoryValue = nil;
        _initSumValue = 0.0f;
        _initCommentValue = nil;
        
        // hide button delete
        self.buttonDelete.enabled = NO;
        self.cellDelete.hidden = YES;
        
        // show button save and add new
        self.cellSaveAndAddNew.hidden = NO;
        self.buttonSaveAndAddNew.enabled = NO;
        self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
        self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];

        // set focus on sum only for new element
        [self.textFieldSum becomeFirstResponder];

    }
    else{
        // set date
        _date = self.expense.date;
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_date];
        
        // set account
        _account = [_em entityById:self.expense.sourceId type:YGEntityTypeAccount];
        self.labelAccount.text = _account.name;
        
        
        // set expenseCategory
        //_category = [_cm categoryById:self.expense.targetId];
        _category = [_cm categoryById:self.expense.targetId type:YGCategoryTypeExpense];
        self.labelCategory.text = _category.name;
        
        // set currency
        //_currency = [_cm categoryById:self.expense.sourceCurrencyId];
        _currency = [_cm categoryById:self.expense.sourceCurrencyId type:YGCategoryTypeCurrency];
        self.labelCurrency.text = [_currency shorterName];
        
        // set sum
        _sum = self.expense.sourceSum;
        self.textFieldSum.text = [NSString stringWithFormat:@"%.2f", self.expense.sourceSum];
        
        // set comment
        _comment = self.expense.comment;
        if(self.expense.comment)
            self.textFieldComment.text = _comment;
        
        // init
        _initDateValue = [_date copy];
        _initAccountValue = [_account copy];
        _initCategoryValue = [_category copy];
        _initSumValue = _sum;
        _initCommentValue = [_comment copy];

        // save and add new button does not need
        self.cellSaveAndAddNew.hidden = YES;
        self.buttonSaveAndAddNew.enabled = NO;
        self.buttonSaveAndAddNew.hidden = YES;

    }
    
    // button save
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // title
    self.navigationItem.title = @"Expense";
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isCategoryChanged = NO;
    _isAccountChanged = NO;
    _isSumChanged = NO;
    _isCommentChanged = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Property sum setter

- (void)setSum:(double)sum {
    
    _sum = round(sum * 100.0)/100.0;
    
}

#pragma mark - Come back from other choice controllers

- (IBAction)unwindFromDateChoiceToExpenseEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGDateChoiceController *vc = unwindSegue.sourceViewController;
    
    _date = vc.targetDate;
    
    self.labelDate.text = [YGTools humanViewWithTodayOfDate:_date];
    
    // date changed?
    if([YGTools isDayOfDate:_date equalsDayOfDate:_initDateValue])
        _isDateChanged = NO;
    else
        _isDateChanged = YES;
    
    [self changeSaveButtonEnable];
    
}

- (IBAction)unwindFromAccountChoiceToExpenseEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    YGEntity *newAccount = vc.targetAccount;
    
    _account = newAccount;
    self.labelAccount.text = _account.name;
    
    _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
    self.labelCurrency.text = [_currency shorterName];
    
    if([_account isEqual:_initAccountValue])
        _isAccountChanged = NO;
    else
        _isAccountChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (IBAction)unwindFromExpenseCategoryChoiceToExpenseEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGExpenseCategoryChoiceController *vc = unwindSegue.sourceViewController;
    
    _category = vc.targetCategory;
    self.labelCategory.text = _category.name;
    
    if([_category isEqual:_initCategoryValue])
        _isCategoryChanged = NO;
    else
        _isCategoryChanged = YES;
    
    [self changeSaveButtonEnable];
    
}

- (BOOL) isEditControlsChanged {
    
    if(_isDateChanged)
        return YES;
    if(_isAccountChanged)
        return YES;
    if(_isCategoryChanged)
        return YES;
    if(_isSumChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
    
    return NO;
}

- (BOOL) isDataReadyForSave {
    if(!_date)
        return NO;
    if(!_account)
        return NO;
    if(!_category)
        return NO;
    if(_sum <= 0)
        return NO;
    
    return YES;
}

#pragma mark - Change save button enable

- (void) changeSaveButtonEnable{
    
    if([self isEditControlsChanged] && [self isDataReadyForSave]){
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if(self.isNewExpense){
            self.buttonSaveAndAddNew.enabled = YES;
            self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionSaveAndAddNew];
        }
        
    }
    else{
        
        self.navigationItem.rightBarButtonItem.enabled = NO;

        if(self.isNewExpense){
            self.buttonSaveAndAddNew.enabled = NO;
            self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
        }
    }
}


#pragma mark - Monitoring of controls changed

- (IBAction)textFieldSumEditingChanged:(UITextField *)sender {
    
    self.sum = [self.textFieldSum.text doubleValue];
    
    if(_initSumValue == _sum){
        _isSumChanged = NO;
    }
    else{
        _isSumChanged = YES;
    }
    
    [self changeSaveButtonEnable];
}

- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender {
    
    _comment = self.textFieldComment.text;
    
    if([_initCommentValue isEqualToString:_comment])
        _isCommentChanged = NO;
    else
        _isCommentChanged = YES;
    
    [self changeSaveButtonEnable];
}


#pragma mark - Save and delete actions

- (void)saveButtonPressed {
    
    [self saveExpense];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender {
    
    [self saveExpense];
    
    [self initUIForNewExpense];
}


- (void)initUIForNewExpense {
    
    // leave date
    //_date;
    
    // leave account
    //_account;
    
    // leave currency
    // _currency;
    
    
    // init
    _initDateValue = [_date copy];
    _initAccountValue = [_account copy];
    _initCategoryValue = [_category copy];
    _initSumValue = 0.0f;
    _initCommentValue = @"";
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isCategoryChanged = NO;
    _isAccountChanged = NO;
    _isSumChanged = NO;
    _isCommentChanged = NO;
    
    // deactivate "Add" and "Save & add new" bottons
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.buttonSaveAndAddNew.enabled = NO;
    self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
    
    // set focus on sum only for new element
    self.textFieldSum.text = @"";
    [self.textFieldSum becomeFirstResponder];

}


- (void)saveExpense {
    if(self.isNewExpense){
        
        YGOperation *expense = [[YGOperation alloc] initWithType:YGOperationTypeExpense
                                                        sourceId:_account.rowId
                                                        targetId:_category.rowId
                                                       sourceSum:_sum
                                                sourceCurrencyId:_account.currencyId
                                                       targetSum:_sum
                                                targetCurrencyId:_account.currencyId
                                                            date:_date
                                                         comment:_comment];
        
        //NSLog(@"New expense. %@", [expense description]);
        
        NSInteger operationId = [_om addOperation:expense];
        
        // crutch
        expense.rowId = operationId;
        
        [_em recalcSumOfAccount:_account forOperation:expense];
        
    }
    else{
        
        if(_isDateChanged)
            self.expense.date = _date;
        if(_isAccountChanged){
            self.expense.sourceId = _account.rowId;
            self.expense.sourceCurrencyId = _currency.rowId;
        }
        if(_isCategoryChanged){
            self.expense.targetId = _category.rowId;
            self.expense.targetCurrencyId = _currency.rowId;
        }
        if(_isSumChanged){
            self.expense.sourceSum = _sum;
            self.expense.targetSum = _sum;
        }
        if(_isCommentChanged){
            self.expense.comment = [_comment copy];
        }
        
        [_om updateOperation:[self.expense copy]];
        
        [_em recalcSumOfAccount:_account forOperation:[self.expense copy]];
        
        // recalc of old account
        if(![_account isEqual:_initAccountValue] && _initAccountValue)
            [_em recalcSumOfAccount:_initAccountValue forOperation:[self.expense copy]];
    }
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    [_om removeOperation:self.expense];
    
    [_em recalcSumOfAccount:_account forOperation:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"segueFromExpenseEditToDateChoice"]){
        
        YGDateChoiceController *vc = segue.destinationViewController;
        
        vc.sourceDate = _date;
        vc.customer = YGDateChoiceСustomerExpense;
        
    }
    else if([segue.identifier isEqualToString:@"segueFromExpenseEditToAccountChoice"]){
        
        YGAccountChoiceController *vc = segue.destinationViewController;
        
        vc.sourceAccount = _account;
        vc.customer = YGAccountChoiceCustomerExpense;
        
    }
    else if([segue.identifier isEqualToString:@"segueFromExpenseEditToExpenseCategoryChoice"]){
        
        YGExpenseCategoryChoiceController *vc = segue.destinationViewController;
        
        vc.sourceCategory = _category;
        
    }
}


#pragma mark - Data source methods to show/hide action cells

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    /*
    if(indexPath.section == 3 && indexPath.row == 0 && !self.isNewExpense){
        cell = self.cellDelete;
    }
    else if (indexPath.section == 3 && indexPath.row == 0 && self.isNewExpense) {
        cell = self.cellSaveAndAddNew;
    }
     */
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 3 && indexPath.row == 1 && !self.isNewExpense) {
        height = 0;
    }
    else if (indexPath.section == 3 && indexPath.row == 0 && self.isNewExpense) {
        height = 0;
    }
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    
    if (section == 3) {
        count = 2;
    }
    
    return count;
}

@end
