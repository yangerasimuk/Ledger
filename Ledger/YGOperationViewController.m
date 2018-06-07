//
//  YGOperationViewController.m
//  Ledger
//
//  Created by Ян on 12/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationViewController.h"

#import "YGCategoryManager.h"
#import "YGOperationManager.h"
#import "YGOperationSectionManager.h"
#import "YGEntityManager.h"
#import "YGEntity.h"

#import "YGOperationSectionHeader.h"
#import "YGOperationRow.h"

#import "YGExpenseEditController.h"
#import "YGAccountActualEditController.h"
#import "YGIncomeEditController.h"
#import "YGTransferEditController.h"

#import "YGOperationOneRowCell.h"
#import "YGOperationTwoRowCell.h"
#import "YGOperationExpenseCell.h"
#import "YGOperationIncomeCell.h"
#import "YGOperationAccountActualCell.h"
#import "YGOperationTransferCell.h"

#import "YGTools.h"
#import "YGConfig.h"

static NSString *const kOperationOneRowCellId = @"OperationOneRowCellId";
static NSString *const kOperationTwoRowCellId = @"OperationTwoRowCellId";
static NSString *const kOperationExpenseCellId = @"OperationExpenseCellId";
static NSString *const kOperationIncomeCellId = @"OperationIncomeCellId";
static NSString *const kOperationAccountActualCellId = @"OperationAccountActualCellId";
static NSString *const kOperationTransferCellId = @"OperationTransferCellId";

static NSInteger kTimeIntervalForCheckToday = 10;

@interface YGOperationViewController (){
    
    NSDate *p_dateDataLoaded;
    
    NSMutableArray <YGOperationSection *> *p_sections;
    
    NSArray <YGCategory *> *_currencies;
    NSArray <YGCategory *> *_expenseCategories;
    NSArray <YGCategory *> *_incomeSources;
    NSArray <YGCategory *> *_creditorsOrDebtors;
    NSArray <YGCategory *> *_tags;
    NSArray <YGEntity *> *_accounts;
    NSArray <YGEntity *> *_debts;
    
    YGOperationManager *_om;
    YGOperationSectionManager *p_operationSectionManager;
    YGCategoryManager *_cm;
    YGEntityManager *_em;
    
    NSArray <YGOperationSectionHeader *> *p_sectionHeaders;
    
    UIRefreshControl *_refresh;
    
    CGFloat _heightSection;
    CGFloat _heightOneRowCell;
    CGFloat _heightTwoRowCell;
    
    NSTimer *p_timerToday;
    
    BOOL p_isDataSourceChanged;
}

@property (strong, nonatomic) UIView *noDataView;

@end

@implementation YGOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _om = [YGOperationManager sharedInstance];
    p_operationSectionManager = [YGOperationSectionManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
    _em = [YGEntityManager sharedInstance];
    
    p_sections = p_operationSectionManager.sections;
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddBarButton)];
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    self.navigationItem.title = NSLocalizedString(@"OPERATIONS_VIEW_FORM_TITLE", @"Title of Operations form");
    
    // set heights of sections and rows
    _heightOneRowCell = [self heightOneRowCell];
    _heightTwoRowCell = [self heightTwoRowCell];
    
    // cell classes for one and two rows
    [self.tableView registerClass:[YGOperationOneRowCell class] forCellReuseIdentifier:kOperationOneRowCellId];
    [self.tableView registerClass:[YGOperationTwoRowCell class] forCellReuseIdentifier:kOperationTwoRowCellId];
    [self.tableView registerClass:[YGOperationExpenseCell class] forCellReuseIdentifier:kOperationExpenseCellId];
    [self.tableView registerClass:[YGOperationIncomeCell class] forCellReuseIdentifier:kOperationIncomeCellId];
    [self.tableView registerClass:[YGOperationAccountActualCell class] forCellReuseIdentifier:kOperationAccountActualCellId];
    [self.tableView registerClass:[YGOperationTransferCell class] forCellReuseIdentifier:kOperationTransferCellId];
    
    [self addAsObserver];
    
    // fill table from cache - p_sections;
    p_isDataSourceChanged = YES;
    [self reloadDataFromCache];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    p_timerToday = [NSTimer timerWithTimeInterval:kTimeIntervalForCheckToday
                                           target:self
                                         selector:@selector(checkForToday)
                                         userInfo:nil
                                          repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:p_timerToday forMode:NSDefaultRunLoopMode];
    
    if (p_isDataSourceChanged) {
        [self reloadDataFromCache];
    }
}

/**
 При уходе контроллера дезактивируем таймер.
 */
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [p_timerToday invalidate];
    p_timerToday = nil;
}

