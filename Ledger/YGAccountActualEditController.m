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

@interface YGAccountActualEditController (){
    NSDate *_date;
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

@property (weak, nonatomic) IBOutlet UITextField *textFieldSourceSum;


@property (weak, nonatomic) IBOutlet UILabel *labelSourceCurrency;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTargetSum;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetCurrency;
@property (weak, nonatomic) IBOutlet UITextField *textFieldComment;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;

- (IBAction)textFieldTargetSumEditingChanged:(UITextField *)sender;
- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellDate;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAccount;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellCurrentSum;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellActualSum;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellComment;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;

@end

@implementation YGAccountActualEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _om = [YGOperationManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
    _em = [YGEntityManager sharedInstance];
    
    if(self.isNewAccountAcutal){
        // set date
        _date = [NSDate date];
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_date];
        
        // set account if one sets as default
        _account = [_em entityAttachedForType:YGEntityTypeAccount];
        if(!_account)
            _account = [_em entityOnTopForType:YGEntityTypeAccount];
        if(_account){
            
            YGCategory *currency = [_cm categoryById:_account.currencyId];
            _currency = currency;
            if(currency.symbol || currency.shortName){
                self.labelAccount.text = [NSString stringWithFormat:@"%@ (%@)", _account.name, [currency shorterName]];
                self.textFieldTargetSum.placeholder = [currency shorterName];
            }
            else{
                self.labelAccount.text = _account.name;
            }
        }
        else{
            self.labelAccount.text = @"No account choice";
        }
        
        // focus on sum
        [self.textFieldTargetSum becomeFirstResponder];
        
        // button save
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
        
        self.navigationItem.rightBarButtonItem = saveButton;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        // button delete disable
        self.buttonDelete.enabled = NO;
        
    }
    else{
        
        // set date
        _date = self.accountActual.date;
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:_date];
        self.cellDate.accessoryType = UITableViewCellAccessoryNone;
        self.cellDate.userInteractionEnabled = NO;
        
        // set account
        _account = [_em entityById:self.accountActual.sourceId];
        self.labelAccount.text = _account.name;
        self.cellAccount.accessoryType = UITableViewCellAccessoryNone;
        self.cellAccount.userInteractionEnabled = NO;
        
        if(_account){
            
            YGCategory *currency = [_cm categoryById:_account.currencyId];
            _currency = currency;
            if(currency.symbol || currency.shortName){
                self.labelAccount.text = [NSString stringWithFormat:@"%@ (%@)", _account.name, [currency shorterName]];
                self.textFieldTargetSum.placeholder = [currency shorterName];
            }
            else{
                self.labelAccount.text = _account.name;
            }
        }
        
        // set currency
        _currency = [_cm categoryById:self.accountActual.sourceCurrencyId];
        
        if(_currency.symbol || _currency.shortName){
            self.labelAccount.text = [NSString stringWithFormat:@"%@ (%@)", _account.name, [_currency shorterName]];
        }
        else{
            self.labelAccount.text = _account.name;
        }
        
        // set sum
        _sourceSum = self.accountActual.sourceSum;
        self.textFieldSourceSum.text = [NSString stringWithFormat:@"%.2f", self.accountActual.sourceSum];
        //self.labelSourceSum.text = [NSString stringWithFormat:@"%.2f", self.accountActual.sourceSum];
        self.textFieldTargetSum.text = [NSString stringWithFormat:@"%.2f", self.accountActual.targetSum];
        self.cellCurrentSum.accessoryType = UITableViewCellAccessoryNone;
        self.cellCurrentSum.userInteractionEnabled = NO;
        self.cellActualSum.accessoryType = UITableViewCellAccessoryNone;
        self.cellActualSum.userInteractionEnabled = NO;
    }
    
    // title
    self.navigationItem.title = @"Balance";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Come back from account choice controller

- (IBAction)unwindFromAccountChoiceToAccountActualEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _account = vc.targetAccount;
    self.labelAccount.text = _account.name;
    
    _currency = [_cm categoryById:_account.currencyId];
    self.labelSourceCurrency.text = [_currency shorterName];
    self.labelTargetCurrency.text = [_currency shorterName];
    
}


#pragma mark - Monitoring of controls changed

- (IBAction)textFieldTargetSumEditingChanged:(UITextField *)sender {
    double sum = [self.textFieldTargetSum.text doubleValue];
    if(self.isNewAccountAcutal && sum > 0){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (IBAction)textFieldCommentEditingChanged:(UITextField *)sender {

}

#pragma mark - Save and delete actions

- (void)saveButtonPressed {
    
    double sourceSum = _account.sum;
    double targetSum = [self.textFieldTargetSum.text doubleValue];

    YGOperation *accountActual = [[YGOperation alloc] initWithType:YGOperationTypeAccountActual sourceId:_account.rowId targetId:_account.rowId sourceSum:sourceSum sourceCurrencyId:_account.currencyId targetSum:targetSum targetCurrencyId:_account.currencyId date:[NSDate date] comment:self.textFieldComment.text];
    
    [_om addOperation:accountActual];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    [_om removeOperation:self.accountActual];
    
    [_em recalcSumOfAccount:_account forOperation:_accountActual];
    
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

@end
