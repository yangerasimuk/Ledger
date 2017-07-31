//
//  YGExpenseCategoryEditController.m
//  Ledger
//
//  Created by Ян on 14/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGExpenseCategoryEditController.h"
#import "YYGExpenseParentChoiceController.h"
#import "YGCategoryManager.h"
#import "YGTools.h"

@interface YGExpenseCategoryEditController () <UITextFieldDelegate> {
    BOOL _isNameChanged;
    BOOL _isSortChanged;
    BOOL _isCommentChanged;
    BOOL _isParentChanged;
    
    NSString *_initNameValue;
    NSString *_initSortValue;
    NSString *_initCommentValue;
    YGCategory *_initParentValue;
    
    YGCategoryManager *p_manager;
}

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSort;
@property (weak, nonatomic) IBOutlet UITextField *textFieldComment;
@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UILabel *labelParent;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellParentCategory;

- (IBAction)buttonActivatePressed:(UIButton *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)textFieldNameEditingChanged:(UITextField *)sender;
- (IBAction)textFieldSortEditingChanged:(UITextField *)sender;
- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender;

@end

@implementation YGExpenseCategoryEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    p_manager = [YGCategoryManager sharedInstance];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.navigationItem.title = @"Expense categories";
    
    
    if(self.isNewExpenseCategory){
        self.expenseCategory = nil;
        
        self.buttonActivate.enabled = NO;
        self.buttonActivate.titleLabel.text = @"Deactivate";
        
        self.buttonDelete.enabled = NO;
        
        self.labelParent.text = @"Root";
        
        _initParentValue = nil;
    }
    else{
        self.textFieldName.text = self.expenseCategory.name;
        self.textFieldSort.text = [NSString stringWithFormat:@"%ld",(long)self.expenseCategory.sort];
        self.textFieldComment.text = self.expenseCategory.comment;
        
        self.buttonActivate.enabled = YES;
        self.buttonDelete.enabled = YES;
        
        if(self.expenseCategory.active){
            [self.buttonActivate setTitle:@"Deactivate" forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionDeactivate];
        }
        else{
            [self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionActivate];
        }
        
        if(_expenseCategory.parentId > 0){
            
            _expenseCategoryParent = [p_manager categoryById:_expenseCategory.parentId type:YGCategoryTypeExpense];
            self.labelParent.text = _expenseCategoryParent.name;
            
            _initParentValue = [_expenseCategoryParent copy];
            
        }
        else{
            self.labelParent.text = @"No parent";
            _expenseCategoryParent = nil;
            _initParentValue = nil;
        }
    }
    
    _isNameChanged = NO;
    _isSortChanged = NO;
    _isCommentChanged = NO;
    _isParentChanged = NO;
    
    _initNameValue = self.textFieldName.text;
    _initSortValue = self.textFieldSort.text;
    _initCommentValue = self.textFieldComment.text;
    
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    //
    self.textFieldName.delegate = self;
    self.textFieldSort.delegate = self;
    self.textFieldComment.delegate = self;
    
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    
    if([p_manager hasLinkedObjectsForCategory:self.expenseCategory]) {
        self.cellParentCategory.userInteractionEnabled = NO;
        ;
        self.cellParentCategory.accessoryType = UITableViewCellAccessoryNone;
        self.labelParent.textColor = [YGTools colorForActionDisable];
        
    }
    else{
        self.cellParentCategory.userInteractionEnabled = YES;
        self.cellParentCategory.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.labelParent.textColor = [UIColor blackColor];
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.textFieldName])
        return [YGTools isValidNameInSourceString:textField.text replacementString:string range:range];
    else if([textField isEqual:self.textFieldSort])
        return [YGTools isValidSortInSourceString:textField.text replacementString:string range:range];
    else if([textField isEqual:self.textFieldComment])
        return [YGTools isValidNoteInSourceString:textField.text replacementString:string range:range];
    else
        return NO;
}

#pragma mark - Come back from parent category choice

- (IBAction)unwindToExpenseCategoryEdit:(UIStoryboardSegue *)unwindSegue {
    
    NSLog(@"-[YGExpenseCategoryEditController unwindFromParentCategoryChoice:]..");
    
    YYGExpenseParentChoiceController *vc = unwindSegue.sourceViewController;
    
    if(vc.targetParentCategory){
        
        self.labelParent.text = [NSString stringWithFormat:@"%@", vc.targetParentCategory.name];
        
        _expenseCategoryParent = vc.targetParentCategory;
    }
    else{
        self.labelParent.text = @"No parent";
        _expenseCategoryParent = nil;
    }
    
    if(![_expenseCategoryParent isEqual:_initParentValue]){
        // UI
        _isParentChanged = YES;
        [self changeSaveButtonEnable];
    }
}

#pragma mark - Monitoring of control value changed

- (IBAction)textFieldNameEditingChanged:(UITextField *)sender {
    
    NSString *newName = self.textFieldName.text;
    
    if([_initNameValue isEqualToString:newName])
        _isNameChanged = NO;
    else
        _isNameChanged = YES;
    
    [self changeSaveButtonEnable];
    
}

