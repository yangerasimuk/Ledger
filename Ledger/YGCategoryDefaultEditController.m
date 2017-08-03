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

@interface YGCategoryDefaultEditController () <UITextFieldDelegate> {
    
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

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSort;
@property (weak, nonatomic) IBOutlet UITextField *textFieldComment;
@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
- (IBAction)buttonActivatePressed:(UIButton *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)textFieldNameEditingChanged:(UITextField *)sender;
- (IBAction)textFieldSortEditingChanged:(UITextField *)sender;
- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender;


@end

@implementation YGCategoryDefaultEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    p_manager = [YGCategoryManager sharedInstance];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if(self.categoryType == YGCategoryTypeIncome){
        self.navigationItem.title = @"Income source";
        
    }
    else if(self.categoryType == YGCategoryTypeCreditorOrDebtor){
        self.navigationItem.title = @"Creditor/Debtor";
    }
    else if(self.categoryType == YGCategoryTypeTag){
        self.navigationItem.title = @"Tag";
    }
    
    if(self.isNewCategory){
        
        self.category = nil;
        p_name = nil;
        p_sort = 100;
        self.textFieldSort.text = @"100";
        p_comment = nil;
        
        self.buttonActivate.enabled = NO;
        self.buttonDelete.enabled = NO;
        
        self.labelName.textColor = [UIColor redColor];
    }
    else{
        
        self.textFieldName.text = self.category.name;
        p_name = self.category.name;
        
        self.textFieldSort.text = [NSString stringWithFormat:@"%ld", (long)self.category.sort];
        p_sort = self.category.sort;
        
        self.textFieldComment.text = self.category.comment;
        p_comment = self.category.comment;
        
        self.buttonActivate.enabled = YES;
        self.buttonDelete.enabled = YES;
        
        if(self.category.active){
            [self.buttonActivate setTitle:@"Deactivate" forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionDeactivate];
        }
        else{
            [self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
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
    self.textFieldComment.delegate = self;
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


#pragma mark - Monitoring of control value changed

- (IBAction)textFieldNameEditingChanged:(UITextField *)sender {
    
    p_name = self.textFieldName.text;
    
    if([_initNameValue isEqualToString:p_name])
        _isNameChanged = NO;
    else
        _isNameChanged = YES;
    
    if([self.textFieldName.text isEqualToString:@""])
        self.labelName.textColor = [UIColor redColor];
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
        self.labelSort.textColor = [UIColor redColor];
    else
        self.labelSort.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
}

- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender {
    
    p_comment = self.textFieldComment.text;
    
    if([_initCommentValue isEqualToString:p_comment])
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
    
    NSUInteger sort = [self.textFieldSort.text integerValue];
    
    if(sort < 1 || sort > 999)
        sort = 100;
    
    if(self.isNewCategory){
        
        YGCategory *expenseCategory = [[YGCategory alloc]
                                       initWithType:self.categoryType
                                       name:self.textFieldName.text
                                       sort:sort
                                       symbol:nil
                                       attach:NO
                                       parentId:-1
                                       comment:self.textFieldComment.text];
        
        [p_manager addCategory:expenseCategory];
    }
    else{
        
        if(_isNameChanged)
            self.category.name = self.textFieldName.text;
        if(_isSortChanged)
            self.category.sort = sort;
        if(_isCommentChanged)
            self.category.comment = self.textFieldComment.text;

        // change db, not instance
        [p_manager updateCategory:[self.category copy]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonActivatePressed:(UIButton *)sender {
    
    if(self.category.active){
        
        if(![p_manager hasActiveCategoryForTypeExceptCategory:self.category]){
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Деактивировать невозможно" message:@"Для работы программы нужна хотя бы одна активная категория данного типа." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [controller addAction:actionOk];
            [self presentViewController:controller animated:YES completion:nil];
            
            [self disableButtonActivate];
            
            return;
        }
        
        [p_manager deactivateCategory:self.category];
        //[self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
    }
    else{
        [p_manager activateCategory:self.category];
        [self.buttonActivate setTitle:@"Dectivate" forState:UIControlStateNormal];
        //[self.buttonActivate setTitleColor:[UIColor ] forState:UIControlStateNormal];
    }
    
    // the best way is return to list of categories
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    if([p_manager hasLinkedObjectsForCategory:self.category]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для удаления данной категории, необходимо удалить все связанные с ней записи (операции, счета, долги и т.д)." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    if(![p_manager hasActiveCategoryForTypeExceptCategory:self.category]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для работы программы нужна хотя бы одна активная категория данного типа." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    if([p_manager isJustOneCategory:self.category]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для работы программы нужна хотя бы одна категория данного типа." preferredStyle:UIAlertControllerStyleAlert];
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
    if(indexPath.section == 1 && indexPath.row == 1){
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
    if(indexPath.section == 1 && indexPath.row == 0){
        
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
