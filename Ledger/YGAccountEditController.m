//
//  YGAccountEditController.m
//  Ledger
//
//  Created by Ян on 15/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGAccountEditController.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGCurrencyChoiceController.h"
#import "YGTools.h"

@interface YGAccountEditController () <UITextFieldDelegate, UITextViewDelegate> {
    
    NSString *p_name;
    NSInteger p_sort;
    NSString *p_comment;
    YGCategory *p_currency;
    BOOL p_isDefault;
    
    BOOL _isNameChanged;
    BOOL _isSortChanged;
    BOOL _isCommentChanged;
    BOOL _isCurrencyChanged;
    BOOL _isDefaultChanged;
    
    NSString *_initNameValue;
    NSInteger _initSortValue;
    NSString *_initCommentValue;
    YGCategory *_initCurrencyValue;
    BOOL _initIsDefaultValue;
    
    YGCategoryManager *_cm;
    YGEntityManager *_em;
    
    BOOL p_canDelete;
}

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelSort;
@property (weak, nonatomic) IBOutlet UILabel *labelIsDefault;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrency;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsOfController;

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSort;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOfController;

@property (weak, nonatomic) IBOutlet UISwitch *switchIsDefault;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSelectCurrency;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellActivate;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;

- (IBAction)textFieldNameEditingChanged:(UITextField *)sender;
- (IBAction)textFieldSortEditingChanged:(UITextField *)sender;
- (IBAction)switchIsDefaultValueChanged:(UISwitch *)sender;
- (IBAction)buttonActivatePressed:(UIButton *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;

@end

@implementation YGAccountEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _em = [YGEntityManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.navigationItem.title = NSLocalizedString(@"ACCOUNT_EDIT_FORM_TITLE", @"Title of Account view/edit form.");
    
    if(!self.account){
        
        self.account = nil;
        p_name = nil;
        self.labelName.textColor = [YGTools colorRed];
        
        //self.currency = nil;
        p_currency = nil;
        
        self.textFieldSort.text = @"100";
        p_sort = 100;
        
        self.switchIsDefault.on = NO;
        p_isDefault = NO;
        
        p_comment = nil;
        // имитируем placeholder у textView
        self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
        self.textViewComment.textColor = [UIColor lightGrayColor];
        self.textViewComment.delegate = self;
        
        // hide button activate
        self.buttonActivate.enabled = NO;
        self.buttonActivate.hidden = YES;
        
        // hide button delete
        self.buttonDelete.enabled = NO;
        self.buttonDelete.hidden = YES;
        
        YGCategory *currency = [_cm categoryAttachedForType:YGCategoryTypeCurrency];
        
        if(currency){
            p_currency = currency;
            
            self.labelCurrency.text = p_currency.name;
        }
        
        if(!currency && [_cm countOfActiveCategoriesForType:YGCategoryTypeCurrency] == 1){

            currency = [_cm categoryOnTopForType:YGCategoryTypeCurrency];
            
            if(currency){
                p_currency = currency;
                self.labelCurrency.text = p_currency.name;
            }
        }
        
        if(!currency){
            self.labelCurrency.text = NSLocalizedString(@"SELECT_CURRENCY_LABEL", @"Select currency text on label.");
            self.labelCurrency.textColor = [YGTools colorRed];
        }
        
        // focus
        [self.textFieldName becomeFirstResponder];
    }
    else{
        
        self.textFieldName.text = self.account.name;
        p_name = self.account.name;
        
        self.textFieldSort.text = [NSString stringWithFormat:@"%ld", (long)self.account.sort];
        p_sort = self.account.sort;
        
        p_comment = self.account.comment;
        // если комментария нет, то имитируем placeholder
        if(p_comment && ![p_comment isEqualToString:@""]){
            self.textViewComment.text = p_comment;
            self.textViewComment.textColor = [UIColor blackColor];
        }
        else{
            self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
            self.textViewComment.textColor = [UIColor lightGrayColor];
        }
        self.textViewComment.delegate = self;
        
        p_currency = [_cm categoryById:self.account.currencyId type:YGCategoryTypeCurrency];
        self.labelCurrency.text = p_currency.name;
        
        self.switchIsDefault.on = self.account.attach;
        p_isDefault = self.account.attach;
        
        self.buttonActivate.enabled = YES;
        if(self.account.active){
            [self.buttonActivate setTitle: NSLocalizedString(@"DEACTIVATE_BUTTON_TITLE", @"Deactivate for button title") forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionDeactivate];
        }
        else{
            [self.buttonActivate setTitle:NSLocalizedString(@"ACTIVATE_BUTTON_TITLE", @"Activate for button title") forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionActivate];
        }
        
    }

    // init state for user changes
    _isNameChanged = NO;
    _isSortChanged = NO;
    _isCommentChanged = NO;
    _isCurrencyChanged = NO;
    _isDefaultChanged = NO;
    
    // init state of UI
    _initNameValue = p_name;
    _initSortValue = p_sort;
    _initCommentValue = p_comment;
    _initCurrencyValue = [p_currency copy];
    _initIsDefaultValue = p_isDefault;
    
    // set delegate to self for validators
    self.textFieldName.delegate = self;
    self.textFieldSort.delegate = self;
    self.textViewComment.delegate = self;
    
    [self updateUI];
    
    [self setDefaultFontForControls];
}

- (void)setDefaultFontForControls {
    
    // set font size of labels
    for(UILabel *label in self.labelsOfController){
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor};
        
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        label.attributedText = attributed;
    }
    
    for(UIButton *button in self.buttonsOfController){
        button.titleLabel.font = [UIFont boldSystemFontOfSize:[YGTools defaultFontSize]];
    }
    
    // set font size of textField and textView
    self.textFieldName.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textFieldSort.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textViewComment.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.account)
        [self updateUI];
}

