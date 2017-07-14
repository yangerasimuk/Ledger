//
//  YGTransferEditController.m
//  Ledger
//
//  Created by Ян on 23/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGTransferEditController.h"
#import "YGDateChoiceController.h"
#import "YGAccountChoiceController.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGOperationManager.h"
#import "YGTools.h"

@interface YGTransferEditController (){
    NSDate *_date;
    YGEntity *_sourceAccount;
    YGCategory *_sourceCurrency;
    YGEntity *_targetAccount;
    YGCategory *_targetCurrency;
    NSString *_comment;
    
    BOOL _isDateChanged;
    BOOL _isSourceAccountChanged;
    BOOL _isSourceSumChanged;
    BOOL _isTargetAccountChanged;
    BOOL _isTargetSumChanged;
    BOOL _isCommentChanged;
    
    NSDate *_initDateValue;
    YGEntity *_initSourceAccountValue;
    double _initSourceSumValue;
    YGCategory *_initSourceCurrencyValue;
    double _initTargetSumValue;
    YGEntity *_initTargetAccountValue;
    YGCategory *_initTargetCurrencyValue;
    NSString *_initCommentValue;
    
    YGEntityManager *_em;
    YGCategoryManager *_cm;
    YGOperationManager *_om;
}

@property (assign, nonatomic) double sourceSum;
@property (assign, nonatomic) double targetSum;

@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelSourceAccount;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSourceSum;
@property (weak, nonatomic) IBOutlet UILabel *labelSourceCurrency;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetAccount;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTargetSum;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetCurrency;
@property (weak, nonatomic) IBOutlet UITextField *textFieldComment;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;

- (IBAction)textFieldSourceSumEditingChanged:(UITextField *)sender;
- (IBAction)textFieldTargetSumEditingChanged:(UITextField *)sender;
- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;

@end

@implementation YGTransferEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _em = [YGEntityManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
    _om = [YGOperationManager sharedInstance];
    
    if(self.isNewTransfer){
        
        // set date
        _date = [NSDate date];
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_date];

        // try to get last transfer
        YGOperation *lastOperation = [_om lastOperationForType:YGOperationTypeTransfer];
        
        if(lastOperation){
            
            // set source account
            _sourceAccount = [_em entityById:lastOperation.sourceId type:YGEntityTypeAccount];
            self.labelSourceAccount.text = _sourceAccount.name;
            
            // set source currence
            //_sourceCurrency = [_cm categoryById:lastOperation.sourceCurrencyId];
            _sourceCurrency = [_cm categoryById:lastOperation.sourceCurrencyId type:YGCategoryTypeCurrency];
            self.labelSourceCurrency.text = _sourceCurrency.name;
            
            
            // set target account
            _targetAccount = [_em entityById:lastOperation.targetId type:YGEntityTypeAccount];
            self.labelTargetAccount.text = _targetAccount.name;
            
            // set target currency
            //_targetCurrency = [_cm categoryById:lastOperation.targetCurrencyId];
            _targetCurrency = [_cm categoryById:lastOperation.targetCurrencyId type:YGCategoryTypeCurrency];
            self.labelTargetCurrency.text = _targetCurrency.name;
            
            self.buttonDelete.enabled = NO;
            
        }
        else{
            _sourceAccount = nil;
            self.labelSourceAccount.text = @"No account";
            self.sourceSum = 0.0;
            self.labelSourceCurrency = nil;
            
            _targetAccount = nil;
            self.labelTargetAccount.text = @"No account";
            self.targetSum = 0.0;
            self.labelTargetCurrency = nil;
        }
        
        // init
        _initDateValue = [_date copy];
        _initSourceAccountValue = nil;
        _initSourceSumValue = 0.0;
        _initSourceCurrencyValue = nil;
        _initTargetAccountValue = nil;
        _initTargetSumValue = 0.0;
        _initSourceCurrencyValue = nil;
        _initCommentValue = nil;
        
        // set focus on sum only for new element
        [self.textFieldSourceSum becomeFirstResponder];
    }
    else{
        
        // set date
        _date = self.transfer.date;
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_date];
        
        // set source account
        _sourceAccount = [_em entityById:self.transfer.sourceId type:YGEntityTypeAccount];
        self.labelSourceAccount.text = _sourceAccount.name;
        
        // set source sum
        _sourceSum = self.transfer.sourceSum;
        self.textFieldSourceSum.text = [NSString stringWithFormat:@"%.2f", _sourceSum];
        
        // set source currency
        //_sourceCurrency = [_cm categoryById:self.transfer.sourceCurrencyId];
        _sourceCurrency = [_cm categoryById:self.transfer.sourceCurrencyId type:YGCategoryTypeCurrency];
        self.labelSourceCurrency.text = [_sourceCurrency shorterName];
        
        // set target account
        _targetAccount = [_em entityById:self.transfer.targetId type:YGEntityTypeAccount];
        self.labelTargetAccount.text = _targetAccount.name;
        
        // set target sum
        _targetSum = self.transfer.targetSum;
        self.textFieldTargetSum.text = [NSString stringWithFormat:@"%.2f", _targetSum];
        
        // set target currency
        //_targetCurrency = [_cm categoryById:self.transfer.targetCurrencyId];
        _targetCurrency = [_cm categoryById:self.transfer.targetCurrencyId type:YGCategoryTypeCurrency];
        self.labelTargetCurrency.text = [_targetCurrency shorterName];
        
        // set comment
        _comment = self.transfer.comment;
        self.textFieldComment.text = _comment;
        
        // init
        _initDateValue = [_date copy];
        _initSourceAccountValue = [_sourceAccount copy];
        _initSourceSumValue = _sourceSum;
        _initSourceCurrencyValue = [_sourceCurrency copy];
        _initTargetAccountValue = [_targetAccount copy];
        _initTargetSumValue = _targetSum;
        _initCommentValue = [_comment copy];
    }
    
    // button save
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // title
    self.navigationItem.title = @"Transfer";
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isSourceAccountChanged = NO;
    _isSourceSumChanged = NO;
    _isTargetAccountChanged = NO;
    _isTargetSumChanged = NO;
    _isCommentChanged = NO;
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties source and target sums setters

