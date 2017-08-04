//
//  YGBackupLocalViewController.m
//  Ledger
//
//  Created by Ян on 07/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGBackupLocalViewController.h"
#import "YGDBManager.h"
#import "YGStorageLocal.h"
#import "YGBackup.h"
#import "YGTools.h"
#import "YGConfig.h"
#import <YGFileSystem.h>
#import "YYGLedgerDefine.h"

//static NSString *const kDateTimeFormat = @"yyyy-MM-dd HH:mm:ss Z";

@interface YGBackupLocalViewController (){
    UIActivityIndicatorView *p_indicator;
    BOOL p_isBackupExist;
}

//@property (copy, nonatomic) YGBackup *backup;

@property (weak, nonatomic) IBOutlet UILabel *labelBackupDate;
@property (weak, nonatomic) IBOutlet UILabel *labelBackupLastOperation;
@property (weak, nonatomic) IBOutlet UILabel *labelBackupDBSize;
@property (weak, nonatomic) IBOutlet UILabel *labelWorkDBLastOperation;
@property (weak, nonatomic) IBOutlet UILabel *labelWorkDBSize;

@property (weak, nonatomic) IBOutlet UIButton *buttonBackup;
@property (weak, nonatomic) IBOutlet UIButton *buttonRestore;



- (IBAction)buttonBackupPressed:(UIButton *)sender;
- (IBAction)buttonRestorePressed:(UIButton *)sender;

@end

@implementation YGBackupLocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"LOCAL_BACKUP_FORM_TITLE", @"Title of Local backup form");
    
    [self loadBackupInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadBackupInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadBackupInfo {
    
    // get list of local backups
    YGDBManager *dm = [YGDBManager sharedInstance];
    
    YGStorageLocal *storage = [dm storageByType:YGStorageTypeLocal];
    
    NSArray <YGBackup *> *backups = [storage backups];
    
    YGBackup *backup = nil;
    if([backups count] > 0)
        backup = [backups firstObject];
    
    if(backup){
        
        p_isBackupExist = YES;
        
        if(backup.backupDate)
            self.labelBackupDate.text = [YGTools humanViewShortWithTodayOfDateString:backup.backupDate];
        if(backup.lastOperation)
            self.labelBackupLastOperation.text = [YGTools humanViewShortWithTodayOfDateString:backup.lastOperation];
        
        if(backup.dbSize)
        self.labelBackupDBSize.text = backup.dbSize;
        
        self.buttonRestore.enabled = YES;
    }
    else{
        
        p_isBackupExist = NO;
    }
    
    [self updateUI];
    
    // load info about work db
    NSString *lastOperation = [dm lastOperation];
    
    NSString *workDbFileFullName = [dm databaseFullName];
    
    YGFile *workDbFile = [[YGFile alloc] initWithPathFull:workDbFileFullName];
    
    NSString *workDbFileSize = [YGTools humanViewStringForByteSize:workDbFile.size];

    self.labelWorkDBLastOperation.text = [YGTools humanViewShortWithTodayOfDateString:lastOperation];
    self.labelWorkDBSize.text = workDbFileSize;

}

#pragma mark - Update UI for show/hide backup secion

- (void)updateUI {
    
    if(p_isBackupExist) {
        self.buttonRestore.enabled = YES;
        self.buttonRestore.backgroundColor = [YGTools colorForActionRestore];
    }
    else{
        self.buttonRestore.enabled = NO;
        self.buttonRestore.backgroundColor = [YGTools colorForActionDisable];
    }
    
    [self.tableView reloadData];
}


#pragma mark - Buttons actions

- (IBAction)buttonBackupPressed:(UIButton *)sender {
    
    // start activity indicator
    [self startActivityIndicatorWithColor:[YGTools colorForActionBackup]];
    
    // begin ignoring user actions
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // disable buttonBackup to prevent new user backup action
    self.buttonBackup.enabled = NO;
    self.buttonBackup.backgroundColor = [YGTools colorForActionDisable];
    
    self.buttonRestore.enabled = NO;
    self.buttonRestore.backgroundColor = [YGTools colorForActionDisable];
    
    YGDBManager *dm = [YGDBManager sharedInstance];
    
    YGStorageLocal *storage = [dm storageByType:YGStorageTypeLocal];
    
    [storage backupDb];
    
    // make some delay for prevent new user actions
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // enable buttonBackup
        self.buttonBackup.enabled = YES;
        self.buttonBackup.backgroundColor = [YGTools colorForActionBackup];
        
        self.buttonRestore.enabled = YES;
        self.buttonRestore.backgroundColor = [YGTools colorForActionRestore];
        
        // update UI
        [self loadBackupInfo];
        
        // end ignoring user actions
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        // end animation
        [self stopActivityIndicator];   
    });
}

