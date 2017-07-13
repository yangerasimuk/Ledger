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

@interface YGCategoryDefaultEditController (){
    BOOL _isNameChanged;
    BOOL _isSortChanged;
    BOOL _isCommentChanged;
    
    NSString *_initNameValue;
    NSString *_initSortValue;
    NSString *_initCommentValue;
    
    YGCategoryManager *p_manager;
}



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
        
        self.buttonActivate.enabled = NO;
        self.buttonActivate.titleLabel.text = @"Deactivate";
        
        self.buttonDelete.enabled = NO;

    }
    else{
        self.textFieldName.text = self.category.name;
        self.textFieldSort.text = [NSString stringWithFormat:@"%ld",self.category.sort];
        self.textFieldComment.text = self.category.comment;
        
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
    
    _initNameValue = self.textFieldName.text;
    _initSortValue = self.textFieldSort.text;
    _initCommentValue = self.textFieldComment.text;
    
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];

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
    
    return NO;
}

#pragma mark - Change save button enable

- (void) changeSaveButtonEnable{
    
    if(!self.isNewCategory){
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Save, deactivate/activate and delete actions

- (void)saveButtonPressed {
    
    if(self.isNewCategory){
        
        YGCategory *expenseCategory = [[YGCategory alloc]
                                       initWithType:self.categoryType
                                       name:self.textFieldName.text
                                       sort:[self.textFieldSort.text integerValue]
                                       shortName:nil
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
            self.category.sort = [self sortValueFromString:self.textFieldSort.text];
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
