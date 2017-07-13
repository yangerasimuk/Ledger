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

@interface YGBackupLocalViewController ()

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
    
    self.navigationItem.title = @"Local backup";
    
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
        self.labelBackupDate.text = [YGTools humanViewShortWithTodayOfDateString:backup.backupDate];
        self.labelBackupLastOperation.text = [YGTools humanViewShortWithTodayOfDateString:backup.lastOperation];
        self.labelBackupDBSize.text = backup.dbSize;
        
        self.buttonRestore.enabled = YES;
    }
    else{
        self.labelBackupDate.text = @"No backup";
        self.labelBackupLastOperation.text = @"No backup";
        self.labelBackupDBSize.text = @"0 B";
        
        self.buttonRestore.enabled = NO;
        self.buttonRestore.titleLabel.textColor = [UIColor grayColor];
    }
    
    // load info about work db
    NSString *lastOperation = [dm lastOperation];
    
    NSString *workDbFileFullName = [dm databaseFullName];
    
    YGFile *workDbFile = [[YGFile alloc] initWithPathFull:workDbFileFullName];
    
    NSString *workDbFileSize = [YGTools humanViewStringForByteSize:workDbFile.size];

    self.labelWorkDBLastOperation.text = [YGTools humanViewShortWithTodayOfDateString:lastOperation];
    self.labelWorkDBSize.text = workDbFileSize;

}

#pragma mark - Buttons actions

- (IBAction)buttonBackupPressed:(UIButton *)sender {
    
    // begin ignoring user actions
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // disable buttonBackup to prevent new user backup action
    self.buttonBackup.enabled = NO;
    self.buttonBackup.titleLabel.textColor = [UIColor grayColor];
    UIColor *enabledColor = self.buttonBackup.titleLabel.textColor;
    
    BOOL isButtonRestoreEnable = self.buttonRestore.enabled;
    self.buttonRestore.enabled = NO;
    
    YGDBManager *dm = [YGDBManager sharedInstance];
    
    YGStorageLocal *storage = [dm storageByType:YGStorageTypeLocal];
    
    [storage backupDb];
    
    // make some delay for prevent new user actions
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // enable buttonBackup
        self.buttonBackup.enabled = YES;
        self.buttonBackup.titleLabel.textColor = enabledColor;
        
        if(isButtonRestoreEnable)
            self.buttonRestore.enabled = YES;
        
        // update UI
        [self loadBackupInfo];
        
        // end ignoring user actions
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}

- (IBAction)buttonRestorePressed:(UIButton *)sender {
    
    // begin ignoring user actions
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // disable buttonRestore to prevent new user backup action
    self.buttonRestore.enabled = NO;
    self.buttonRestore.titleLabel.textColor = [UIColor grayColor];
    UIColor *enabledColor = self.buttonBackup.titleLabel.textColor;
    
    BOOL isButtonBackupEnabled = self.buttonBackup.enabled;
    self.buttonBackup.enabled = NO;
    
    YGDBManager *dm = [YGDBManager sharedInstance];
    YGStorageLocal *storage = [dm storageByType:YGStorageTypeLocal];
    
    NSArray <YGBackup *>*backups = [storage backups];
    YGBackup *backup = [backups firstObject];
    
    [storage restoreDb:backup];
    
    // make some delay for prevent new user actions
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // enable buttonRestore
        self.buttonRestore.enabled = YES;
        self.buttonRestore.titleLabel.textColor = enabledColor;
        
        if(isButtonBackupEnabled)
            self.buttonBackup.enabled = YES;
        
        // update UI
        [self loadBackupInfo];
        
        // end ignoring user actions
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
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