/**
 При переходе программы в активное состояние, проверяем совпадает ли установленная при загрузке
 контроллера дата с текущей, если нет получается наступил следующий день и необходимо заново
 сгенерировать секции.
 */
- (void)applicationDidBecomeActiveHandler {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    if(![calendar isDateInToday:p_dateDataLoaded])
        [self reloadDataFromCache];
}

/**
 Dealloc. Удаляем все подписки на извещения.
 */
-(void)dealloc {
    
    // remove self as observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) checkForToday {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    if(![calendar isDateInToday:p_dateDataLoaded])
        [self reloadDataFromCache];
}

- (void) setDataSourceUpdated {
    p_isDataSourceChanged = YES;
}

- (void)reloadDataFromCache {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // для сравнения с текущей датой при выходе из background/suspend
        p_dateDataLoaded = [NSDate date];
        
        if(!p_sections || [p_sections count] == 0){
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            //self.tableView.hidden = YES;
            self.tableView.userInteractionEnabled = NO;
            [self showNoDataView];
        } else{
            [self hideNoDataView];
            self.tableView.userInteractionEnabled = YES;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            
            NSMutableArray <YGOperationSectionHeader *> *headers = [[NSMutableArray alloc] init];
            [p_sections enumerateObjectsUsingBlock:^(YGOperationSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                YGOperationSectionHeader *header = [[YGOperationSectionHeader alloc] initWithSection:obj];
                [headers addObject:header];
            }];
            p_sectionHeaders = [headers copy];
            
            [self.tableView reloadData];
        }
        
        p_isDataSourceChanged = NO;
    });
}

//- (void)pullRefreshSwipe:(UIRefreshControl *)refresh {
//
//    [refresh beginRefreshing];
//    [refresh endRefreshing];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self addOperation];
//    });
//}

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
        
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO_OPERATIONS_LABEL", @"No operations in Operations form.") attributes:attributes];
        
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


#pragma mark - Actions

- (void)actionAddBarButton {
    [self addOperation];
}

- (void)addOperation {
    /*
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"OPERATION_CHOICE_ALERT_SHEET_TITLE", @"Usually: Choose operation") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
     */
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *addExpenseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"EXPENSE_ALERT_ITEM_TITLE", @"Expense") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddExpense];
    }];
    [controller addAction:addExpenseAction];
    
    UIAlertAction *addIncomeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"INCOME_ALERT_ITEM_TITLE", @"Income") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddIncome];
    }];
    [controller addAction:addIncomeAction];
    
    UIAlertAction *addTransferAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"TRANSFER_ALERT_ITEM_TITLE", @"Transfer") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddTransfer];
    }];
    [controller addAction:addTransferAction];
    
    UIAlertAction *addAccountActualAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"BALANCE_ALERT_ITEM_TITLE", @"Balance") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self actionAddAccountActual];
    }];
    [controller addAction:addAccountActualAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL_ALERT_ITEM_TITLE", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:cancelAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)updateUI {
    //YGConfig *config = [YGTools config];
    
    /*
    // Hide decimal fraction
    _isHideDecimalFraction = YES;
    if([[config valueForKey:@"HideDecimalFraction"] isEqualToString:@"NO"])
        _isHideDecimalFraction = NO;
     */
    
    // Pull refresh add new element
//    _isPullRefreshToAddElement = NO;
//    if([[config valueForKey:@"PullRefreshToAddElement"] isEqualToString:@"Y"]){
//        _isPullRefreshToAddElement = YES;
//        
//        _refresh = [[UIRefreshControl alloc] init];
//        [_refresh addTarget:self action:@selector(pullRefreshSwipe:) forControlEvents:UIControlEventValueChanged];
//        
//        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:@"New operation" attributes:nil];
//        _refresh.attributedTitle = attr;
//        
//        self.refreshControl = _refresh;
//    }
//    else{
//        _refresh = nil;
//        self.refreshControl = nil;
//    }
    
    
}


#pragma mark - Add concrete action