- (void)updateUI {
    
    if(!self.account){
        ;
    }
    else{
        
        p_canDelete = YES;
        
        if([_em isExistLinkedOperationsForEntity:self.account]
           || [_cm countOfActiveCategoriesForType:YGCategoryTypeCurrency] == 1){
            
            // set unselectable currency choice
            self.cellSelectCurrency.accessoryType = UITableViewCellAccessoryNone;
            self.cellSelectCurrency.userInteractionEnabled = NO;
            self.labelCurrency.textColor = [UIColor grayColor];
            
            self.buttonDelete.enabled = NO;
            self.buttonDelete.hidden = YES;
            
            // set flag for [tableView reloadData]
            p_canDelete = NO;
        }
        else{
            
            // set selectable currency choice
            self.cellSelectCurrency.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.cellSelectCurrency.userInteractionEnabled = YES;
            self.labelCurrency.textColor = [UIColor blackColor];

            self.buttonDelete.enabled = YES;
            self.buttonDelete.hidden = NO;
        }
        
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate & UITextViewDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.textFieldName])
        return [YGTools isValidNameInSourceString:textField.text replacementString:string range:range];
    else if([textField isEqual:self.textFieldSort])
        return [YGTools isValidSortInSourceString:textField.text replacementString:string range:range];
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

#pragma mark - Has account linked operations?

- (BOOL)hasAccountLinkedOperations {
    
    if(_account){

        if([_em isExistLinkedOperationsForEntity:_account])
            return YES;
    }
    return NO;
}


#pragma mark - UITextViewDelegate for placeholder

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if([textView isEqual:self.textViewComment]){
        
        if(textView.text && [textView.text isEqualToString:NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.")]){
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }
    }
    
    [textView becomeFirstResponder];
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if([textView isEqual:self.textViewComment]){
        
        if(!textView.text || [textView.text isEqualToString:@""]){
            textView.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
            textView.textColor = [UIColor lightGrayColor];
        }
    }
    
    [textView resignFirstResponder];
}


#pragma mark - Come back from currency choice

- (IBAction)unwindToAccountEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGCurrencyChoiceController *vc = unwindSegue.sourceViewController;
    
    // set current currency
    p_currency = [vc.targetCurrency copy];
    
    // update UI
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],NSForegroundColorAttributeName:[UIColor blackColor],};
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:p_currency.name attributes:attributes];
    self.labelCurrency.attributedText = attributed;
    
    // equal to init currency value and set flag of changes
    if([p_currency isEqual:_initCurrencyValue])
        _isCurrencyChanged = NO;
    else{
        _isCurrencyChanged = YES;
        [self changeSaveButtonEnable];
    }
}


#pragma mark - Monitoring of control value changed

