//
//  YYGBackupViewController.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGBackupViewController.h"
#import "YGDropboxLinkViewController.h"
#import "YGLoadView.h"
#import "YGTools.h"
#import "YGDBManager.h"
#import "YGFile.h"
#import "YYGBackuper.h"

@interface YYGBackupViewController() {
    id<YYGStoraging> p_storage;
    YGLoadView *p_loadView;
    BOOL p_isBackupExists;
    NSString *p_backupFileName;
}
@property (weak, nonatomic) IBOutlet UILabel *workDBLastOperationLabel;
@property (weak, nonatomic) IBOutlet UILabel *workDBSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *backupDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *backupLastOperationLabel;
@property (weak, nonatomic) IBOutlet UILabel *backupDBSizeLabel;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsOfController;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOfController;

@property (weak, nonatomic) IBOutlet UIButton *backupButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;

- (IBAction)backupButtonPressed:(UIButton *)sender;
- (IBAction)restoreButtonPressed:(UIButton *)sender;
@end

@implementation YYGBackupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // А здесь могут быть и другие хранилища...
    // Navigation
    self.title = @"Dropbox";
    UIBarButtonItem *dropboxItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACKUP_MENU_ACCOUNT", @"Account") style:UIBarButtonItemStylePlain target:self action:@selector(manageStorage)];
    self.navigationItem.rightBarButtonItem = dropboxItem;
    
    // Get info about current, work db
    [self loadWorkDbInfo];
    
    _storageType = YYGStorageTypeDropbox;
    p_storage = [YYGStorage storageWithType:_storageType];
    p_storage.owner = self;
}

- (void)manageStorage {
    YGDropboxLinkViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YGDropboxLinkViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadWorkDbInfo];
    [p_storage checkBackup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadWorkDbInfo {
    
    YGDBManager *dbManager = [YGDBManager sharedInstance];
    
    NSString *lastOperation = [dbManager lastOperation];
    if(lastOperation)
        self.workDBLastOperationLabel.text = [YGTools humanViewShortWithTodayOfDateString:lastOperation];
    else
        self.workDBLastOperationLabel.text = NSLocalizedString(@"NO_OPERATIONS_LABEL", @"No operation text in Local backup form");
    
    YGFile *workDbFile = [[YGFile alloc] initWithPathFull:[dbManager databaseFullName]];
    self.workDBSizeLabel.text = [YGTools humanViewStringForByteSize:workDbFile.size];
}

#pragma mark - YYGStorageOwner

- (void)notifyIsBackupExists:(BOOL)isBackupExists {
    
    p_isBackupExists = isBackupExists;
    
    if(isBackupExists) {
        NSLog(@"Backup exists");
        
        NSDictionary *info = [p_storage backupInfo];
        
        NSString *lastOperation = [info objectForKey:@"LastOperation"];
        NSString  *backupDbSize = [info objectForKey:@"BackupDBSize"];
        NSString *backupDate = [info objectForKey:@"BackupDate"];
        
        self.backupDateLabel.text = [YGTools humanViewShortWithTodayOfDateString:backupDate];
        self.backupDBSizeLabel.text = backupDbSize;
        
        if(lastOperation && ![lastOperation isEqualToString:@""])
            self.backupLastOperationLabel.text = [YGTools humanViewShortWithTodayOfDateString:lastOperation];
        else
            self.backupLastOperationLabel.text = NSLocalizedString(@"NO_OPERATIONS_LABEL", @"No operation text in Local backup form");
        
    } else
        NSLog(@"Backup does NOT exist");
    
    if ([p_storage isNeedLoadView])
        [self finishLoadView];
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    [self updateUI];
}

- (void)notifyErrorWithTitle:(NSString *)title message:(NSString *)message {
    NSLog(@"Error with title: %@, message: %@\nPlease, try again later.", title, message);
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:(UIAlertControllerStyle)UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:(UIAlertActionStyle)UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self.navigationController popViewControllerAnimated:YES];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)notifyBackupWithErrorMessage:(NSString *)message {
    if ([p_storage isNeedLoadView])
        [self finishLoadView];
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    
    NSString *errorMessage = nil;
    if (message)
        errorMessage = [NSString stringWithFormat:@"%@\nPlease, try again later.", message];
    else
        errorMessage = @"Backup to Dropbox is failed. \nPlease, try again later.";
    
    UIAlertController *errorController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"BACKUP_ERROR_ALERT_TITLE", @"Error") message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [errorController addAction:okAction];
    
    [self presentViewController:errorController animated:YES completion:^{
        //
    }];
}

