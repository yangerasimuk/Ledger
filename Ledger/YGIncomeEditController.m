//
//  YGIncomeEditController.m
//  Ledger
//
//  Created by Ян on 22/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGIncomeEditController.h"
#import "YGDateChoiceController.h"
#import "YGAccountChoiceController.h"
#import "YGIncomeSourceChoiceController.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGOperationManager.h"
#import "YGTools.h"

@interface YGIncomeEditController (){
    NSDate *_date;
    YGCategory *_incomeSource;
    YGEntity *_account;
    YGCategory *_currency;
    NSString *_comment;
    
    BOOL _isDateChanged;
    BOOL _isIncomeSourceChanged;
    BOOL _isAccountChanged;
    BOOL _isSumChanged;
    BOOL _isCommentChanged;
    
    NSDate *_initDateValue;
    YGCategory *_initIncomeSourceValue;
    YGEntity *_initAccountValue;
    double _initSumValue;
    NSString *_initCommentValue;
    
    YGCategoryManager *_cm;
    YGEntityManager *_em;
    YGOperationManager *_om;
}

@property (assign, nonatomic) double sum;

@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelIncomeSource;
@property (weak, nonatomic) IBOutlet UILabel *labelAccount;

@property (weak, nonatomic) IBOutlet UITextField *textFieldSum;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrency;
@property (weak, nonatomic) IBOutlet UITextField *textFieldComment;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveAndAddNew;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSaveAndAddNew;


- (IBAction)textFieldSumEditingChanged:(UITextField *)sender;
- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender;
@end

@implementation YGIncomeEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cm = [YGCategoryManager sharedInstance];
    _em = [YGEntityManager sharedInstance];
    _om = [YGOperationManager sharedInstance];
    
    if(self.isNewIncome){
        
        // set date
        _date = [NSDate date];
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_date];
        
        // set income source
        _incomeSource = [_cm categoryAttachedForType:YGCategoryTypeIncome];
        
        if(!_incomeSource)
            _incomeSource = [_cm categoryOnTopForType:YGCategoryTypeIncome];
        if(!_incomeSource)
            self.labelIncomeSource.text = @"No income source";
        else
            self.labelIncomeSource.text = _incomeSource.name;
        
        // set account
        _account = [_em entityAttachedForType:YGEntityTypeAccount];
        if(!_account)
            _account = [_em entityOnTopForType:YGEntityTypeAccount];
        if(_account){
            //_currency = [_cm categoryById:_account.currencyId];
            _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];

            self.labelAccount.text = _account.name;
            self.labelCurrency.text = [_currency shorterName];
            
        }
        else{
            self.labelAccount.text = @"Select account";
            
        }
        
        // init
        _initDateValue = [_date copy];
        _initIncomeSourceValue = nil;
        _initAccountValue = nil;
        _initSumValue = 0.0;
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
        _date = self.income.date;
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_date];
        
        // set income source
        //_incomeSource = [_cm categoryById:self.income.sourceId];
        _incomeSource = [_cm categoryById:self.income.sourceId type:YGCategoryTypeIncome];
        self.labelIncomeSource.text = _incomeSource.name;
        
        // set account
        _account = [_em entityById:self.income.targetId type:YGEntityTypeAccount];
        self.labelAccount.text = _account.name;
        
        // set currency
        //_currency = [_cm categoryById:self.income.targetCurrencyId];
        _currency = [_cm categoryById:self.income.targetCurrencyId type:YGCategoryTypeCurrency];
        self.labelCurrency.text = [_currency shorterName];
        
        // set sum
        _sum = self.income.targetSum;
        self.textFieldSum.text = [NSString stringWithFormat:@"%.2f", self.income.targetSum];
        
        // set comment
        _comment = self.income.comment;
        self.textFieldComment.text = _comment;
        
        // init
        _initDateValue = [_date copy];
        _initIncomeSourceValue = [_incomeSource copy];
        _initAccountValue = [_account copy];
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
    self.navigationItem.title = @"Income";
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isIncomeSourceChanged = NO;
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

