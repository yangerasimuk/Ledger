//
//  YGCategoryDefaultEditController.m
//  Ledger
//
//  Created by Ян on 14/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCategoryDefaultEditController.h"
#import "YGCategoryManager.h"
#import "YGTools.h"

@interface YGCategoryDefaultEditController () <UITextFieldDelegate, UITextViewDelegate> {
    
    NSString *p_name;
    NSInteger p_sort;
    NSString *p_comment;
    
    BOOL _isNameChanged;
    BOOL _isSortChanged;
    BOOL _isCommentChanged;
    
    NSString *_initNameValue;
    NSInteger _initSortValue;
    NSString *_initCommentValue;
    
    YGCategoryManager *p_manager;
}


@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelSort;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsOfControllers;

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSort;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOfController;

- (IBAction)buttonActivatePressed:(UIButton *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)textFieldNameEditingChanged:(UITextField *)sender;
- (IBAction)textFieldSortEditingChanged:(UITextField *)sender;

@end

@implementation YGCategoryDefaultEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    p_manager = [YGCategoryManager sharedInstance];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if(self.categoryType == YGCategoryTypeIncome)
        self.navigationItem.title = NSLocalizedString(@"INCOME_SOURCE_EDIT_FORM_TITLE", @"Title of Income source form.");
    else if(self.categoryType == YGCategoryTypeCreditorOrDebtor){
        self.navigationItem.title = NSLocalizedString(@"CREDITOR_DEBTOR_EDIT_FORM_TITLE", @"Title of Creditor/Debtor view/edit form.");
    }
    else if(self.categoryType == YGCategoryTypeTag){
        self.navigationItem.title = NSLocalizedString(@"TAG_EDIT_FORM_TITLE", @"Title of Tag edit form.");
    }
    
    if(self.isNewCategory){
        
        self.category = nil;
        p_name = nil;
        p_sort = 100;
        self.textFieldSort.text = @"100";
        
        
        p_comment = nil;
        // имитируем placeholder у textView
        self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
        self.textViewComment.textColor = [UIColor lightGrayColor];
        self.textViewComment.delegate = self;

        
        self.buttonActivate.enabled = NO;
        self.buttonDelete.enabled = NO;
        
        self.labelName.textColor = [YGTools colorRed];
        
        [self.textFieldName becomeFirstResponder];
    }
    else{
        
        self.textFieldName.text = self.category.name;
        p_name = self.category.name;
        
        self.textFieldSort.text = [NSString stringWithFormat:@"%ld", (long)self.category.sort];
        p_sort = self.category.sort;
        
        p_comment = self.category.comment;
        
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
        
        
        self.buttonActivate.enabled = YES;
        self.buttonDelete.enabled = YES;
        
        if(self.category.active){
            [self.buttonActivate setTitle: NSLocalizedString(@"DEACTIVATE_BUTTON_TITLE", @"Label of Deactivate button.") forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionDeactivate];
        }
        else{
            [self.buttonActivate setTitle:NSLocalizedString(@"ACTIVATE_BUTTON_TITLE", @"Label of Activate button.") forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionActivate];
        }
    }
    
    _isNameChanged = NO;
    _isSortChanged = NO;
    _isCommentChanged = NO;
    
    _initNameValue = p_name;
    _initSortValue = p_sort;
    _initCommentValue = p_comment;
    
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    self.textFieldName.delegate = self;
    self.textFieldSort.delegate = self;
    self.textViewComment.delegate = self;
    
    [self setDefaultFontForControls];
}


- (void)setDefaultFontForControls {
    
    // set font size of labels
    for(UILabel *label in self.labelsOfControllers){
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor,
                                     };
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
        
        if(textView.text && [textView.text isEqualToString:@""])
            p_comment = textView.text;
        else
            p_comment = nil;

        return [YGTools isValidCommentInSourceString:textView.text replacementString:text range:range];
    }
    else
        return NO;
}


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


#pragma mark - Monitoring of control value changed

