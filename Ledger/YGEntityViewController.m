//
//  YGEntityViewController.m
//  Ledger
//
//  Created by Ян on 15/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGEntityViewController.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGAccountEditController.h"
//#import "YGOperationCell.h"

#import "YGTools.h"
#import "YGConfig.h"

static NSString *const kEntityCellId = @"EntityCellId";

@interface YGEntityViewController (){
    
    YGEntityManager *_em;
    YGCategoryManager *_cm;
    
    BOOL _isHideDecimalFraction;
}

@property (strong, nonatomic) NSArray <YGEntity *> *entities;

@end

@implementation YGEntityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _em = [YGEntityManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
        
    if(self.tabBarController.selectedIndex == 1){
        self.type = YGEntityTypeAccount;
    }
    
    //[self.tableView registerClass:[YGOperationCell class] forCellReuseIdentifier:kEntityCellId];
    
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kEntityCellId];
    
    //self.entities = [_em listEntitiesByType:self.type];
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type = %ld", _type];
    
    //self.entities = [[_em.entities valueForKey:NSStringFromEntityType(_type)] filteredArrayUsingPredicate:typePredicate];
    
    self.entities = [_em.entities valueForKey:NSStringFromEntityType(_type)];
    
    [self updateUI];
    
    [self.tableView reloadData];
    
    // add button on nav bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddButtonPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.navigationItem.title = @"Accounts";
    

    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    //self.entities = [_em listEntitiesByType:self.type];
/*
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type = %ld", _type];
    self.entities = [_em.entities filteredArrayUsingPredicate:typePredicate];

  */  
    [self updateUI];
    
    [self.tableView reloadData];
}

- (void)updateUI {
    YGConfig *config = [YGTools config];
    
    if([[config valueForKey:@"HideDecimalFraction"] isEqualToString:@"Y"])
        _isHideDecimalFraction = YES;
    else
        _isHideDecimalFraction = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)actionAddButtonPressed {
    
    if(self.type == YGEntityTypeAccount){
        
        YGAccountEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountEditScene"];
        
        vc.isNewAccount = YES;
        vc.account = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.type == YGEntityTypeAccount){
        
        YGAccountEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountEditScene"];
        
        vc.isNewAccount = NO;
        vc.account = self.entities[indexPath.row];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.entities count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *formatForNumbers;
    if(_isHideDecimalFraction)
        formatForNumbers = @"%.f %@";
    else
        formatForNumbers = @"%.2f %@";
    
    /*

    YGOperationCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             kEntityCellId];
    if (cell == nil) {
        cell = [[YGOperationCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:kEntityCellId];
    }
    
    YGEntity *entity = self.entities[indexPath.row];
    
    YGCategory *currency = [_cm categoryById:entity.currencyId];
    
    cell.descriptionText = entity.name;
    cell.sumText = [NSString stringWithFormat:formatForNumbers, entity.sum, [currency shorterName]];
    
    if(!entity.active)
        cell.cellTextColor = [UIColor grayColor];
    else{
        if(entity.sum >= 0)
            cell.cellTextColor = [UIColor blackColor];
        else
            cell.cellTextColor = [UIColor redColor];
    }
    
    return cell;
     */
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEntityCellId];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kEntityCellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    YGEntity *entity = self.entities[indexPath.row];
    
    //YGCategory *currency = [_cm categoryById:entity.currencyId];
    YGCategory *currency = [_cm categoryById:entity.currencyId type:YGCategoryTypeCurrency];
    
    NSDictionary *nameAttributes = nil;
    if(!entity.active){
        nameAttributes = @{
                           NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                           NSForegroundColorAttributeName:[UIColor grayColor],
                           };
    }
    else{
        nameAttributes = @{
                           NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                           };
    }
    
    NSAttributedString *nameAttributed = [[NSAttributedString alloc] initWithString:entity.name attributes:nameAttributes];
    
    cell.textLabel.attributedText = nameAttributed;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    NSDictionary *sumAttributes =  @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                                     };
    NSAttributedString *sumAttributed = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:formatForNumbers, entity.sum, [currency shorterName]] attributes:sumAttributes];
    cell.detailTextLabel.attributedText = sumAttributed;
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    
    return cell;
}


@end