- (IBAction)unwindFromDateChoiceToIncomeEdit:(UIStoryboardSegue *)unwindSegue {
    
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

- (IBAction)unwindFromIncomeSourceChoiceToIncomeEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGIncomeSourceChoiceController *vc = unwindSegue.sourceViewController;
    
    YGCategory *newIncomeSource = vc.targetIncome;
    
    _incomeSource = newIncomeSource;
    self.labelIncomeSource.text = _incomeSource.name;
    
    if([_incomeSource isEqual:_initIncomeSourceValue])
        _isIncomeSourceChanged = NO;
    else
        _isIncomeSourceChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (IBAction)unwindFromAccountChoiceToIncomeEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _account = vc.targetAccount;
    self.labelAccount.text = _account.name;
    
    // may be lazy?
    //_currency = [_cm categoryById:_account.currencyId];
    _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
    self.labelCurrency.text = [_currency shorterName];
    
    if([_account isEqual:_initAccountValue])
        _isAccountChanged = NO;
    else
        _isAccountChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (BOOL) isEditControlsChanged {
    
    if(_isDateChanged)
        return YES;
    if(_isIncomeSourceChanged)
        return YES;
    if(_isAccountChanged)
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
    if(!_incomeSource)
        return NO;
    if(!_account)
        return NO;
    if(_sum <= 0)
        return NO;
    
    return YES;
}


#pragma mark - Change save button enable

- (void) changeSaveButtonEnable{
    
    if([self isEditControlsChanged] && [self isDataReadyForSave]){
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if(self.isNewIncome){
            self.buttonSaveAndAddNew.enabled = YES;
            self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionSaveAndAddNew];
        }
    }
    else{
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        if(self.isNewIncome){
            self.buttonSaveAndAddNew.enabled = NO;
            self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
        }
    }
}

#pragma mark - Monitoring of controls changed

- (IBAction)textFieldSumEditingChanged:(UITextField *)sender {
    
    self.sum =  [self.textFieldSum.text doubleValue];
    
    if(_initSumValue == self.sum){
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
    
    [self saveIncome];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender:(UIButton *)sender {
    
    [self saveIncome];
    
    [self initUIForNewIncome];
}

- (void)initUIForNewIncome {
    
    // leave date
    //_date;
    
    // leave account
    //_account;
    
    // leave currency
    // _currency;
    
    
    // init
    _initDateValue = [_date copy];
    _initAccountValue = [_account copy];
    _initIncomeSourceValue = [_incomeSource copy];
    _initSumValue = 0.0f;
    _initCommentValue = @"";
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isIncomeSourceChanged = NO;
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

- (void)saveIncome {
    
    if(self.isNewIncome){
        
        YGOperation *income = [[YGOperation alloc] initWithType:YGOperationTypeIncome
                                                       sourceId:_incomeSource.rowId
                                                       targetId:_account.rowId
                                                      sourceSum:_sum
                                               sourceCurrencyId:_account.currencyId
                                                      targetSum:_sum
                                               targetCurrencyId:_account.currencyId
                                                           date:_date
                                                        comment:_comment];
        
        NSInteger operationId = [_om addOperation:income];
        
        // crutch
        income.rowId = operationId;
        
        // update sum of account
        [_em recalcSumOfAccount:[_account copy] forOperation:[income copy]];
    }
    else{
        
        if(_isDateChanged)
            self.income.date = _date;
        if(_isIncomeSourceChanged){
            self.income.sourceId = _incomeSource.rowId;
            self.income.sourceCurrencyId = _currency.rowId;
        }
        if(_isAccountChanged){
            self.income.targetId = _account.rowId;
            self.income.targetCurrencyId = _currency.rowId;
        }
        if(_isSumChanged){
            self.income.sourceSum = _sum;
            self.income.targetSum = _sum;
        }
        if(_isCommentChanged)
            self.income.comment = [_comment copy];
        
        [_om updateOperation:[self.income copy]];
        
        // update sum of account
        [_em recalcSumOfAccount:[_account copy] forOperation:[self.income copy]];
        
    }
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    [_om removeOperation:self.income];
    
    [_em recalcSumOfAccount:_account forOperation:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"segueFromIncomeEditToDateChoice"]){
        
        YGDateChoiceController *vc = segue.destinationViewController;
        
        vc.sourceDate = _date;
        vc.customer = YGDateChoiceСustomerIncome;
        
    }
    else if([segue.identifier isEqualToString:@"segueFromIncomeEditToIncomeSourceChoice"]){
        
        YGIncomeSourceChoiceController *vc = segue.destinationViewController;
        
        vc.sourceIncome = _incomeSource;
        vc.customer = YGIncomeSourceChoiceСustomerIncome;
        
    }
    else if([segue.identifier isEqualToString:@"segueFromIncomeEditToAccountChoice"]){
        
        YGAccountChoiceController *vc = segue.destinationViewController;
        
        vc.sourceAccount = _account;
        vc.customer = YGAccountChoiceCustomerIncome;
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
    
    if (indexPath.section == 3 && indexPath.row == 1 && !self.isNewIncome) {
        height = 0;
    }
    else if (indexPath.section == 3 && indexPath.row == 0 && self.isNewIncome) {
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