- (IBAction)textFieldSortEditingChanged:(UITextField *)sender {
    
    NSString *newSort = self.textFieldSort.text;
    
    if([_initSortValue isEqualToString:newSort])
        _isSortChanged = NO;
    else
        _isSortChanged = YES;
    
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


- (BOOL)isEditControlsChanged{
    if(_isNameChanged)
        return YES;
    if(_isSortChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
     if(_isParentChanged)
         return YES;
    
    return NO;
}

#pragma mark - Change save button enable

- (void) changeSaveButtonEnable{
    
    if(!self.isNewExpenseCategory){
        if([self isEditControlsChanged]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else{
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else{
        
        if([self isEditControlsChanged]){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else{
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
}


#pragma mark - Save, deactivate/activate and delete actions

- (void)saveButtonPressed {
    
    if(self.isNewExpenseCategory){
        
        YGCategory *expenseCategory = [[YGCategory alloc]
                                       initWithType:YGCategoryTypeExpense
                                       name:self.textFieldName.text
                                       sort:[self.textFieldSort.text integerValue]
                                       shortName:nil
                                       symbol:nil
                                       attach:NO
                                       parentId:self.expenseCategoryParent.rowId
                                       comment:self.textFieldComment.text];
        
        [p_manager addCategory:expenseCategory];
    }
    else{
        
        if(_isNameChanged)
            self.expenseCategory.name = self.textFieldName.text;
        if(_isSortChanged)
            self.expenseCategory.sort = [self sortValueFromString:self.textFieldSort.text];
        if(_isCommentChanged)
            self.expenseCategory.comment = self.textFieldComment.text;
        if(_isParentChanged)
            self.expenseCategory.parentId = self.expenseCategoryParent.rowId;
        
        // change db, not instance
        [p_manager updateCategory:[self.expenseCategory copy]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonActivatePressed:(UIButton *)sender {
    
    if(self.expenseCategory.active){
        
        if(![p_manager hasActiveCategoryForTypeExceptCategory:self.expenseCategory]){
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Деактивировать невозможно" message:@"Для работы программы нужна хотя бы одна активная категория данного типа." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [controller addAction:actionOk];
            [self presentViewController:controller animated:YES completion:nil];
            
            [self disableButtonActivate];
            
            return;
        }
        
        if([p_manager hasChildObjectActiveForCategory:self.expenseCategory]){
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Деактивировать невозможно" message:@"Для деактивации категории необходимо деактивировать все дочерние подкатегории." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [controller addAction:actionOk];
            [self presentViewController:controller animated:YES completion:nil];
            
            [self disableButtonActivate];
            
            return;
        }
        
        [p_manager deactivateCategory:self.expenseCategory];
        //[self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
    }
    else{
        [p_manager activateCategory:self.expenseCategory];
        //[self.buttonActivate setTitle:@"Dectivate" forState:UIControlStateNormal];
    }
    
    // the best way is return to list of categories
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    // check for linked object existens
    if([p_manager hasLinkedObjectsForCategory:self.expenseCategory]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для удаления данной категории, необходимо удалить все связанные с ней записи (категории, операции, счета, долги и т.д)." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    // check for linked object existens
    if([p_manager hasChildObjectForCategory:self.expenseCategory]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для удаления данной категории, необходимо удалить или отвязать все подкатегории." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    if(![p_manager hasActiveCategoryForTypeExceptCategory:self.expenseCategory]){
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для работы программы нужна хотя бы одна активная категория данного типа." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    // check for removed category just one
    if([p_manager isJustOneCategory:self.expenseCategory]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для работы программы нужна хотя бы одна категория данного типа." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    // remove category
    [p_manager removeCategory:self.expenseCategory];
    
    // return to Option controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)disableButtonDelete {
    self.buttonDelete.enabled = NO;
    self.buttonDelete.backgroundColor = [UIColor lightGrayColor];
    self.buttonDelete.titleLabel.textColor = [UIColor whiteColor];
}

- (void)disableButtonActivate {
    self.buttonActivate.enabled = NO;
    self.buttonActivate.backgroundColor = [UIColor lightGrayColor];
    self.buttonActivate.titleLabel.textColor = [UIColor whiteColor];
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

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    // action delete
    if(indexPath.section == 2 && indexPath.row == 1){
        
        if(self.expenseCategory){
            
            if([p_manager hasLinkedObjectsForCategory:self.expenseCategory]
               || [p_manager hasChildObjectForCategory:self.expenseCategory]
               || ![p_manager hasActiveCategoryForTypeExceptCategory:self.expenseCategory]
               || [p_manager isJustOneCategory:self.expenseCategory]){
                height = 0.0f;
            }
        }
        else { // for new category
            height = 0.0f;
        }
    }
    
    // action deactivate
    if(indexPath.section == 2 && indexPath.row == 0){
        
        if(self.expenseCategory && self.expenseCategory.active){
            
            if(![p_manager hasActiveCategoryForTypeExceptCategory:self.expenseCategory]
               || [p_manager hasChildObjectActiveForCategory:self.expenseCategory]){
                
                height = 0.0f;
            }
        }
        else if(!self.expenseCategory){
            
            height = 0.0f;
        }
    }
    
    return height;
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     YYGExpenseParentChoiceController *vc = segue.destinationViewController;
     
     //vc.expenseCategoryId = _expenseCategory.rowId;
    vc.expenseCategory = _expenseCategory;
     //vc.sourceParentId = _expenseCategory.parentId;
    
    //YGCategory *parent = [p_manager categoryById:_ex type:<#(YGCategoryType)#>]
    
    vc.sourceParentCategory = _expenseCategoryParent;
}

@end
