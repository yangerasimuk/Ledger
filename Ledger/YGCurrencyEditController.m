//
//  YGCurrencyEditController.m
//  Ledger
//
//  Created by Ян on 01/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCurrencyEditController.h"
#import "YGCategoryManager.h"

@interface YGCurrencyEditController (){
    BOOL _isNameChanged;
    BOOL _isShortNameChanged;
    BOOL _isSymbolChanged;
    BOOL _isSortChanged;
    BOOL _isDefaultChanged;
    
    BOOL _isCommentChanged;
    NSString *_initNameValue;
    NSString *_initShortNameValue;
    NSString *_initSymbolValue;
    NSString *_initSortValue;
    BOOL _initDefaultValue;
    NSString *_initCommentValue;
}


@property (weak, nonatomic) IBOutlet UITextField *currencyName;
@property (weak, nonatomic) IBOutlet UITextField *currencySymbol;
@property (weak, nonatomic) IBOutlet UITextField *currencySort;
@property (weak, nonatomic) IBOutlet UITextField *currencyShortName;
@property (weak, nonatomic) IBOutlet UITextField *currencyComment;
@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UISwitch *currencyIsDefault;

- (IBAction)textNameChanged:(id)sender;
- (IBAction)textSymbolChanged:(id)sender;
- (IBAction)textSortChanged:(id)sender;
- (IBAction)textShortNameChanged:(id)sender;
- (IBAction)textCommentChanged:(id)sender;
- (IBAction)sliderDefaultChanged:(id)sender;
- (IBAction)buttonActivatePressed:(UIButton *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;


@end

@implementation YGCurrencyEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.navigationItem.title = @"Currency";
    
    if(self.isNewCurrency){

        self.currency = nil;
        self.currencySort.text = @"100";
        self.currencyIsDefault.on = NO;
        
        self.buttonDelete.enabled = NO;
        self.buttonActivate.enabled = NO;
        self.buttonActivate.titleLabel.text = @"Deactivate";
        [self.buttonDelete setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self.buttonActivate setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
    else{

        self.currencyName.text = self.currency.name;
        self.currencyShortName.text = self.currency.shortName;
        self.currencySymbol.text = self.currency.symbol;
        self.currencySort.text = [NSString stringWithFormat:@"%ld", self.currency.sort];
        self.currencyComment.text = self.currency.comment;
        self.currencyIsDefault.on = self.currency.isAttach;
        
        self.buttonActivate.enabled = YES;
        self.buttonDelete.enabled = YES;
        
        if(_currency.active){
            [self.buttonActivate setTitle:@"Deactivate" forState:UIControlStateNormal];
        }
        else{
            [self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
        }
    }
    
    _isSortChanged = NO;
    _isNameChanged = NO;
    _isShortNameChanged = NO;
    _isSymbolChanged = NO;
    _isCommentChanged = NO;
    _isDefaultChanged = NO;
    
    _initSortValue = self.currencySort.text;
    _initNameValue = self.currencyName.text;
    _initSymbolValue = self.currencySymbol.text;
    _initShortNameValue = self.currencyShortName.text;
    _initCommentValue = self.currencyComment.text;
    _initDefaultValue = self.currencyIsDefault.isOn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Monitoring of control value changed

- (IBAction)textNameChanged:(id)sender{
    
    NSString *newName = self.currencyName.text;
    
    if([_initNameValue isEqualToString:newName])
        _isNameChanged = NO;
    else
        _isNameChanged = YES;
    
    [self changeSaveButtonEnable];
    
}

- (IBAction)textSymbolChanged:(id)sender{
    
    NSString *newSymbol = self.currencySymbol.text;
    
    if([_initSymbolValue isEqualToString:newSymbol])
        _isSymbolChanged = NO;
    else
        _isSymbolChanged = YES;
    
    [self changeSaveButtonEnable];
    
}
- (IBAction)textSortChanged:(id)sender{
    
    NSString *newSort = self.currencySort.text;
    
    if([_initSortValue isEqualToString:newSort])
        _isSortChanged = NO;
    else
        _isSortChanged = YES;
    
    [self changeSaveButtonEnable];
    
}

- (IBAction)textShortNameChanged:(id)sender {
    NSString *newShortName = self.currencyShortName.text;
    
    if([_initShortNameValue isEqualToString:newShortName])
        _isShortNameChanged = NO;
    else
        _isShortNameChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (IBAction)textCommentChanged:(id)sender {
    NSString *newComment = self.currencyComment.text;
    
    if([_initCommentValue isEqualToString:newComment])
        _isCommentChanged = NO;
    else
        _isCommentChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (IBAction)sliderDefaultChanged:(id)sender {
    
    BOOL newValue = self.currencyIsDefault.isOn;
    
    if(_initDefaultValue == newValue)
        _isDefaultChanged = NO;
    else
        _isDefaultChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (BOOL)isEditControlsChanged{
    if(_isNameChanged)
        return YES;
    if(_isShortNameChanged)
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

#pragma mark - Change save button enable

- (void) changeSaveButtonEnable{
    
    if(!self.isNewCurrency){
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

#pragma mark - Save, activate/deactivate and delete actions

- (void)saveButtonPressed {
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    if(_isNewCurrency){
        YGCategory *currency = [[YGCategory alloc] initWithType:YGCategoryTypeCurrency name:self.currencyName.text sort:[self.currencySort.text integerValue] shortName:self.currencyShortName.text symbol:self.currencySymbol.text attach:self.currencyIsDefault.isOn parentId:-1 comment:self.currencyComment.text];
        
        [manager addCategory:currency];
    }
    else{
        
        if(_isNameChanged)
            _currency.name = self.currencyName.text;
        if(_isShortNameChanged)
            _currency.shortName = self.currencyShortName.text;
        if(_isSymbolChanged)
            _currency.symbol = self.currencySymbol.text;
        if(_isSortChanged)
            _currency.sort = [self sortValueFromString:self.currencySort.text];
        if(_isDefaultChanged)
            _currency.attach = self.currencyIsDefault.isOn;
        if(_isCommentChanged)
            _currency.comment = self.currencyComment.text;
        
        [manager updateCategory:[_currency copy]];
        
        // if set to default, and early be not default
        if(_isDefaultChanged && _initDefaultValue == NO){
            [manager setOnlyOneDefaultCategory:[_currency copy]];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonActivatePressed:(UIButton *)sender {
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    if(_currency.active){
        [manager deactivateCategory:_currency];
        [self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
    }
    else{
        [manager activateCategory:_currency];
        [self.buttonActivate setTitle:@"Dectivate" forState:UIControlStateNormal];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    YGCategoryManager *manager = [YGCategoryManager sharedInstance];
    
    if(![manager isExistRecordsForCategory:_currency]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для удаления данной валюты, необходимо удалить все связанные с ней записи (операции, счета, долги и т.д)." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else{
        [manager removeCategory:_currency];
        
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