// TODO: Объединить с предыдущим, можно через третью 
- (void)notifyRestoreWithError:(NSString *)errorMessage {
    if ([p_storage isNeedLoadView])
        [self finishLoadView];

    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    
    NSString *message = nil;
    if (errorMessage)
        message = [NSString stringWithFormat:@"%@\n%@", message, NSLocalizedString(@"BACKUP_TRY_AGAIN_LATER_MESSAGE", @"Please, try again later.")];
    else
        message = NSLocalizedString(@"BACKUP_RESTORE_FROM_BACKUP_FAILED_MESSAGE", @"Restore from backup is failed. \nPlease, try again later.");

    UIAlertController *errorController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"BACKUP_RESTORE_ERROR_ALERT_TITLE", @"Restore error") message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [errorController addAction:okAction];
    
    [self presentViewController:errorController animated:YES completion:^{
        //
    }];
}

- (void)notifyRestoreWithSuccess {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"DatabaseRestoredEvent" object:nil];
    
    if ([p_storage isNeedLoadView])
        [self finishLoadView];

    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    [self loadWorkDbInfo];
}

#pragma mark - YYGBackuperOwner

- (void)notifyBackupDbSuccess {
    NSLog(@"YYGBackupViewController. notifyBackupDbSuccess. Backup of work db complete with success");
    [p_storage backup:p_backupFileName];
}

- (void)notifyBackupDbError:(NSString *)message {
    NSLog(@"YYGBackupViewController. notifyBackupDbError. Error during backup db. Message: %@", message);
    p_backupFileName = nil;
}

#pragma mark - YYGStorageOwner & YYGBackuperOwner

- (void)notifyMessage:(NSString *)message {
    if ([p_storage isNeedLoadView])
        [self startLoadViewWithMessage:message];
}

- (void) updateUI {
    if(p_isBackupExists) {
        self.restoreButton.enabled = YES;
        self.restoreButton.backgroundColor = [YGTools colorForActionRestore];
    } else {
        self.restoreButton.enabled = NO;
        self.restoreButton.backgroundColor = [YGTools colorForActionDisable];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Buttons actions

- (IBAction)restoreButtonPressed:(UIButton *)sender {
    
    UIAlertController *warningController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WARNING_ALERT_CONTROLLER_TITLE", @"Warning") message:NSLocalizedString(@"DB_REPLACEMENT_WHEN_RESTORE_MESSAGE", @"В процессе восстановления текущая база данных будет заменена на архивную.") preferredStyle:UIAlertControllerStyleAlert];
    
    // confirm action
    UIAlertAction *confirmAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"RESTORE_ALERT_ITEM_TITLE", @"Restore")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                                        [p_storage restore];
                                    }];
    [warningController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"CANCEL_ALERT_ITEM_TITLE", @"Cancel")
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    [warningController addAction:cancelAction];
    
    [self presentViewController:warningController animated:YES completion:nil];
}

- (IBAction)backupButtonPressed:(UIButton *)sender {
    
    // Игнорируем пользовательский ввод
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // Снимаю с текущей базы данных слепок
    YYGBackuper *backuper = [[YYGBackuper alloc] init];
    [backuper backupDb];
    
    // Сохраняю имя нового бекапа
    p_backupFileName = backuper.fileName;
    
    [p_storage backup:p_backupFileName];
    
    // всё остальное в методах делегата
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    CGFloat height = 44.0f;
    
    if (indexPath.section == 1 && !p_isBackupExists) {
        height = 0.0;
    }
    else if(indexPath.section == 2 && indexPath.row == 1 && !p_isBackupExists){
        height = 0.0;
    }
        
    return height;
}

/**
 @warning Set height in 0.0 is not work.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CGFloat height = [super tableView:tableView heightForHeaderInSection:section];
    
    if(section == 1 && !p_isBackupExists)
        height = 1.0;
    
    return height;
}

/**
 @warning Set height in 0.0 is not work.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = [super tableView:tableView heightForHeaderInSection:section];
    
    if(section == 1 && !p_isBackupExists)
        height = 1.0;
    
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = [super tableView:tableView titleForHeaderInSection:section];
    
    if(section == 1 && !p_isBackupExists)
        title = @"";
    
    return title;
}

#pragma mark - Utilities

- (void)startLoadViewWithMessage:(NSString *)message {
    if(!p_loadView) {
        p_loadView = [[YGLoadView alloc] initWithHostView:self.view];
        [p_loadView startLoadWithMessage:message];
    } else
        [p_loadView setMessage:message];
}

- (void)finishLoadView {
    if(p_loadView)
        [p_loadView finishLoad];
    p_loadView = nil;
}

@end
