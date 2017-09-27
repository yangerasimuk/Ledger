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
#import "YGTools.h"
#import "YGConfig.h"

static NSInteger const kWidthOfMarginIndents = 65;
static NSString *const kEntityCellId = @"EntityCellId";

@interface YGEntityViewController (){
    
    YGEntityManager *_em;
    YGCategoryManager *_cm;
    
    BOOL p_hideDecimalFraction;
}

// список Сущностей
@property (strong, nonatomic) NSArray <YGEntity *> *entities;
// вьюха для случая отсутствия данных
@property (strong, nonatomic) UIView *noDataView;

@end

@implementation YGEntityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _em = [YGEntityManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
        
    if(self.tabBarController.selectedIndex == 1){
        self.type = YGEntityTypeAccount;
    }
    
    YGConfig *config = [YGTools config];
    
    p_hideDecimalFraction = [[config valueForKey:@"HideDecimalFractionInLists"] boolValue];
    
    // add button on nav bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddButtonPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.navigationItem.title = NSLocalizedString(@"ACCOUNTS_VIEW_FORM_TITLE", @"Title of Accounts form");
    

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(reloadDataFromCache)
                   name:@"EntityManagerCacheUpdateEvent"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(reloadDataAfterDecimalFractionChange)
                   name:@"HideDecimalFractionInListsChangedEvent"
                 object:nil];
    
    [self reloadDataFromCache];
}

- (void)reloadDataFromCache {
    
    self.entities = [_em.entities valueForKey:NSStringFromEntityType(_type)];
    
    if(!_entities || [_entities count] == 0){
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.userInteractionEnabled = NO;
        [self showNoDataView];
    }
    else{
        
        [self hideNoDataView];
        self.tableView.userInteractionEnabled = YES;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                
        [self.tableView reloadData];
    }
}

- (void) reloadDataAfterDecimalFractionChange {
    
    YGConfig *config = [YGTools config];
    
    p_hideDecimalFraction = [[config valueForKey:@"HideDecimalFractionInLists"] boolValue];
    
    [self reloadDataFromCache];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    //self.entities = [_em listEntitiesByType:self.type];
/*
    NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"type = %ld", _type];
    self.entities = [_em.entities filteredArrayUsingPredicate:typePredicate];

  */
    /*
    [self updateUI];
    
    [self.tableView reloadData];
     */
}


/**
 Dealloc of object. Remove all notifications.
 */
-(void)dealloc {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma mark - Show/hide No operation view

- (void)showNoDataView {
    
    if(!self.noDataView){
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        
        self.noDataView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        self.noDataView.backgroundColor = [UIColor colorWithRed:0.9647 green:0.9647 blue:0.9647 alpha:1.f];
        
        CGFloat navigationBarHeight = [self.navigationController navigationBar].frame.size.height;
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        
        CGFloat widthNote = self.view.bounds.size.width/2;
        CGFloat heightNote = 44.f;
        
        CGFloat xNote = self.view.bounds.size.width/2 - widthNote/2;
        CGFloat yNote;
        
        if(screenSize.height != self.view.bounds.size.height)
            yNote = self.view.bounds.size.height/2 - heightNote/2 - statusBarHeight + 7;
        else
            yNote = self.view.bounds.size.height/2 - heightNote/2 - navigationBarHeight -  statusBarHeight;
        
        UILabel *labelNote = [[UILabel alloc] initWithFrame:CGRectMake(xNote, yNote, widthNote, heightNote)];
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize] + 2], NSForegroundColorAttributeName:[UIColor grayColor]};
        
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO_ACCOUNTS_LABEL", @"No accounts in Accounts form.") attributes:attributes];
        
        labelNote.attributedText = attributed;
        labelNote.textAlignment = NSTextAlignmentCenter;
        
        [self.noDataView addSubview:labelNote];
        
        [self.view addSubview:self.noDataView];
        [self.view bringSubviewToFront:self.noDataView];
    }
}


- (void)hideNoDataView {
    
    if(self.noDataView){
        [self.noDataView removeFromSuperview];
        self.noDataView = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)actionAddButtonPressed {
    
    if(self.type == YGEntityTypeAccount){
        
        YGAccountEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountEditScene"];
        
        vc.account = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.type == YGEntityTypeAccount){
        
        YGAccountEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountEditScene"];
        
        vc.account = [self.entities[indexPath.row] copy];
        
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

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEntityCellId];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kEntityCellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    YGEntity *entity = self.entities[indexPath.row];
    
    YGCategory *currency = [_cm categoryById:entity.currencyId type:YGCategoryTypeCurrency];
    
    // define sum and currency symbol first
    NSString *stringSumAndCurrency = [NSString stringWithFormat:@"%@ %@", [YGTools stringCurrencyFromDouble:entity.sum hideDecimalFraction:p_hideDecimalFraction], [currency shorterName]];
    
    NSDictionary *sumAttributes =  @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                                     };
    NSAttributedString *sumAttributed = [[NSAttributedString alloc] initWithString:stringSumAndCurrency attributes:sumAttributes];
    cell.detailTextLabel.attributedText = sumAttributed;
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    
    // define name of account, trancate if needed
    NSString *stringName = [entity.name copy];
    
    NSInteger widthSum = [YGTools widthForContentString:stringSumAndCurrency];
    NSInteger widthName = [YGTools widthForContentString:stringName];
    
    if(widthName > (self.view.bounds.size.width - widthSum - kWidthOfMarginIndents))
        stringName = [YGTools stringForContentString:stringName holdInWidth:(self.view.bounds.size.width - widthSum - kWidthOfMarginIndents)];
    
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
    
    NSAttributedString *nameAttributed = [[NSAttributedString alloc] initWithString:stringName attributes:nameAttributes];
    
    cell.textLabel.attributedText = nameAttributed;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return cell;
}

@end
