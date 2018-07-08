//
//  YYGStorage.h
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YYGStorageType) {
    YYGStorageTypeLocal,
    YYGStorageTypeDropbox
};

@protocol YYGStorageOwning
- (void)notifyIsBackupExists:(BOOL)isBackupExists;
- (void)notifyErrorWithTitle:(NSString *)title message:(NSString *)message;
- (void)notifyDownloadedInfoFile:(NSString *)fileName;
- (void)notifyMessage:(NSString *)message;
- (void)notifyBackupWithSuccess;
- (void)notifyBackupWithErrorMessage:(NSString *)message;

- (void)notifyRestoreWithSuccess;
- (void)notifyRestoreWithError:(NSString *)errorMessage;

@end

@protocol YYGStoraging
@property (weak, nonatomic) id<YYGStorageOwning> owner;
- (BOOL)isNeedLoadView;
- (void)checkBackup;
- (NSDictionary *)backupInfo;
- (void)backup:(NSString *)fileName;
- (void)restore;
@end

@interface YYGStorage: NSObject

@property (assign, nonatomic) YYGStorageType type;
@property (weak, nonatomic) id<YYGStorageOwning> owner;

+ (id<YYGStoraging>)storageWithType:(YYGStorageType) type;

@end