- (void)setSourceSum:(double)sourceSum {
    _sourceSum = round(sourceSum * 100.0)/100.0;
    
}

- (void)setTargetSum:(double)targetSum {
    _targetSum = round(targetSum * 100.0)/100.0;
}


#pragma mark - Come back from other choice controllers

- (IBAction)unwindFromDateChoiceToTransferEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGDateChoiceController *vc = unwindSegue.sourceViewController;
    
    _date = vc.targetDate;
    
    self.labelDate.text = [YGTools humanViewWithTodayOfDate:_date];
    
    // date changed?
    if([YGTools isDayOfDate:_date equalsDayOfDate:_initDateValue])
        _isDateChanged = NO;
    else
        _isDateChanged = YES;
    
    [self changeSaveButtonEnable];
    
}

- (IBAction)unwindFromSourceAccountChoiceToTransferEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _sourceAccount = vc.targetAccount;
    self.labelSourceAccount.text = _sourceAccount.name;
    
    // may be lazy?
    //_sourceCurrency = [_cm categoryById:_sourceAccount.currencyId];
    _sourceCurrency = [_cm categoryById:_sourceAccount.currencyId type:YGCategoryTypeCurrency];
    self.labelSourceCurrency.text = [_sourceCurrency shorterName];
    
    if([_sourceAccount isEqual:_initSourceAccountValue])
        _isSourceAccountChanged = NO;
    else
        _isSourceAccountChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (IBAction)unwindFromTargetAccountChoiceToTransferEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _targetAccount = vc.targetAccount;
    self.labelTargetAccount.text = _targetAccount.name;
    
    // may be lazy?
    //_targetCurrency = [_cm categoryById:_targetAccount.currencyId];
    _targetCurrency = [_cm categoryById:_targetAccount.currencyId type:YGCategoryTypeCurrency];
    self.labelTargetCurrency.text = [_targetCurrency shorterName];
    
    if([_targetAccount isEqual:_initTargetAccountValue])
        _isTargetAccountChanged = NO;
    else
        _isTargetAccountChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (BOOL) isEditControlsChanged {
    
    if(_isDateChanged)
        return YES;
    if(_isSourceAccountChanged)
        return YES;
    if(_isSourceSumChanged)
        return YES;
    if(_isTargetAccountChanged)
        return YES;
    if(_isTargetSumChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
    
    return NO;
}

- (BOOL) isDataReadyForSave {
    if(!_date)
        return NO;
    if(!_sourceAccount)
        return NO;
    if(_sourceSum <= 0)
        return NO;
    if(!_targetAccount)
        return NO;
    if(_targetSum <= 0)
        return NO;
    if([_sourceAccount isEqual:_targetAccount])
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


#pragma mark - Monitoring of controls changed

- (IBAction)textFieldSourceSumEditingChanged:(UITextField *)sender {
    
    self.sourceSum =  [self.textFieldSourceSum.text doubleValue];
    
    if(_initSourceSumValue == self.sourceSum){
        _isSourceSumChanged = NO;
    }
    else{
        _isSourceSumChanged = YES;
    }
    
    [self changeSaveButtonEnable];
}

- (IBAction)textFieldTargetSumEditingChanged:(UITextField *)sender {
    
    self.targetSum =  [self.textFieldTargetSum.text doubleValue];
    
    if(_initTargetSumValue == self.targetSum){
        _isTargetSumChanged = NO;
    }
    else{
        _isTargetSumChanged = YES;
    }
    
    [self changeSaveButtonEnable];
}

- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender {
    
    _comment = self.textFieldComment.text;
    
    if([_initCommentValue isEqualToString:_comment])
        _isCommentChanged = NO;
    else
        _isCommentChanged = YES;
    
    [self changeSaveButtonEnable];
}


#pragma mark - Save and delete actions

- (void)saveButtonPressed {
    
    if(self.isNewTransfer){
        
        YGOperation *transfer = [[YGOperation alloc] initWithType:YGOperationTypeTransfer
                                                       sourceId:_sourceAccount.rowId
                                                       targetId:_targetAccount.rowId
                                                      sourceSum:_sourceSum
                                               sourceCurrencyId:_sourceAccount.currencyId
                                                      targetSum:_targetSum
                                               targetCurrencyId:_targetAccount.currencyId
                                                           date:_date
                                                        comment:_comment];
        
                
        NSInteger operationId = [_om addOperation:transfer];
        
        transfer.rowId = operationId;
        
        [_em recalcSumOfAccount:_sourceAccount forOperation:transfer];
        [_em recalcSumOfAccount:_targetAccount forOperation:transfer];
        
    }
    else{
        
        if(_isDateChanged)
            self.transfer.date = _date;
        if(_isSourceAccountChanged){
            self.transfer.sourceId = _sourceAccount.rowId;
            self.transfer.sourceCurrencyId = _sourceCurrency.rowId;
        }
        if(_isTargetAccountChanged){
            self.transfer.targetId = _targetAccount.rowId;
            self.transfer.targetCurrencyId = _targetCurrency.rowId;
        }
        if(_isSourceSumChanged){
            self.transfer.sourceSum = _sourceSum;
        }
        if(_isTargetSumChanged){
            self.transfer.targetSum = _targetSum;
        }
        if(_isCommentChanged)
            self.transfer.comment = [_comment copy];
        
        [_om updateOperation:[self.transfer copy]];

        [_em recalcSumOfAccount:_sourceAccount forOperation:self.transfer];
        [_em recalcSumOfAccount:_targetAccount forOperation:self.transfer];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    [_om removeOperation:self.transfer];
    
    [_em recalcSumOfAccount:_sourceAccount forOperation:_transfer];
    [_em recalcSumOfAccount:_targetAccount forOperation:_transfer];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([segue.identifier isEqualToString:@"segueFromTransferEditToDateChoice"]){
        
        YGDateChoiceController *vc = segue.destinationViewController;
        
        vc.sourceDate = _date;
        vc.customer = YGDateChoiceСustomerTransfer;
        
    }
    else if([segue.identifier isEqualToString:@"segueFromTransferEditToSourceAccountChoice"]){
        
        YGAccountChoiceController *vc = segue.destinationViewController;
        
        vc.sourceAccount = _sourceAccount;
        vc.customer = YGAccountChoiceCustomerTransferSource;
        
    }
    else if([segue.identifier isEqualToString:@"segueFromTransferEditToTargetAccountChoice"]){
        
        YGAccountChoiceController *vc = segue.destinationViewController;
        
        vc.sourceAccount = _targetAccount;
        vc.customer = YGAccountChoiceCustomerTransferTarget;
    }
}


@end
