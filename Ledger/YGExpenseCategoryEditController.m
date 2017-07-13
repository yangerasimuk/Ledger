//
//  YGExpenseCategoryEditController.m
//  Ledger
//
//  Created by Ян on 14/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGExpenseCategoryEditController.h"
#import "YGCategoryManager.h"
#import "YGExpenseParentChoiseController.h"

@interface YGExpenseCategoryEditController (){
    BOOL _isNameChanged;
    BOOL _isSortChanged;
    BOOL _isCommentChanged;
    BOOL _isParentChanged;
    
    NSString *_initNameValue;
    NSString *_initSortValue;
    NSString *_initCommentValue;
    NSInteger _initParentIdValue;
    
    NSInteger _parentId;
    
    YGCategoryManager *p_manager;
    
}

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSort;
@property (weak, nonatomic) IBOutlet UITextField *textFieldComment;
@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UILabel *labelParent;

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
    
    self.navigationItem.title = @"Expense category";
    
    
    if(self.isNewExpenseCategory){
        self.expenseCategory = nil;
        
        self.buttonActivate.enabled = NO;
        self.buttonActivate.titleLabel.text = @"Deactivate";
        [self.buttonActivate setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        self.buttonDelete.enabled = NO;
        [self.buttonActivate setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        self.labelParent.text = @"No parent";
        
        _initParentIdValue = -1;
    }
    else{
        self.textFieldName.text = self.expenseCategory.name;
        self.textFieldSort.text = [NSString stringWithFormat:@"%ld",self.expenseCategory.sort];
        self.textFieldComment.text = self.expenseCategory.comment;
        
        self.buttonActivate.enabled = YES;
        self.buttonDelete.enabled = YES;
        
        if(self.expenseCategory.active)
            [self.buttonActivate setTitle:@"Deactivate" forState:UIControlStateNormal];
        else
            [self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
        
        if(_expenseCategory.parentId > 0){
            
            _expenseParent = [p_manager categoryById:_expenseCategory.parentId];
            self.labelParent.text = _expenseParent.name;
            
        }
        else{
            self.labelParent.text = @"No parent";
            _expenseParent = nil;
        }
        
        _initParentIdValue = _expenseCategory.parentId;

    }
    
    _isNameChanged = NO;
    _isSortChanged = NO;
    _isCommentChanged = NO;
    _isParentChanged = NO;
    
    _initNameValue = self.textFieldName.text;
    _initSortValue = self.textFieldSort.text;
    _initCommentValue = self.textFieldComment.text;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Come back from parent category choice

- (IBAction)unwindToExpenseCategoryEdit:(UIStoryboardSegue *)unwindSegue {
    
    NSLog(@"-[YGExpenseCategoryEditController unwindFromParentCategoryChoice:]..");
    
    YGExpenseParentChoiseController *vc = unwindSegue.sourceViewController;
    
    // check if parentId changed
    if(vc.targetParentId != _initParentIdValue){
        
        // fake or real parent category
        if(vc.targetParentId != -1){
            
            YGCategory *parent = [p_manager categoryById:vc.targetParentId];
            
            self.labelParent.text = [NSString stringWithFormat:@"%@", parent.name];
            
            _expenseParent = parent;
        }
        else{
            self.labelParent.text = @"No parent";
            _expenseParent = nil;
        }
        
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
                                       parentId:self.expenseParent.rowId 
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
            self.expenseCategory.parentId = self.expenseParent.rowId;
        
        // change db, not instance
        [p_manager updateCategory:[self.expenseCategory copy]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonActivatePressed:(UIButton *)sender {
    
    if(self.expenseCategory.active){
        [p_manager deactivateCategory:self.expenseCategory];
        [self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
    }
    else{
        [p_manager activateCategory:self.expenseCategory];
        [self.buttonActivate setTitle:@"Dectivate" forState:UIControlStateNormal];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    // check for linked object existens
    if([p_manager hasLinkedObjectsForCategory:self.expenseCategory]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для удаления данной категории, необходимо удалить все связанные с ней записи (категории, операции, счета, долги и т.д)." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else{
        
        // check for removed category just one
        if([p_manager isJustOneCategory:self.expenseCategory]){
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для работы программы нужна хотя бы одна категория данного типа." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [controller addAction:actionOk];
            [self presentViewController:controller animated:YES completion:nil];
        }
        
        // remove category
        [p_manager removeCategory:self.expenseCategory];
        
        // return to Option controller
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
        NSLog(@"Error in -[YGExpenseCategoryEditController sortValueFromString]. Exception: %@", [ex description]);
    } @finally {
        return result;
    }
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     YGExpenseParentChoiseController *vc = segue.destinationViewController;
     
     vc.expenseCategoryId = _expenseCategory.rowId;
     vc.sourceParentId = _expenseCategory.parentId;
    
 }

@end