- (void)actionAddExpense {
    
    if(![_em isExistActiveEntityOfType:YGEntityTypeAccount]
       || ![_cm isExistActiveCategoryOfType:YGCategoryTypeExpense]){
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ATTENTION_ALERT_CONTROLLER_TITLE", @"Attention title of alert controller") message:NSLocalizedString(@"TERMS_FOR_ADD_OPERATION_EXPENSE_MESSAGE", @"Terms for adding operation Expense") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:okAction];

        [self presentViewController:controller animated:YES completion:nil];
    }
    else{
        
        YGExpenseEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGExpenseEditScene"];
        
        vc.isNewExpense = YES;
        vc.expense = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionAddIncome {
    
    if(![_em isExistActiveEntityOfType:YGEntityTypeAccount]
       || ![_cm isExistActiveCategoryOfType:YGCategoryTypeIncome]){
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ATTENTION_ALERT_CONTROLLER_TITLE", @"Attention title of alert controller") message:NSLocalizedString(@"TERMS_FOR_ADD_OPERATION_INCOME_MESSAGE", @"Terms for adding operation Income") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:okAction];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else{
        
        YGIncomeEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGIncomeEditScene"];
        
        vc.isNewIncome = YES;
        vc.income = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)actionAddAccountActual {

    if(![_em isExistActiveEntityOfType:YGEntityTypeAccount]){
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ATTENTION_ALERT_CONTROLLER_TITLE", @"Attention title of alert controller") message:NSLocalizedString(@"TERMS_FOR_ADD_OPERATION_ACCOUNT_ACTUAL_MESSAGE", @"Terms for adding operation Account actual") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:okAction];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else{
        
        YGAccountActualEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGAccountActualEditScene"];
        
        vc.isNewAccountAcutal = YES;
        vc.accountActual = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)actionAddTransfer {
    
    if([_em countOfActiveEntitiesOfType:YGEntityTypeAccount] < 2){
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ATTENTION_ALERT_CONTROLLER_TITLE", @"Attention title of alert controller") message:NSLocalizedString(@"TERMS_FOR_ADD_OPERATION_TRANSFER_MESSAGE", @"Terms for adding operation Transfer") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:okAction];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else{
        
        YGTransferEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGTransferEditScene"];
        
        vc.isNewTransfer = YES;
        vc.transfer = nil;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGOperationRow *operationRow = p_sections[indexPath.section].operationRows[indexPath.row];

    if(operationRow.operation.type == YGOperationTypeExpense){
        
        YGExpenseEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGExpenseEditScene"];
        
        vc.isNewExpense = NO;
        vc.expense = [operationRow.operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operationRow.operation.type == YGOperationTypeAccountActual){
        
        YGAccountActualEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGAccountActualEditScene"];
        
        vc.isNewAccountAcutal = NO;
        vc.accountActual = [operationRow.operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if(operationRow.operation.type == YGOperationTypeIncome){
        
        YGIncomeEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGIncomeEditScene"];
        
        vc.isNewIncome = NO;
        vc.income = [operationRow.operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(operationRow.operation.type == YGOperationTypeTransfer){
        
        YGTransferEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGTransferEditScene"];
        
        vc.isNewTransfer = NO;
        vc.transfer = [operationRow.operation copy];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //return p_sections[section].headerView;
    return p_sectionHeaders[section];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [YGOperationSectionHeader heightSectionHeader];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGOperationType type = p_sections[indexPath.section].operationRows[indexPath.row].operation.type;
    
    if(type == YGOperationTypeTransfer){
        return _heightTwoRowCell; // 76;
    }
    else{
        return _heightOneRowCell; // 44;
    }
}


#pragma mark - UITableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [p_sections count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [p_sections[section].operationRows count];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    YGOperationRow *operationRow = p_sections[indexPath.section].operationRows[indexPath.row];
    
    if(operationRow.operation.type == YGOperationTypeExpense) {
        
        YGOperationExpenseCell *cellExpense = (YGOperationExpenseCell *)cell;
        
        cellExpense.leftText = operationRow.target;
        
        cellExpense.rightText = operationRow.sourceSum;
    }
    else if(operationRow.operation.type == YGOperationTypeAccountActual){
        
        YGOperationAccountActualCell *cellBalance = (YGOperationAccountActualCell *)cell;
        
        cellBalance.leftText = operationRow.target;
        
        cellBalance.rightText = operationRow.targetSum;
    }
    else if(operationRow.operation.type == YGOperationTypeIncome){
        
        YGOperationIncomeCell *cellIncome = (YGOperationIncomeCell *)cell;

        cellIncome.leftText = operationRow.source;
        
        cellIncome.rightText = operationRow.targetSum;
    }
    else if(operationRow.operation.type == YGOperationTypeTransfer){

        YGOperationTransferCell *cellTransfer = (YGOperationTransferCell *)cell;

        cellTransfer.firstRowText = operationRow.source;
        cellTransfer.firstRowDetailText = operationRow.sourceSum;
        
        cellTransfer.secondRowText = operationRow.target;
        cellTransfer.secondRowDetailText = operationRow.targetSum;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGOperationRow *operationRow = p_sections[indexPath.section].operationRows[indexPath.row];
    
    if(operationRow.operation.type == YGOperationTypeExpense){
        
        YGOperationExpenseCell *cell = [tableView dequeueReusableCellWithIdentifier:kOperationExpenseCellId];
        if (cell == nil) {
            
            cell = [[YGOperationExpenseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kOperationExpenseCellId];
        }
        return cell;
    }
    else if(operationRow.operation.type == YGOperationTypeAccountActual){
        
        YGOperationAccountActualCell *cell = [tableView dequeueReusableCellWithIdentifier:kOperationAccountActualCellId];
        if (cell == nil) {
            cell = [[YGOperationAccountActualCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:kOperationAccountActualCellId];
        }
        return cell;
    }
    else if(operationRow.operation.type == YGOperationTypeIncome){
        
        YGOperationIncomeCell *cell = [tableView dequeueReusableCellWithIdentifier:kOperationIncomeCellId];
        if (cell == nil) {
            cell = [[YGOperationIncomeCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:kOperationIncomeCellId];
        }
        return cell;
    }
    else if(operationRow.operation.type == YGOperationTypeTransfer){
        
        YGOperationTransferCell *cell = [tableView dequeueReusableCellWithIdentifier:kOperationTransferCellId];
        if (cell == nil) {
            cell = [[YGOperationTransferCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:kOperationTransferCellId];
        }
        return cell;
    }
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Helper methods

- (CGFloat)heightOneRowCell {
    
    static CGFloat heightOneRowCell = 0.f;
    
    if(heightOneRowCell == 0){
        
        NSInteger width = [YGTools deviceScreenWidth];
        
        switch(width){
            case 320:
                heightOneRowCell = 44.f;
                break;
            case 375:
                heightOneRowCell = 48.f;
                break;
            case 414:
                heightOneRowCell = 52.f;
                break;
            default:
                heightOneRowCell = 48.f;
        }
    }
    return heightOneRowCell;
}

- (CGFloat)heightTwoRowCell {
    
    static CGFloat heightTwoRowCell = 0.f;
    
    if(heightTwoRowCell == 0){
        
        NSInteger width = [YGTools deviceScreenWidth];
        
        switch(width){
            case 320:
                heightTwoRowCell = 80.f;
                break;
            case 375:
                heightTwoRowCell = 88.f;
                break;
            case 414:
                heightTwoRowCell = 96.f;
                break;
            default:
                heightTwoRowCell = 76.f;
        }
    }
    return heightTwoRowCell;
}

- (void)addAsObserver {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(setDataSourceUpdated)
                   name:@"OperationManagerCacheUpdateEvent"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(setDataSourceUpdated)
                   name:@"EntityManagerEntityWithOperationsUpdateEvent"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(setDataSourceUpdated)
                   name:@"CategoryManagerCategoryWithObjectsUpdateEvent"
                 object:nil];
    
    [center addObserver:self
               selector:@selector(setDataSourceUpdated)
                   name:@"HideDecimalFractionInListsChangedEvent"
                 object:nil];
    
    // Выход из 9i/suspend'a
    [center addObserver:self
               selector:@selector(applicationDidBecomeActiveHandler)
                   name:@"UIApplicationDidBecomeActiveNotification" object:nil];
}

- (void)addPullRefresh {
    UIRefreshControl *pullRefresh = [[UIRefreshControl alloc] init];
    [pullRefresh addTarget:self action:@selector(pullRefreshReloadTable:) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = pullRefresh;
}

/**
 Pull-Refresh отключен - при жесте пальцем вниз происходит рывок таблицы, когда срабатывает событие.
 Получается таблица как бы вырывается из под пальца - неприятно.
 Поведение это системное, т.е. так себя ведет refreshControl когда просто включено обновление в storyboard.
 
 Reload table data when user pull table down.
 In some case there is sqlite db lock.

 @param sender tableView?
 */
- (void)pullRefreshReloadTable:(id)sender {
    @try {
        self.view.userInteractionEnabled = NO;
        self.navigationController.view.userInteractionEnabled = NO;
        
        __weak YGOperationViewController *weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf) {
                YGOperationViewController *strongSelf = weakSelf;
                
                self.tableView.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"OPERATIONS_VIEW_FORM_PULL_REFRESH_RELOAD_TITLE", @"Title when pull refresh reload table")];
                [strongSelf.tableView.refreshControl beginRefreshing];
                
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                    [p_operationSectionManager makeSections];
                    p_sections = p_operationSectionManager.sections;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf reloadDataFromCache];
                        [strongSelf.tableView.refreshControl endRefreshing];
                        strongSelf.view.userInteractionEnabled = YES;
                        strongSelf.navigationController.view.userInteractionEnabled = YES;
                    });
                });
            } // if (weakSelf)
        });
    }
    @catch (NSException *ex) {
        NSLog(@"Exception in YGOperationViewController.pullRefreshReloadTable. Description: %@", [ex description]);
    }
}

@end
