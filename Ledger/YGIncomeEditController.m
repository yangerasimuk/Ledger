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

@interface YGIncomeEditController () <UITextFieldDelegate> {
    NSDate *_created;
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
@property (weak, nonatomic) IBOutlet UILabel *labelSum;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrency;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsController;

@property (weak, nonatomic) IBOutlet UITextField *textFieldSum;
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
        _created = [NSDate date];
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_created];
        
        // set income source
        _incomeSource = [_cm categoryAttachedForType:YGCategoryTypeIncome];
        
        /*
        if(!_incomeSource)
            _incomeSource = [_cm categoryOnTopForType:YGCategoryTypeIncome];
         */
        if(!_incomeSource){
            self.labelIncomeSource.text = NSLocalizedString(@"SELECT_INCOME_SOURCE_LABEL", @"Select source");
            self.labelIncomeSource.textColor = [UIColor redColor];
        }
        else
            self.labelIncomeSource.text = _incomeSource.name;
        
        // set account
        _account = [_em entityAttachedForType:YGEntityTypeAccount];
        /*
        if(!_account)
            _account = [_em entityOnTopForType:YGEntityTypeAccount];
         */
        
        if(_account){
            //_currency = [_cm categoryById:_account.currencyId];
            _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];

            self.labelAccount.text = _account.name;
            self.labelCurrency.text = [_currency shorterName];
            
        }
        else{
            self.labelAccount.text = NSLocalizedString(@"SELECT_ACCOUNT_LABEL", @"Select account");
            self.labelAccount.textColor = [UIColor redColor];
        }
        
        // set label sum red
        self.labelSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"SUM", @"Sum")] color:[UIColor redColor]];
        
        // init
        _initDateValue = [_created copy];
        _initIncomeSourceValue = nil;
        _initAccountValue = nil;
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
        
        // set focus on sum only for all modes
        [self.textFieldSum becomeFirstResponder];
        
    }
    else{
        // set date
        _created = self.income.created;
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_created];
        
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
        //self.textFieldSum.text = [NSString stringWithFormat:@"%.2f", self.income.targetSum];
        self.textFieldSum.text = [YGTools stringCurrencyFromDouble:self.income.targetSum];
        
        // set comment
        _comment = self.income.comment;
        self.textFieldComment.text = _comment;
        
        // init
        _initDateValue = [_created copy];
        _initIncomeSourceValue = [_incomeSource copy];
        _initAccountValue = [_account copy];
        _initSumValue = _sum;
        _initCommentValue = [_comment copy];
        
        // save and add new button does not need
        self.cellSaveAndAddNew.hidden = YES;
        self.buttonSaveAndAddNew.enabled = NO;
        self.buttonSaveAndAddNew.hidden = YES;
        
        // delete button
        self.cellDelete.hidden = NO;
        self.buttonDelete.enabled = YES;
        self.buttonDelete.hidden = NO;
        self.buttonDelete.backgroundColor = [YGTools colorForActionDelete];

    }
    
    // button save
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // title
    self.navigationItem.title = @"Income";
    
    // set font size of labels
    for(UILabel *label in self.labelsController){
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor,
                                     };
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        label.attributedText = attributed;
    }
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isIncomeSourceChanged = NO;
    _isAccountChanged = NO;
    _isSumChanged = NO;
    _isCommentChanged = NO;
    
    self.textFieldSum.delegate = self;
    self.textFieldComment.delegate = self;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.textFieldSum])
        return [YGTools isValidSumInSourceString:textField.text replacementString:string range:range];
    else if([textField isEqual:self.textFieldComment])
        return [YGTools isValidNoteInSourceString:textField.text replacementString:string range:range];
    else
        return NO;
}

#pragma mark - Property sum setter

- (void)setSum:(double)sum {
    
    _sum = round(sum * 100.0)/100.0;
}


#pragma mark - Come back from other choice controllers

- (IBAction)unwindFromDateChoiceToIncomeEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGDateChoiceController *vc = unwindSegue.sourceViewController;
    
    _created = vc.targetDate;
    self.labelDate.attributedText = [YGTools attributedStringWithText:[YGTools humanViewWithTodayOfDate:_created] color:[UIColor blackColor]];
    
    // date changed?
    if([YGTools isDayOfDate:_created equalsDayOfDate:_initDateValue])
        _isDateChanged = NO;
    else
        _isDateChanged = YES;
    
    [self changeSaveButtonEnable];
    
}

- (IBAction)unwindFromIncomeSourceChoiceToIncomeEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGIncomeSourceChoiceController *vc = unwindSegue.sourceViewController;
    
    YGCategory *newIncomeSource = vc.targetIncome;
    
    _incomeSource = newIncomeSource;
    self.labelIncomeSource.attributedText = [YGTools attributedStringWithText:_incomeSource.name color:[UIColor blackColor]];
    
    if([_incomeSource isEqual:_initIncomeSourceValue])
        _isIncomeSourceChanged = NO;
    else
        _isIncomeSourceChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (IBAction)unwindFromAccountChoiceToIncomeEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _account = vc.targetAccount;
    self.labelAccount.attributedText = [YGTools attributedStringWithText:_account.name color:[UIColor blackColor]];
    
    // may be lazy?
    _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
    self.labelCurrency.attributedText = [YGTools attributedStringWithText:[_currency shorterName] color:[UIColor blackColor]];
    
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
    if(!_created)
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
    
    //self.sum =  [self.textFieldSum.text doubleValue];
    self.sum = [YGTools doubleFromStringCurrency:self.textFieldSum.text];
    
    if(_initSumValue == self.sum){
        _isSumChanged = NO;
    }
    else{
        _isSumChanged = YES;
    }
    
    if(self.sum == 0.00f)
        self.labelSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"SUM", @"Sum.")] color:[UIColor redColor]];
    else
        self.labelSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"SUM", @"Sum.")] color:[UIColor blackColor]];
    
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
    
    [self saveIncome];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonSaveAndAddNewPressed {
    
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
    _initDateValue = [_created copy];
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
        
        YGOperation *income = [[YGOperation alloc]
                               initWithType:YGOperationTypeIncome
                               sourceId:_incomeSource.rowId
                               targetId:_account.rowId
                               sourceSum:_sum
                               sourceCurrencyId:_account.currencyId
                               targetSum:_sum
                               targetCurrencyId:_account.currencyId
                               created:_created
                               modified:[_created copy]
                               comment:_comment];
        
        NSInteger operationId = [_om addOperation:income];
        
        // crutch
        income.rowId = operationId;
        
        // update sum of account
        [_em recalcSumOfAccount:[_account copy] forOperation:[income copy]];
    }
    else{
        
        if(_isDateChanged)
            self.income.created = _created;
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
        
        self.income.modified = [NSDate date];
        
        [_om updateOperation:[self.income copy]];
        
        // update sum of account
        [_em recalcSumOfAccount:[_account copy] forOperation:[self.income copy]];
        
        // recalc of old account
        if(![_account isEqual:_initAccountValue] && _initAccountValue)
            [_em recalcSumOfAccount:[_initAccountValue copy] forOperation:[self.income copy]];
        
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
        
        vc.sourceDate = _created;
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


@end
