//
//  YGCurrencyEditController.m
//  Ledger
//
//  Created by Ян on 01/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCurrencyEditController.h"
#import "YGCategoryManager.h"
#import "YGTools.h"

@interface YGCurrencyEditController () <UITextFieldDelegate> {
    
    NSString *p_name;
    NSString *p_symbol;
    NSInteger p_sort;
    NSString *p_comment;
    BOOL p_isDefault;
    
    BOOL _isNameChanged;
    BOOL _isSymbolChanged;
    BOOL _isSortChanged;
    BOOL _isCommentChanged;
    BOOL _isDefaultChanged;
    
    NSString *_initNameValue;
    NSString *_initSymbolValue;
    NSInteger _initSortValue;
    BOOL _initDefaultValue;
    NSString *_initCommentValue;
    
    YGCategoryManager *p_manager;
}

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelSymbol;
@property (weak, nonatomic) IBOutlet UILabel *labelSort;

@property (weak, nonatomic) IBOutlet UITextField *currencyName;
@property (weak, nonatomic) IBOutlet UITextField *currencySymbol;
@property (weak, nonatomic) IBOutlet UITextField *currencySort;
@property (weak, nonatomic) IBOutlet UITextField *currencyComment;
@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UISwitch *currencyIsDefault;

- (IBAction)textNameChanged:(id)sender;
- (IBAction)textSymbolChanged:(id)sender;
- (IBAction)textSortChanged:(id)sender;
- (IBAction)textCommentChanged:(id)sender;
- (IBAction)sliderDefaultChanged:(id)sender;
- (IBAction)buttonActivatePressed:(UIButton *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;

@end

@implementation YGCurrencyEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    p_manager = [YGCategoryManager sharedInstance];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.navigationItem.title = @"Currency";
    
    if(self.isNewCurrency){

        self.currency = nil;
        p_name = nil;
        p_sort = 100;
        self.currencySort.text = @"100";
        p_isDefault = NO;
        self.currencyIsDefault.on = NO;
        p_comment = nil;
        
        self.buttonActivate.enabled = NO;
        self.buttonActivate.titleLabel.text = @"Deactivate";

        self.buttonDelete.enabled = NO;
        
        self.labelName.textColor = [UIColor redColor];
        self.labelSymbol.textColor = [UIColor redColor];
    }
    else{

        self.currencyName.text = self.currency.name;
        p_name = self.currency.name;
        
        self.currencySymbol.text = self.currency.symbol;
        p_symbol = self.currency.symbol;
        
        self.currencySort.text = [NSString stringWithFormat:@"%ld", self.currency.sort];
        p_sort = self.currency.sort;
        
        self.currencyIsDefault.on = self.currency.isAttach;
        p_isDefault = self.currency.isAttach;
        
        self.currencyComment.text = self.currency.comment;
        p_comment = self.currency.comment;
        
        self.buttonActivate.enabled = YES;
        self.buttonDelete.enabled = YES;
        
        if(self.currency.active){
            [self.buttonActivate setTitle:@"Deactivate" forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionDeactivate];
        }
        else{
            [self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionActivate];
        }
    }
    
    _isNameChanged = NO;
    _isSymbolChanged = NO;
    _isSortChanged = NO;
    _isDefaultChanged = NO;
    _isCommentChanged = NO;
    
    _initNameValue = p_name;
    _initSymbolValue = p_symbol;
    _initSortValue = p_sort;
    _initDefaultValue = p_isDefault;
    _initCommentValue = p_comment;
    
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.currencyName.delegate = self;
    self.currencySymbol.delegate = self;
    self.currencySort.delegate = self;
    self.currencyComment.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.currencyName])
        return [YGTools isValidNameInSourceString:textField.text replacementString:string range:range];
    else if([textField isEqual:self.currencySymbol])
        return [YGTools isValidSymbolInSourceString:textField.text replacementString:string range:range];
    else if([textField isEqual:self.currencySort])
        return [YGTools isValidSortInSourceString:textField.text replacementString:string range:range];
    else if([textField isEqual:self.currencyComment])
        return [YGTools isValidNoteInSourceString:textField.text replacementString:string range:range];
    else
        return NO;
}

#pragma mark - Monitoring of control value changed

- (IBAction)textNameChanged:(id)sender{
    
    p_name = self.currencyName.text;
    
    if([_initNameValue isEqualToString:p_name])
        _isNameChanged = NO;
    else
        _isNameChanged = YES;
    
    if([self.currencyName.text isEqualToString:@""])
        self.labelName.textColor = [UIColor redColor];
    else
        self.labelName.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
    
}

