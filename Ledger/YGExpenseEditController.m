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

@interface YGExpenseEditController () <UITextFieldDelegate, UITextViewDelegate> {
    
    NSDate *_created;
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
@property (weak, nonatomic) IBOutlet UILabel *labelSum;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrency;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsController;

@property (weak, nonatomic) IBOutlet UITextField *textFieldSum;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSaveAndAddNew;

@property (weak, nonatomic) IBOutlet UIButton *buttonSaveAndAddNew;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;

- (IBAction)textFieldSumEditingChanged:(UITextField *)sender;
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
        _created = [NSDate date];
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_created];
        
        // set account if one sets as default
        _account = [_em entityAttachedForType:YGEntityTypeAccount];
        /*
        if(!_account)
            _account = [_em entityOnTopForType:YGEntityTypeAccount];
         */
        if(_account){
            _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
            
            self.labelAccount.text = _account.name;
            self.labelCurrency.text = [_currency shorterName];
        }
        else{
            self.labelAccount.text = NSLocalizedString(@"SELECT_ACCOUNT_LABEL", @"Select account.");
            self.labelAccount.textColor = [UIColor redColor];
        }
        
        // attention user to select category
        self.labelCategory.text = NSLocalizedString(@"SELECT_CATEGORY_LABEL", @"Select category");
        self.labelCategory.textColor = [UIColor redColor];
        
        // set label sum red
        self.labelSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"SUM", @"Sum.")] color:[UIColor redColor]];
        
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
        
        // set focus on sum only for all modes
        [self.textFieldSum becomeFirstResponder];

    }
    else{
        // set date
        _created = self.expense.created;
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_created];
        
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
        //self.textFieldSum.text = [NSString stringWithFormat:@"%.2f", self.expense.sourceSum];
        self.textFieldSum.text = [YGTools stringCurrencyFromDouble:self.expense.sourceSum];
        
        // set comment
//        _comment = self.expense.comment;
//        if(self.expense.comment)
//            self.textFieldComment.text = _comment;
        
        _comment = self.expense.comment;
        if(_comment)
            self.textViewComment.text = _comment;
        
        
        // init
        _initDateValue = [_created copy];
        _initAccountValue = [_account copy];
        _initCategoryValue = [_category copy];
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
    self.navigationItem.title = NSLocalizedString(@"EXPENSE_EDIT_FORM_TITLE",  @"Title of expense edit form.");
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isCategoryChanged = NO;
    _isAccountChanged = NO;
    _isSumChanged = NO;
    _isCommentChanged = NO;
    
    self.textFieldSum.delegate = self;
    //self.textFieldComment.delegate = self;
    self.textViewComment.delegate = self;
    
    [self setDefaultFontForControls];
    
}

- (void)setDefaultFontForControls {
    
    // set font size of labels
    for(UILabel *label in self.labelsController){
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor,
                                     };
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        label.attributedText = attributed;
    }
    
    // set font size of textField and textView
    self.textFieldSum.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textViewComment.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.textFieldSum])
        return [YGTools isValidSumInSourceString:textField.text replacementString:string range:range];
    else
        return NO;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([textView isEqual:self.textViewComment]){
        return [YGTools isValidCommentInSourceString:textView.text replacementString:text range:range];
    }
    else
        return NO;
}


#pragma mark - Property sum setter

- (void)setSum:(double)sum {

    _sum = round(sum * 100.0)/100.0;
}


#pragma mark - Come back from other choice controllers

- (IBAction)unwindFromDateChoiceToExpenseEdit:(UIStoryboardSegue *)unwindSegue {
    
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

- (IBAction)unwindFromAccountChoiceToExpenseEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _account = vc.targetAccount;
    self.labelAccount.attributedText = [YGTools attributedStringWithText:_account.name color:[UIColor blackColor]];
    
    _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
    self.labelCurrency.attributedText = [YGTools attributedStringWithText:[_currency shorterName] color:[UIColor blackColor]];
    
    if([_account isEqual:_initAccountValue])
        _isAccountChanged = NO;
    else
        _isAccountChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (IBAction)unwindFromExpenseCategoryChoiceToExpenseEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGExpenseCategoryChoiceController *vc = unwindSegue.sourceViewController;
    
    _category = vc.targetCategory;
    self.labelCategory.attributedText = [YGTools attributedStringWithText:_category.name color:[UIColor blackColor]];
    
    if([_category isEqual:_initCategoryValue])
        _isCategoryChanged = NO;
    else
        _isCategoryChanged = YES;
    
    [self changeSaveButtonEnable];
    
}

- (BOOL)isEditControlsChanged {
    
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

- (BOOL)isDataReadyForSave {
    
    if(!_created)
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
    
    self.sum = [YGTools doubleFromStringCurrency:self.textFieldSum.text];
    
    if(_initSumValue == _sum){
        _isSumChanged = NO;
    }
    else{
        _isSumChanged = YES;
    }
    
    if(self.sum == 0.00f)
        self.labelSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"SUM", "Sum.")] color:[UIColor redColor]];
    else
        self.labelSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"SUM", "Sum.")] color:[UIColor blackColor]];
    
    [self changeSaveButtonEnable];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if([textView isEqual:self.textViewComment]){
        
        _comment = textView.text;
        
        if([_initCommentValue isEqualToString:_comment])
            _isCommentChanged = NO;
        else
            _isCommentChanged = YES;
        
        [self changeSaveButtonEnable];
    }
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
    _initDateValue = [_created copy];
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
        
        YGOperation *expense = [[YGOperation alloc]
                                initWithType:YGOperationTypeExpense
                                sourceId:_account.rowId
                                targetId:_category.rowId
                                sourceSum:_sum
                                sourceCurrencyId:_account.currencyId
                                targetSum:_sum
                                targetCurrencyId:_account.currencyId
                                created:_created
                                modified:[_created copy]
                                comment:_comment];
        
        NSInteger operationId = [_om addOperation:expense];
        
        // crutch
        expense.rowId = operationId;
        
        [_em recalcSumOfAccount:_account forOperation:expense];
        
    }
    else{
        
        if(_isDateChanged)
            self.expense.created = _created;
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
        
        self.expense.modified = [NSDate date];
        
        [_om updateOperation:[self.expense copy]];
        
        [_em recalcSumOfAccount:[_account copy] forOperation:[self.expense copy]];
        
        // recalc of old account
        if(![_account isEqual:_initAccountValue] && _initAccountValue)
            [_em recalcSumOfAccount:[_initAccountValue copy] forOperation:[self.expense copy]];
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
        
        vc.sourceDate = _created;
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

@end