- (IBAction)buttonRestorePressed:(UIButton *)sender {
    
    // start activity indicator
    [self startActivityIndicatorWithColor:[YGTools colorForActionRestore]];
    
    // begin ignoring user actions
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // disable buttonRestore to prevent new user backup action
    self.buttonRestore.enabled = NO;
    self.buttonRestore.backgroundColor = [YGTools colorForActionDisable];
    
    self.buttonBackup.enabled = NO;
    self.buttonBackup.backgroundColor = [YGTools colorForActionDisable];
    
    YGDBManager *dm = [YGDBManager sharedInstance];
    YGStorageLocal *storage = [dm storageByType:YGStorageTypeLocal];
    
    NSArray <YGBackup *>*backups = [storage backups];
    YGBackup *backup = [backups firstObject];
    
    [storage restoreDb:backup];
    
    // make some delay for prevent new user actions
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // enable buttonRestore
        self.buttonBackup.enabled = YES;
        self.buttonBackup.backgroundColor = [YGTools colorForActionBackup];
        
        self.buttonRestore.enabled = YES;
        self.buttonRestore.backgroundColor = [YGTools colorForActionRestore];
        
        // update UI
        [self loadBackupInfo];
        
        // end ignoring user actions
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        // end animation
        [self stopActivityIndicator];
    });
}


#pragma mark - Data source methods to show/hide action cells

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 1 && !p_isBackupExist) {
        height = 0.0;
    }
    else if(indexPath.section == 2 && indexPath.row == 1 && !p_isBackupExist){
        height = 0.0;
    }
    
    return height;
}

/**
 @warning Set height in 0.0 is not work.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CGFloat height = [super tableView:tableView heightForHeaderInSection:section];
    
    if(section == 1 && !p_isBackupExist)
        height = 1.0;
    
    return height;
}

/**
 @warning Set height in 0.0 is not work.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = [super tableView:tableView heightForHeaderInSection:section];
 
    if(section == 1 && !p_isBackupExist)
        height = 1.0;
 
    return height;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = [super tableView:tableView titleForHeaderInSection:section];
    
    if(section == 1 && !p_isBackupExist)
        title = @"";

    return title;
}


#pragma mark - Start and stop activity indicator

- (void)startActivityIndicatorWithColor:(UIColor *)color {
    
    p_indicator = [[UIActivityIndicatorView alloc]
                   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    p_indicator.color = color;
    p_indicator.hidesWhenStopped = YES;
    
    // this is not work
    //indicator.center = [self.view superview].center;
    
    // but this is a crutch
    CGFloat navigationBarHeight = [self.navigationController navigationBar].frame.size.height;
    
    //tabBarHeight = [self.tabBarController tabBar].frame.size.height;
    //tabBarHeight = [[[super tabBarController] tabBar] frame].size.height;
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    // wtf?
    p_indicator.center = CGPointMake(self.view.bounds.size.width/2.0, (self.view.bounds.size.height - navigationBarHeight)/2.0 + statusBarHeight);
    
    [self.view addSubview:p_indicator];
    
    [p_indicator startAnimating];
}

- (void)stopActivityIndicator {
    
    [p_indicator stopAnimating];
    
    // needed?
    [p_indicator removeFromSuperview];
}


@end