- (IBAction)textSymbolChanged:(id)sender{
    
    p_symbol = self.currencySymbol.text;
    
    if([_initSymbolValue isEqualToString:p_symbol])
        _isSymbolChanged = NO;
    else
        _isSymbolChanged = YES;
    
    if([self.currencySymbol.text isEqualToString:@""])
        self.labelSymbol.textColor = [UIColor redColor];
    else
        self.labelSymbol.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
    
}
- (IBAction)textSortChanged:(id)sender{
    
    p_sort = [self.currencySort.text integerValue];
    
    if(_initSortValue == p_sort)
        _isSortChanged = NO;
    else
        _isSortChanged = YES;
    
    if([self.currencySort.text isEqualToString:@""])
        self.labelSort.textColor = [UIColor redColor];
    else
        self.labelSort.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
}


- (IBAction)textCommentChanged:(id)sender {
    
    p_comment = self.currencyComment.text;
    
    if([_initCommentValue isEqualToString:p_comment])
        _isCommentChanged = NO;
    else
        _isCommentChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (IBAction)sliderDefaultChanged:(id)sender {
    
    p_isDefault = self.currencyIsDefault.isOn;
    
    if(_initDefaultValue == p_isDefault)
        _isDefaultChanged = NO;
    else
        _isDefaultChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (BOOL)isEditControlsChanged{
    if(_isNameChanged)
        return YES;
    if(_isSymbolChanged)
        return YES;
    if(_isSortChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
    if(_isDefaultChanged)
        return YES;
    
    return NO;
}


- (BOOL) isDataReadyForSave {
    if(!p_name || [p_name isEqualToString:@""])
        return NO;
    if(!p_symbol || [p_symbol isEqualToString:@""])
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


#pragma mark - Save, activate/deactivate and delete actions

- (void)saveButtonPressed {
    
    if(_isNewCurrency){
        YGCategory *currency = [[YGCategory alloc] initWithType:YGCategoryTypeCurrency name:self.currencyName.text sort:[self.currencySort.text integerValue] symbol:self.currencySymbol.text attach:self.currencyIsDefault.isOn parentId:-1 comment:self.currencyComment.text];
        
        [p_manager addCategory:[currency copy]];
    }
    else{
        
        if(_isNameChanged)
            _currency.name = self.currencyName.text;
        if(_isSymbolChanged)
            _currency.symbol = self.currencySymbol.text;
        if(_isSortChanged)
            _currency.sort = [self sortValueFromString:self.currencySort.text];
        if(_isDefaultChanged)
            _currency.attach = self.currencyIsDefault.isOn;
        if(_isCommentChanged)
            _currency.comment = self.currencyComment.text;
        
        [p_manager updateCategory:[_currency copy]];
        
        // if set to default, and early be not default
        if(_isDefaultChanged && _initDefaultValue == NO){
            [p_manager setOnlyOneDefaultCategory:[_currency copy]];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonActivatePressed:(UIButton *)sender {
    
    if(_currency.active){
        
        if(![p_manager hasActiveCategoryForTypeExceptCategory:_currency]){
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Деактивировать невозможно" message:@"Для работы программы нужна хотя бы одна активная валюта." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [controller addAction:actionOk];
            [self presentViewController:controller animated:YES completion:nil];
            
            [self disableButtonActivate];
            
            return;
        }
        
        [p_manager deactivateCategory:_currency];
        //[self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
    }
    else{
        [p_manager activateCategory:_currency];
        //[self.buttonActivate setTitle:@"Dectivate" forState:UIControlStateNormal];
    }
    
    // the best way is return to list of categories
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    if([p_manager hasLinkedObjectsForCategory:_currency]){
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для удаления данной валюты, необходимо удалить все связанные с ней записи (операции, счета, долги и т.д)." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    // check for removed category just one active
    if(![p_manager hasActiveCategoryForTypeExceptCategory:_currency]){
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для работы программы нужна хотя бы одна активная валюта." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    // check for removed category just one
    if([p_manager isJustOneCategory:_currency]){
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для работы программы нужна хотя бы одна валюта." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    [p_manager removeCategory:_currency];
    
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
        
        if(self.currency){
            if([p_manager hasLinkedObjectsForCategory:_currency]
               || ![p_manager hasActiveCategoryForTypeExceptCategory:_currency]
               || [p_manager isJustOneCategory:_currency]){
                height = 0.0f;
            }
        }
        else{
            height = 0.0f;
        }
    }
    
    
    // action deactivate
    if(indexPath.section == 2 && indexPath.row == 0){
        
        if(self.currency && self.currency.active){
            
            if(![p_manager hasActiveCategoryForTypeExceptCategory:_currency]){
                
                height = 0.0f;
            }
        }
        else if(!self.currency){
            
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
        NSLog(@"Error in -[YGCurrencyEditController sortFromString]. Exception: %@", [ex description]);
    } @finally {
        return result;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
