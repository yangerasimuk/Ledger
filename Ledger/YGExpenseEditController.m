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

- (IBAction)textFieldSumEditingChanged:(UITextField *)sender;
- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;

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
            _currency = [_cm categoryById:_account.currencyId];
            
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
        
        self.buttonDelete.enabled = NO;
        
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
        _category = [_cm categoryById:self.expense.targetId];
        self.labelCategory.text = _category.name;
        
        // set currency
        _currency = [_cm categoryById:self.expense.sourceCurrencyId];
        self.labelCurrency.text = [_currency shorterName];
        
        // set sum
        _sum = self.expense.sourceSum;
        self.textFieldSum.text = [NSString stringWithFormat:@"%.2f", self.expense.sourceSum];
        
        // set comment
        _comment = self.expense.comment;
        self.textFieldComment.text = _comment;
        
        // init
        _initDateValue = [_date copy];
        _initAccountValue = [_account copy];
        _initCategoryValue = [_category copy];
        _initSumValue = _sum;
        _initCommentValue = [_comment copy];
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
    
    
    
    //NSLog(@"%@", self.textFieldSum.keyboardType]
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
    
    _currency = [_cm categoryById:_account.currencyId];
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
    }
    else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
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
    
    NSString *newComment = self.textFieldComment.text;
    
    if([_initCommentValue isEqualToString:newComment])
        _isCommentChanged = NO;
    else
        _isCommentChanged = YES;
    
    [self changeSaveButtonEnable];
}


#pragma mark - Save and delete actions

- (void)saveButtonPressed {
    
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    [_om removeOperation:self.expense];
    
    [_em recalcSumOfAccount:_account forOperation:_expense];
    
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

@end
