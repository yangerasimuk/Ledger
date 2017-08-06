//
//  YGAccountActualEditController.m
//  Ledger
//
//  Created by Ян on 19/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGAccountActualEditController.h"
#import "YGDateChoiceController.h"
#import "YGAccountChoiceController.h"
#import "YGTools.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGOperationManager.h"

@interface YGAccountActualEditController () <UITextFieldDelegate, UITextViewDelegate> {
    
    NSDate *_created;
    YGEntity *_account;
    YGCategory *_currency;
    double _sourceSum;
    double _targetSum;
    
    YGOperationManager *_om;
    YGCategoryManager *_cm;
    YGEntityManager *_em;
}
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelActualTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetCurrency;
@property (weak, nonatomic) IBOutlet UILabel *labelCommentTitle;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsController;


@property (weak, nonatomic) IBOutlet UITextField *textFieldTargetSum;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveAndAddNew;

- (IBAction)textFieldTargetSumEditingChanged:(UITextField *)sender;

- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellDate;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAccount;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellActualSum;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellComment;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSaveAndAddNew;

@end

@implementation YGAccountActualEditController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _om = [YGOperationManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
    _em = [YGEntityManager sharedInstance];
    
    if(self.isNewAccountAcutal){
        
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
            
            YGCategory *currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
            _currency = currency;
            
            self.labelAccount.text = _account.name;
            self.labelTargetCurrency.text = [_currency shorterName];
        }
        else{
            self.labelAccount.text = NSLocalizedString(@"SELECT_ACCOUNT_LABEL", @"Select account.");
            self.labelAccount.textColor = [UIColor redColor];
        }
        
        // set label sum red
        self.labelActualTitle.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"SUM", @"Sum")] color:[UIColor redColor]];

        // button save
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
        
        self.navigationItem.rightBarButtonItem = saveButton;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        // button delete disable
        self.buttonDelete.enabled = NO;
        self.buttonDelete.hidden = YES;
        
        // show button save and add new
        self.cellSaveAndAddNew.hidden = NO;
        self.buttonSaveAndAddNew.enabled = NO;
        self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
        self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
        
        // focus on sum only for new element
        [self.textFieldTargetSum becomeFirstResponder];
        
    }
    else{
        
        // set date
        _created = self.accountActual.created;
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_created];
        
        // set account
        _account = [_em entityById:self.accountActual.sourceId type:YGEntityTypeAccount];
        self.labelAccount.text = _account.name;
        self.labelAccount.textColor = [UIColor grayColor];
        self.cellAccount.accessoryType = UITableViewCellAccessoryNone;
        self.cellAccount.userInteractionEnabled = NO;
        
        YGCategory *currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
        _currency = currency;
        self.labelAccount.text = _account.name;
        self.labelTargetCurrency.text = [_currency shorterName];
        self.labelTargetCurrency.textColor = [UIColor grayColor];
        
        // set sum
        //self.textFieldTargetSum.text = [NSString stringWithFormat:@"%.2f", self.accountActual.targetSum];
        self.textFieldTargetSum.text = [YGTools stringCurrencyFromDouble:self.accountActual.targetSum];
        
        self.textFieldTargetSum.enabled = NO;
        self.textFieldTargetSum.textColor = [UIColor grayColor];
        self.labelActualTitle.textColor = [UIColor grayColor];
        self.cellActualSum.userInteractionEnabled = NO;
        
        // set comment
        self.textViewComment.text = self.accountActual.comment;
        self.textViewComment.textColor = [UIColor grayColor];
        self.labelCommentTitle.textColor = [UIColor grayColor];
        self.cellComment.userInteractionEnabled = NO;
        
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
    
    // title
    self.navigationItem.title = NSLocalizedString(@"BALANCE_EDIT_FORM_TITLE", @"Balance.");
    
    // set font size of labels
    for(UILabel *label in self.labelsController){
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor,
                                     };
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        label.attributedText = attributed;
    }
    
    // disable date select
    self.labelDate.textColor = [UIColor grayColor];
    self.cellDate.accessoryType = UITableViewCellAccessoryNone;
    self.cellDate.textLabel.textColor = [UIColor grayColor]; // light?
    self.cellDate.userInteractionEnabled = NO;
    
    //
    self.textFieldTargetSum.delegate = self;
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
    self.textFieldTargetSum.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textViewComment.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate & UITextViewDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.textFieldTargetSum])
        return [YGTools isValidSumWithZeroInSourceString:textField.text replacementString:string range:range];
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