- (IBAction)textFieldNameEditingChanged:(UITextField *)sender {
    
    p_name = self.textFieldName.text;
    
    if([_initNameValue isEqualToString:p_name])
        _isNameChanged = NO;
    else
        _isNameChanged = YES;
    
    if([self.textFieldName.text isEqualToString:@""])
        self.labelName.textColor = [YGTools colorRed];
    else
        self.labelName.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
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


- (BOOL)isEditControlsChanged{
    if(_isNameChanged)
        return YES;
    if(_isSortChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
    
    return NO;
}


- (BOOL) isDataReadyForSave {
    if(!p_name || [p_name isEqualToString:@""])
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Save, deactivate/activate and delete actions

- (void)saveButtonPressed {
    
    p_name = [p_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    p_comment = [p_comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(p_sort < 1 || p_sort > 999)
        p_sort = 100;
    
    if(self.isNewCategory){
        
        YGCategory *expenseCategory = [[YGCategory alloc]
                                       initWithType:self.categoryType
                                       name:p_name
                                       sort:p_sort
                                       symbol:nil
                                       attach:NO
                                       parentId:-1
                                       comment:p_comment];
        
        [p_manager addCategory:expenseCategory];
    }
    else{
        
        if(_isNameChanged)
            self.category.name = p_name;
        if(_isSortChanged)
            self.category.sort = p_sort;
        if(_isCommentChanged)
            self.category.comment = p_comment;
        
        self.category.modified = [NSDate date];

        // change db, not instance
        [p_manager updateCategory:[self.category copy]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonActivatePressed:(UIButton *)sender {
    
    if(self.category.active){
        
        if(![p_manager hasActiveCategoryForTypeExceptCategory:self.category]){
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DEACTIVATE_ALERT_TITLE", @"Title of alert Can not deactivate") message:NSLocalizedString(@"REASON_CAN_NOT_DEACTIVATE_CATEGORY_BECOUSE_CATEGORY_HAS_LINKED_OBJECTS_MESSAGE", @"Message with reason that applicatin must have at least one active category") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [controller addAction:actionOk];
            [self presentViewController:controller animated:YES completion:nil];
            
            [self disableButtonActivate];
            
            return;
        }
        
        [p_manager deactivateCategory:self.category];
    }
    else
        [p_manager activateCategory:self.category];
    
    // the best way is return to list of categories
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    if([p_manager hasLinkedObjectsForCategory:self.category]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_CATEGORY_HAS_LINKED_OBJECTS_MESSAGE", @"Message with reason that category has linked objects (operations, accounts, debts, etc.)") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    if(![p_manager hasActiveCategoryForTypeExceptCategory:self.category]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_ABSENT_ANOTHER_ACTIVE_CATEGORY_FOR_TYPE_MESSAGE", @"Message with reason that category is only one active for type and another is not exists.") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    if([p_manager isJustOneCategory:self.category]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_ONLY_ONE_CATEGORY_EXISTS_FOR_TYPE_MESSAGE", @"Message with reason that category is only one for type and can not be deleted.") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    [p_manager removeCategory:self.category];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)disableButtonDelete {
    self.buttonDelete.enabled = NO;
    self.buttonDelete.backgroundColor = [UIColor lightGrayColor];
    self.buttonDelete.titleLabel.textColor = [UIColor whiteColor];
}


- (void)disableButtonActivate {
    self.buttonDelete.enabled = NO;
    self.buttonDelete.backgroundColor = [UIColor lightGrayColor];
    self.buttonDelete.titleLabel.textColor = [UIColor whiteColor];
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    // action delete
    if(indexPath.section == 2 && indexPath.row == 1){
        if(self.category){
            
            if([p_manager hasLinkedObjectsForCategory:self.category]
               || ![p_manager hasActiveCategoryForTypeExceptCategory:self.category]
               || [p_manager isJustOneCategory:self.category]){
                
                height = 0.0f;
            }
        }
        else{
            height = 0.0f;
        }
    }

    // action deactivate
    if(indexPath.section == 2 && indexPath.row == 0){
        
        if(self.category && self.category.active){
            
            if(![p_manager hasActiveCategoryForTypeExceptCategory:self.category]){
                
                height = 0.0f;
            }
            
        }
        else if(!self.category){
            height = 0.0f;
        }
    }
    
    return height;
}


#pragma mark - Tools

- (NSInteger)sortValueFromString:(NSString *)string{
    
    NSInteger result = 100;
    
    @try {
        
        if(string && [string length] > 0){
            result = [string integerValue];
        }
    } @catch (NSException *ex) {
        NSLog(@"Error in -[YGExpenseCategoryEditController sortValueFromString]. Exception: %@", [ex description]);
    } @finally {
        return result;
    }
}

@end
