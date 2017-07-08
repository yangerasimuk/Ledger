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

@interface YGAccountEditController () {
    BOOL _isNameChanged;
    BOOL _isSortChanged;
    BOOL _isCommentChanged;
    BOOL _isCurrencyChanged;
    BOOL _isDefaultChanged;
    
    NSString *_initNameValue;
    NSString *_initSortValue;
    NSString *_initCommentValue;
    YGCategory *_initCurrencyValue;
    BOOL _initIsDefaultValue;
    
    YGCategoryManager *_cm;
    YGEntityManager *_em;
}

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSort;
@property (weak, nonatomic) IBOutlet UITextField *textFieldComment;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrency;
@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UISwitch *switchIsDefault;

- (IBAction)textFieldNameEditingChanged:(UITextField *)sender;
- (IBAction)textFieldSortEditingChanged:(UITextField *)sender;
- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender;
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
    
    self.navigationItem.title = @"Account";
    
    if(self.isNewAccount){
        self.account = nil;
        self.currency = nil;
        self.textFieldSort.text = @"100";
        self.switchIsDefault.on = NO;
        
        self.buttonActivate.enabled = NO;
        self.buttonActivate.titleLabel.text = @"Deactivate";
        [self.buttonActivate setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        self.buttonDelete.enabled = NO;
        [self.buttonActivate setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        self.labelCurrency.text = @"No currency";
    }
    else{
        self.textFieldName.text = self.account.name;
        self.textFieldSort.text = [NSString stringWithFormat:@"%ld",self.account.sort];
        self.textFieldComment.text = self.account.comment;
        
        self.switchIsDefault.on = self.account.attach;
        
        self.buttonActivate.enabled = YES;
        self.buttonDelete.enabled = YES;
        
        if(self.account.active)
            [self.buttonActivate setTitle:@"Deactivate" forState:UIControlStateNormal];
        else
            [self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
        
        // get currency object by currencyId
        self.currency = [_cm categoryById:self.account.currencyId];
        self.labelCurrency.text = self.currency.name;
    }
    

    // init state for user changes
    _isNameChanged = NO;
    _isSortChanged = NO;
    _isCommentChanged = NO;
    _isCurrencyChanged = NO;
    _isDefaultChanged = NO;
    
    // init state of UI
    _initNameValue = self.textFieldName.text;
    _initSortValue = self.textFieldSort.text;
    _initCommentValue = self.textFieldComment.text;
    _initCurrencyValue = [self.currency copy];
    _initIsDefaultValue = self.switchIsDefault.isOn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Come back from currency choice

- (IBAction)unwindToAccountEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGCurrencyChoiceController *vc = unwindSegue.sourceViewController;
    
    // set current currency
    YGCategory *currency = vc.targetCurrency;
    self.currency = [currency copy];
    
    // update UI
    self.labelCurrency.text = currency.name;
    
    // equal to init currency value and set flag of changes
    if([currency isEqual:_initCurrencyValue])
        _isCurrencyChanged = NO;
    else{
        _isCurrencyChanged = YES;
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

- (IBAction)switchIsDefaultValueChanged:(UISwitch *)sender {
    
    BOOL newValue = self.switchIsDefault.isOn;
    
    if(_initIsDefaultValue == newValue)
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

#pragma mark - Change save button enable

- (void) changeSaveButtonEnable{
    
    if(!self.isNewAccount){
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
    
    if(self.isNewAccount){

        YGEntity *account = [[YGEntity alloc]
                             initWithType:YGEntityTypeAccount
                             name:self.textFieldName.text
                             sum:0 //sum:[self.textFieldSort.text integerValue]
                             currencyId:self.currency.rowId
                             attach:self.switchIsDefault.isOn
                             sort:[self.textFieldSort.text integerValue]
                             comment:self.textFieldComment.text
                             ];
        
        [_em addEntity:account];
        
        if(self.switchIsDefault.isOn)
            [_em setOnlyOneDefaultEntity:[account copy]];
    }
    else{
        
        if(_isNameChanged)
            self.account.name = self.textFieldName.text;
        if(_isSortChanged)
            self.account.sort = [self sortValueFromString:self.textFieldSort.text];
        if(_isCommentChanged)
            self.account.comment = self.textFieldComment.text;
        if(_isCurrencyChanged)
            self.account.currencyId = self.currency.rowId;
        if(_isDefaultChanged)
            self.account.attach = self.switchIsDefault.isOn;
        
        // change db, not instance
        [_em updateEntity:[self.account copy]];
        
        if(_isDefaultChanged && _initIsDefaultValue == NO){
            [_em setOnlyOneDefaultEntity:[self.account copy]];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonActivatePressed:(UIButton *)sender {
    
    if(self.account.active){
        [_em deactivateEntity:self.account];
        [self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
    }
    else{
        [_em activateEntity:self.account];
        [self.buttonActivate setTitle:@"Dectivate" forState:UIControlStateNormal];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    if(![_em isExistRecordsForEntity:self.account]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Удаление невозможно" message:@"Для удаления данной категории расхода, необходимо удалить все связанные с ней записи (категории, операции, счета, долги и т.д)." preferredStyle:UIAlertControllerStyleAlert];
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
    
    vc.sourceCurrency = self.currency;
}
@end