- (IBAction)textFieldNameEditingChanged:(UITextField *)sender {
    
    p_name = self.textFieldName.text;
    
    if([self.textFieldName.text isEqualToString:@""])
        self.labelName.textColor = [YGTools colorRed];
    else
        self.labelName.textColor = [UIColor blackColor];
    
    if([_initNameValue isEqualToString:p_name])
        _isNameChanged = NO;
    else{
        _isNameChanged = YES;
        [self changeSaveButtonEnable];
    }
}


- (IBAction)textFieldSortEditingChanged:(UITextField *)sender {
    
    p_sort = [self.textFieldSort.text integerValue];
    
    if(_initSortValue == p_sort)
        _isSortChanged = NO;
    else
        _isSortChanged = YES;
    
    if([self.textFieldSort.text isEqualToString:@""])
        self.labelSort.textColor = [YGTools colorRed];
    else
        self.labelSort.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
}


- (void)textViewDidChange:(UITextView *)textView {
    
    if([textView isEqual:self.textViewComment]){
        
        p_comment = textView.text;
        
        if([_initCommentValue isEqualToString:p_comment])
            _isCommentChanged = NO;
        else
            _isCommentChanged = YES;
        
        [self changeSaveButtonEnable];
    }
}


- (IBAction)switchIsDefaultValueChanged:(UISwitch *)sender {
    
    p_isDefault = self.switchIsDefault.isOn;
    
    if(_initIsDefaultValue == p_isDefault)
        _isDefaultChanged = NO;
    else
        _isDefaultChanged = YES;
    
    [self changeSaveButtonEnable];
}


- (BOOL)isEditControlsChanged{
    
    if(_isNameChanged)
        return YES;
    if(_isSortChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
    if(_isCurrencyChanged)
        return YES;
    if(_isDefaultChanged)
        return YES;
    
    return NO;
}


- (BOOL)isDataReadyForSave {
    
    if(!p_name || [p_name isEqualToString:@""])
        return NO;
    if(!p_currency)
        return NO;
    if(p_sort < 1 || p_sort > 999)
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


#pragma mark - Save, deactivate/activate and delete actions

- (void)saveButtonPressed {
    
    p_name = [p_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    p_comment = [p_comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(p_sort < 1 || p_sort > 999)
        p_sort = 100;
    
    if(!self.account){

        YGEntity *account = [[YGEntity alloc]
                             initWithType:YGEntityTypeAccount
                             name:p_name
                             sum:0.0f
                             currencyId:p_currency.rowId
                             attach:p_isDefault
                             sort:p_sort
                             comment:p_comment
                             ];
        
        [_em addEntity:[account copy]];
    }
    else{
        
        if(_isNameChanged)
            self.account.name = p_name;
        if(_isSortChanged)
            self.account.sort = p_sort;
        if(_isCommentChanged)
            self.account.comment = p_comment;
        if(_isCurrencyChanged)
            self.account.currencyId = p_currency.rowId;
        if(_isDefaultChanged)
            self.account.attach = p_isDefault;
        
        self.account.modified = [NSDate date];
        
        // change db, not instance
        [_em updateEntity:[self.account copy]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonActivatePressed:(UIButton *)sender {
    
    if(self.account.active)
        [_em deactivateEntity:self.account];
    else
        [_em activateEntity:self.account];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    if([_em isExistLinkedOperationsForEntity:_account]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"REASON_CAN_NOT_DELETE_ACCOUNT_WITH_LINKED_MESSAGE", @"Message with reason that current account has linked objects and can not be deleted.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else{
        [_em removeEntity:self.account];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Tools

- (NSInteger)sortValueFromString:(NSString *)string{
    
    NSInteger result = 100;
    
    @try {
        if(string && [string length] > 0){
            result = [string integerValue];
        }
    } @catch (NSException *ex) {
        NSLog(@"Error in -[YGAccountEditController sortValueFromString]. Exception: %@", [ex description]);
    } @finally {
        return result;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    YGCurrencyChoiceController *vc = segue.destinationViewController;
    
    vc.sourceCurrency = p_currency;
}

#pragma mark - Data source methods to show/hide action cells

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if(!self.account && indexPath.section == 4)
        return 0.0f;
    
    if(self.account && indexPath.section == 4 && indexPath.row == 1 && !p_canDelete)
        return 0.0f;
    
    if(self.account && indexPath.section == 4 && indexPath.row == 0){
        YGCategory *currency = [_cm categoryById:self.account.currencyId type:YGCategoryTypeCurrency];
        if(!currency.active)
            return 0.0f;
    }
    return height;
}

@end