#pragma mark - Come back from account choice controller

- (IBAction)unwindFromAccountChoiceToAccountActualEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _account = vc.targetAccount;
    //self.labelAccount.text = _account.name;
    self.labelAccount.attributedText = [YGTools attributedStringWithText:_account.name color:[UIColor blackColor]];
    
    _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];

    //self.labelTargetCurrency.text = [_currency shorterName];
    self.labelTargetCurrency.attributedText = [YGTools attributedStringWithText:[_currency shorterName] color:[UIColor blackColor]];
    
}


#pragma mark - Monitoring of controls changed

- (IBAction)textFieldTargetSumEditingChanged:(UITextField *)sender {
    
    if(![self.textFieldTargetSum.text isEqualToString:@""]){
        
        double sum = [YGTools doubleFromStringCurrency:self.textFieldTargetSum.text];
        
        if(self.isNewAccountAcutal && sum >= 0.00f){
            
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            self.buttonSaveAndAddNew.enabled = YES;
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionSaveAndAddNew];
        }
        
        self.labelActualTitle.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"SUM", @"Sum")] color:[UIColor blackColor]];
    }
    else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        self.buttonSaveAndAddNew.enabled = NO;
        self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
        
        self.labelActualTitle.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@:", NSLocalizedString(@"SUM", @"Sum")] color:[UIColor redColor]];
    }
}

- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender {

}

#pragma mark - Save and delete actions

- (void)saveButtonPressed {
    
    [self saveAccountActual];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender {
    
    [self saveAccountActual];
    
    [self initUIForNewAccountActual];
    
}

- (void)initUIForNewAccountActual {
    
    // leave date
    //_date;
    
    // leave account
    //_account;
    
    // leave currency
    // _currency;
    
    // deactivate "Add" and "Save & add new" bottons
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.buttonSaveAndAddNew.enabled = NO;
    self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
    
    // set focus on sum only for new element
    self.textFieldTargetSum.text = @"";
    [self.textFieldTargetSum becomeFirstResponder];
}


/**
 @warning Do i need any recalc?
 */
- (void)saveAccountActual {
    
    double sourceSum = _account.sum;
    double targetSum = [YGTools doubleFromStringCurrency:self.textFieldTargetSum.text];
    
    YGOperation *accountActual = [[YGOperation alloc]
                                  initWithType:YGOperationTypeAccountActual
                                  sourceId:_account.rowId
                                  targetId:_account.rowId
                                  sourceSum:sourceSum
                                  sourceCurrencyId:_account.currencyId
                                  targetSum:targetSum
                                  targetCurrencyId:_account.currencyId
                                  created:_created
                                  modified:_created
                                  comment:self.textViewComment.text];
    
    [_om addOperation:accountActual];
}


- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    [_om removeOperation:self.accountActual];
    
    [_em recalcSumOfAccount:_account forOperation:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([segue.identifier isEqualToString:@"segueFromAccountActualEditToAccountChoice"]){
        
        YGAccountChoiceController *vc = segue.destinationViewController;
        
        vc.sourceAccount = _account;
        vc.customer = YGAccountChoiceCustomerAccountActual;
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
    
    if (indexPath.section == 3 && indexPath.row == 1 && !self.isNewAccountAcutal) {
        height = 0;
    }
    else if (indexPath.section == 3 && indexPath.row == 0 && self.isNewAccountAcutal) {
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
