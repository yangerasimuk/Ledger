//
//  YYGStorageDropbox.m
//  Ledger
//
//  Created by Ян on 25.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGStorageDropbox.h"
#import "YGTools.h"
#import "YYGDBTester.h"
#import "YYGLedgerDefine.h"
#import "YYGDBTestDbOpen.h"
#import "YYGDBTestDbFormat.h"
#import "YYGDBTestDbVersion.h"

#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

typedef NS_ENUM(NSInteger, YYGDownloadTaskType) {
    YYGDownloadTaskTypeInfo,
    YYGDownloadTaskTypeRestore
};

@interface YYGStorageDropbox() {
    NSString *p_localFileFullName;
    NSString *p_remoteFileName;
    NSMutableArray *p_remoteFileNames;
    NSDictionary *p_backupInfo;
}
@end

@implementation YYGStorageDropbox

- (instancetype)init{
    self = [super init];
    if(self){
        p_localFileFullName = nil;
        p_remoteFileName = nil;
        p_remoteFileNames = [[NSMutableArray alloc] init];
        p_backupInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - YYGStoriging

- (BOOL)isNeedLoadView {
    return YES;
}

#pragma mark - Check current backup in Dropbox

- (void)checkBackup {
    
    [self.owner notifyMessage:NSLocalizedString(@"DROPBOX_DOWNLOAD_BACKUP_INFO_MESSAGE", @"Download backup info...")];
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSString *searchPath = @"";
    
    // list folder metadata contents (folder will be root "/" Dropbox folder if app has permission
    // "Full Dropbox" or "/Apps/<APP_NAME>/" if app has permission "App Folder").
    [[client.filesRoutes listFolder:searchPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
         
         if (result) {
             
             BOOL isBackupFolderExists = NO;
             for(DBFILESMetadata *meta in result.entries) {
                 if([meta.name isEqualToString:@"Backup"])
                     isBackupFolderExists = YES;
             }
             
             if (!isBackupFolderExists){
                 [self createBackupFolder];
             } else {
                 [self downloadInfoFile];
             }
         } else {
             NSString *title = @"";
             NSString *message = @"";
             NSString *userMessage = @"";
             if (routeError) {
                 // Route-specific request error
                 title = @"Route-specific error";
                 if ([routeError isPath]) {
                     message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                     userMessage = [message copy];
                 }
             } else {
                 // Generic request error
                 title = @"Generic request error";
                 if ([error isInternalServerError]) {
                     DBRequestInternalServerError *internalServerError = [error asInternalServerError];
                     message = [NSString stringWithFormat:@"%@", internalServerError];
                 } else if ([error isBadInputError]) {
                     DBRequestBadInputError *badInputError = [error asBadInputError];
                     message = [NSString stringWithFormat:@"%@", badInputError];
                 } else if ([error isAuthError]) {
                     DBRequestAuthError *authError = [error asAuthError];
                     message = [NSString stringWithFormat:@"%@", authError];
                 } else if ([error isRateLimitError]) {
                     DBRequestRateLimitError *rateLimitError = [error asRateLimitError];
                     message = [NSString stringWithFormat:@"%@", rateLimitError];
                 } else if ([error isHttpError]) {
                     DBRequestHttpError *genericHttpError = [error asHttpError];
                     message = [NSString stringWithFormat:@"%@", genericHttpError];
                 } else if ([error isClientError]) {
                     DBRequestClientError *genericLocalError = [error asClientError];
                     message = [NSString stringWithFormat:@"%@", genericLocalError];
                 }
                 
                 NSError *nsError = [error nsError];
                 if(nsError){
                     userMessage = [nsError localizedDescription];
                 }
             }
             [self.owner notifyErrorWithTitle:title message:userMessage];
         }
     }];
}

- (void)createBackupFolder {
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    [[client.filesRoutes createFolderV2:@"/Backup"] setResponseBlock:^(DBFILESCreateFolderResult * _Nullable result, DBFILESCreateFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        
        if (result){
            [self.owner notifyIsBackupExists:NO];
        } else {
            NSString *title = @"";
            NSString *message = @"";
            NSString *userMessage = @"";
            if (routeError) {
                // Route-specific request error
                title = @"Route-specific error";
                if ([routeError isPath]) {
                    message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                    userMessage = [message copy];
                }
            } else {
                // Generic request error
                title = @"Generic request error";
                if ([networkError isInternalServerError]) {
                    DBRequestInternalServerError *internalServerError = [networkError asInternalServerError];
                    message = [NSString stringWithFormat:@"%@", internalServerError];
                } else if ([networkError isBadInputError]) {
                    DBRequestBadInputError *badInputError = [networkError asBadInputError];
                    message = [NSString stringWithFormat:@"%@", badInputError];
                } else if ([networkError isAuthError]) {
                    DBRequestAuthError *authError = [networkError asAuthError];
                    message = [NSString stringWithFormat:@"%@", authError];
                } else if ([networkError isRateLimitError]) {
                    DBRequestRateLimitError *rateLimitError = [networkError asRateLimitError];
                    message = [NSString stringWithFormat:@"%@", rateLimitError];
                } else if ([networkError isHttpError]) {
                    DBRequestHttpError *genericHttpError = [networkError asHttpError];
                    message = [NSString stringWithFormat:@"%@", genericHttpError];
                } else if ([networkError isClientError]) {
                    DBRequestClientError *genericLocalError = [networkError asClientError];
                    message = [NSString stringWithFormat:@"%@", genericLocalError];
                }
                
                NSError *nsError = [networkError nsError];
                if(nsError){
                    userMessage = [nsError localizedDescription];
                }
            }
            [self.owner notifyErrorWithTitle:title message:userMessage];
        }
    }];
}

- (void)downloadInfoFile {
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSString *searchPath = @"/Backup/";
    
    // list folder metadata contents (folder will be root "/" Dropbox folder if app has permission
    // "Full Dropbox" or "/Apps/<APP_NAME>/" if app has permission "App Folder").
    [[client.filesRoutes listFolder:searchPath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESListFolderError *routeError, DBRequestError *error) {
         
         if (result) {
             
             // 1. Fill files list
             for(DBFILESMetadata *meta in result.entries) {
//                 NSLog(@"meta: %@", meta);
                 [p_remoteFileNames addObject:meta.name];
             }
             
             // 2. Is backup exists and get name
             NSString *fileName = [self remoteBackupFileName];
             if(fileName){
                 p_remoteFileName = fileName;
                 
                 // 3. Download info file and parse it
                 NSString *sourcePath = [NSString stringWithFormat:@"/Backup/%@.xml", fileName];
                 NSURL *targetURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.xml", NSTemporaryDirectory(), fileName]];
                 [self downloadFileFrom:sourcePath toDestination:targetURL forTask:YYGDownloadTaskTypeInfo];
             } else {
                 [self.owner notifyIsBackupExists:NO];
             }
         } else {
             NSString *title = @"";
             NSString *message = @"";
             NSString *userMessage = @"";
             if (routeError) {
                 // Route-specific request error
                 title = @"Route-specific error";
                 if ([routeError isPath]) {
                     message = [NSString stringWithFormat:@"Invalid path: %@", routeError.path];
                     userMessage = [message copy];
                 }
             } else {
                 // Generic request error
                 title = @"Generic request error";
                 if ([error isInternalServerError]) {
                     DBRequestInternalServerError *internalServerError = [error asInternalServerError];
                     message = [NSString stringWithFormat:@"%@", internalServerError];
                 } else if ([error isBadInputError]) {
                     DBRequestBadInputError *badInputError = [error asBadInputError];
                     message = [NSString stringWithFormat:@"%@", badInputError];
                 } else if ([error isAuthError]) {
                     DBRequestAuthError *authError = [error asAuthError];
                     message = [NSString stringWithFormat:@"%@", authError];
                 } else if ([error isRateLimitError]) {
                     DBRequestRateLimitError *rateLimitError = [error asRateLimitError];
                     message = [NSString stringWithFormat:@"%@", rateLimitError];
                 } else if ([error isHttpError]) {
                     DBRequestHttpError *genericHttpError = [error asHttpError];
                     message = [NSString stringWithFormat:@"%@", genericHttpError];
                 } else if ([error isClientError]) {
                     DBRequestClientError *genericLocalError = [error asClientError];
                     message = [NSString stringWithFormat:@"%@", genericLocalError];
                 }
                 
                 NSError *nsError = [error nsError];
                 if(nsError){
                     userMessage = [nsError localizedDescription];
                 }
             }
             [self.owner notifyErrorWithTitle:title message:userMessage];
         }
     }];
}

- (NSDictionary *)backupInfo {
    return p_backupInfo;
}

/**
 Backup base fileName determine by sort list of all files find by checkBackup function.
 TODO: make validation of fileName.

 @return Base fileName of backup.
 */
- (NSString *)remoteBackupFileName {
    
    // Check
    if ([p_remoteFileNames count] == 0)
        return nil;
    
    // Result
    NSString *backupFileName = nil;
    
    // Filter input files for timestamp pattern match
    NSArray *filteredNames = [self filteredRemoteFileNames:p_remoteFileNames];
    
    // Sort names in DESC order
    NSArray *sortedNames = [filteredNames sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        
        if ([obj1 compare:obj2 options:NSForcedOrderingSearch | NSNumericSearch | NSCaseInsensitiveSearch] == NSOrderedDescending)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
    
    BOOL isPairExists = NO;
    for (NSString *nameI in sortedNames){
        if([nameI hasSuffix:@"sqlite"]){
            NSString *infoFileName = [nameI stringByAppendingString:@".xml"];
            for(NSString *nameJ in sortedNames){
                if (nameI != nameJ && [nameJ hasSuffix:@".xml"]){
                    if ([nameJ isEqualToString:infoFileName]){
                        isPairExists = true;
                        backupFileName = nameI;
                        break;
                    }
                }
            }
        }
        if(isPairExists)
            break;
    }
    
    return backupFileName;
}

- (NSArray *)filteredRemoteFileNames:(NSArray *)fileNames {
    
    // Check
    if ([fileNames count] == 0)
        return nil;
    
    NSMutableArray *resultNames = [NSMutableArray array];
    
    for (NSString *name in fileNames){
        
        // src pattern
        // @"^\\d{4}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[+-]\\d{4}\\.ledger\\.db\\.sqlite$"
        NSString *pattern = @"^\\d{4}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[+-]\\d{4}\\.ledger\\.db\\.sqlite";
        NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
        NSMatchingOptions matchingOptions = NSMatchingReportProgress;
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
        
        if(error){
            printf("\nError! Cannot create regex-object. %s", [[error description] UTF8String]);
            continue;
        }
        
        if([regex numberOfMatchesInString:name options:matchingOptions range:NSMakeRange(0, [name length])] > 0)
           [resultNames addObject:name];
    }
    return [resultNames copy];
}

#pragma mark - Restore backup from Dropbox

- (void)restore {
    
    [self.owner notifyMessage:NSLocalizedString(@"DROPBOX_DOWNLOAD_BACKUP_MESSAGE", @"Download backup...")];
    
    NSURL *dbDestination = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), p_remoteFileName]];

    NSString *remoteFilePath = [NSString stringWithFormat:@"/Backup/%@", p_remoteFileName];
    [self downloadFileFrom:remoteFilePath toDestination:dbDestination successHandler:^(NSURL *dbFile) {
        [self.owner notifyMessage:NSLocalizedString(@"DROPBOX_TEST_BACKUP_MESSAGE", @"Test backup...")];
        [self restoreDownloadedFile:dbFile];
    } errorHandler:^(NSString *message) {
        [self.owner notifyRestoreWithError:message];
    }];
}

- (void)restoreDownloadedFile:(NSURL *)downloadedFile {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *sourcePath = [downloadedFile absoluteString];
    NSString *targetPath = [NSString stringWithFormat:@"%@/%@", [YGTools documentsDirectoryPath], [[downloadedFile absoluteString] lastPathComponent]];
    
    // If any file exists on targetPath delete it
    // check for file name pattern, do not delete work.base!!!
    NSString *targetFileName = [targetPath lastPathComponent];
    if([fileManager fileExistsAtPath:targetPath]
       && ![targetFileName isEqualToString:kAppConfigName]
       && ![targetFileName isEqualToString:kDatabaseName]){
        
        NSError *error = nil;
        if(![fileManager removeItemAtPath:targetPath error:&error]){
            NSLog(@"Fail to remove file on target path. Error: %@", [error description]);
        }
    }
    
    NSError *error = nil;
    if(![fileManager moveItemAtPath:sourcePath toPath:targetPath error:&error]) {
        NSLog(@"Fail to move file. Error: %@", [error description]);
    }
    if (error){
        NSLog(@"Fail to move file. Error: %@", [error description]);
    }
    
    YYGDBTestDbFormat *testFormat = [[YYGDBTestDbFormat alloc] init];
    YYGDBTestDbOpen *testOpen = [[YYGDBTestDbOpen alloc] init];
    YYGDBTestDbVersion *testVersion = [[YYGDBTestDbVersion alloc] init];
    
    NSArray <id<YYGDBTesting>> *tests = [NSArray arrayWithObjects:testFormat, testOpen, testVersion, nil];
    YYGDBTester *tester = [[YYGDBTester alloc] initWithDbFile:targetPath tests:tests];
    
    if ([tester testDbFile]){
        // Test successfully passed
        
        NSString *oldFilePath = [NSString stringWithFormat:@"%@/%@", [YGTools documentsDirectoryPath], kDatabaseName];
        NSString *newFilePath = targetPath;
        if(![self replaceOldFile:(NSString *)oldFilePath onNewFile:(NSString *)newFilePath]){
            [self.owner notifyRestoreWithError:@"Error during swap db files."];
        } else {
            [self.owner notifyRestoreWithSuccess];
        }
    } else {
        // Tests failed
        NSString *message = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"DROPBOX_CAN_NOT_RESTORE_DB_MESSAGE", @"Can not restore database from remote backup."), [tester messageOfFailedTests]];
        [self.owner notifyRestoreWithError:message];
        
        // Remove downloaded file
        NSError *error = nil;
        if(![fileManager removeItemAtPath:targetPath error:&error]){
            NSLog(@"Error during remove unpassed, downloaded file. Error: %@", [error description]);
        }
    }
}

- (BOOL) replaceOldFile:(NSString *)oldFilePath onNewFile:(NSString *)newFilePath {
    
    NSFileManager *fileMananger = [NSFileManager defaultManager];
    
    // 1. Rename work db file to temp name
    NSString *oldFileTempPath = [NSString stringWithFormat:@"%@.%@.tmp", oldFilePath, [[NSUUID UUID] UUIDString]];
    NSError *error = nil;
    if (![fileMananger moveItemAtPath:oldFilePath toPath:oldFileTempPath error:&error]){
        NSLog(@"YYGStorageDropbox replaceOldFile:onNewFile:. Can not rename work db file.");
        return NO;
    }
    
    // 2. Rename backup db file to work db name
    if(![fileMananger moveItemAtPath:newFilePath toPath:oldFilePath error:&error]){
        NSLog(@"YYGStorageDropbox replaceOldFile:onNewFile:. Can not rename backup db file.");
        
        // rollback
        // TODO: Need to do something?
        
        return NO;
    }
    
    // 3. Delete ex work db file with temp name
    if(![fileMananger removeItemAtPath:oldFileTempPath error:&error]){
        NSLog(@"YYGStorageDropbox replaceOldFile:onNewFile:. Can not remove old work db file.");
        
        // It is not serious problem :)
    }
    
    return YES;
}


#pragma mark - Backup db to Dropbox

- (void)backup:(NSString *)fileName {
    
    p_localFileFullName = [fileName copy];
    
    // Check bundle
    if ([self isTempBackupValid:fileName]){
        [self uploadBackup:fileName];
    } else {
        [self.owner notifyBackupWithErrorMessage:NSLocalizedString(@"DROPBOX_LOCAL_BACKUP_IS_NOT_VALID_MESSAGE", @"Local backup is not valid.")];
    }
}

- (void)uploadBackup:(NSString *)fileName {
    
    // Upload sqlite-data & xml-info files
    [self uploadFile:p_localFileFullName successHandler:^{
        [self uploadFile:[p_localFileFullName stringByAppendingString:@".xml"] successHandler:^{
            [self notifyUploadedWithSuccess];
        } errorHandler:^(NSString *message) {
            [self notifyUploadedWithError:message];
        }];
    } errorHandler:^(NSString *message) {
        [self notifyUploadedWithError:message];
    }];
}

- (BOOL)isTempBackupValid:(NSString *)fileName {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:fileName]){
        return NO;
    }

    NSString *infoFileName = [fileName stringByAppendingString:@".xml"];
    if(![fileManager fileExistsAtPath:infoFileName]){
        return NO;
    }

    return YES;
}


/**
 @warning Callback to owner will be at checkBackup().
 */
- (void)notifyUploadedWithSuccess {
    
    // Clear temp local and remote files
    [self clearLocalTmp];
    [self clearRemoteOldBackups];
    
    // Clear shared
    p_localFileFullName = nil;
    p_remoteFileName = nil;
    [p_remoteFileNames removeAllObjects];
    
    // Update backup info
    [self checkBackup];
}

// Хорошо бы передать ошибку...
- (void)notifyUploadedWithError:(NSString *)message {
    
    // Clear temp local and remote files
    [self clearLocalTmp];
    [self clearRemoteUploadedWithErrors];
    
    // Callback to owner immediatly
    [self.owner notifyBackupWithErrorMessage:message];
}

- (void)clearLocalTmp {
    
    NSString *shortFileName = [p_localFileFullName lastPathComponent];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // database file
    NSString *dataFileName = [NSTemporaryDirectory() stringByAppendingPathComponent:shortFileName];
    if ([fileManager fileExistsAtPath:dataFileName]){
        [fileManager removeItemAtPath:dataFileName error:&error];
        if(error){
            NSLog(@"Error during remove database file. Error: %@", [error description]);
            error = nil;
        }
    }
    
    // info file
    NSString *infoFileName = [dataFileName stringByAppendingString:@".xml"];
    if([fileManager fileExistsAtPath:infoFileName]){
        [fileManager removeItemAtPath:infoFileName error:&error];
        if(error)
            NSLog(@"Error during remove info file. Error: %@", [error description]);
    }
}

- (void)clearRemoteOldBackups {
    
    // Check
    if ([p_remoteFileNames count] == 0)
        return;
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSMutableArray <DBFILESDeleteArg *> *args = [[NSMutableArray alloc] init];
    NSString *shortName = [p_localFileFullName lastPathComponent];
    for(NSString *name in p_remoteFileNames){
        
        if(![name isEqualToString:shortName] && ![name isEqualToString:[shortName stringByAppendingString:@".xml"]]){
            DBFILESDeleteArg *arg = [[DBFILESDeleteArg alloc] initWithPath:[@"/backup/" stringByAppendingString:name]];
            [args addObject:arg];
        }
    }
    
    if([args count] > 0){
        [client.filesRoutes deleteBatch:[args copy]];
    }
}

- (void)clearRemoteUploadedWithErrors {
    
    // Check
    if (!p_localFileFullName)
        return;
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSMutableArray <DBFILESDeleteArg *> *args = [[NSMutableArray alloc] init];
    NSString *shortName = [p_localFileFullName lastPathComponent];
    [args addObject:[[DBFILESDeleteArg alloc] initWithPath:[NSString stringWithFormat:@"/Backup/%@", shortName]]];
    [args addObject:[[DBFILESDeleteArg alloc] initWithPath:[NSString stringWithFormat:@"/Backup/%@.xml", shortName]]];
    
    [client.filesRoutes deleteBatch:[args copy]];
}

- (void)uploadFile:(NSString *)fileName successHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSString *message))errorHandler {
    
    [self.owner notifyMessage:NSLocalizedString(@"DROPBOX_UPLOAD_BACKUP_MESSAGE", @"Upload backup...")];
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSData *fileData = [NSData dataWithContentsOfFile:fileName];
    
    // For overriding on upload
    DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
    
    // Remote path
    NSString *shortName = [fileName lastPathComponent];
    NSString *targetPath = [@"/Backup/" stringByAppendingString:shortName];
    
    [[[client.filesRoutes uploadData:targetPath
                                mode:mode
                          autorename:@(NO)
                      clientModified:nil
                                mute:@(NO)
                           inputData:fileData]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESUploadError *routeError, DBRequestError *networkError) {
          if (result) {
              //NSLog(@"%@\n", result);
              successHandler();
          } else {
              NSLog(@"%@\n%@\n", routeError, networkError);
              NSString *message = nil;
              if (networkError){
                  NSString *errorUserInfo = [[networkError nsError] localizedDescription];
                  if (errorUserInfo)
                      message = errorUserInfo;
              }
              else if(routeError){
                  message = [routeError description];
              }
              errorHandler(message);
          }
      }] setProgressBlock:^(int64_t bytesUploaded, int64_t totalBytesUploaded, int64_t totalBytesExpectedToUploaded) {
          //NSLog(@"\n%lld\n%lld\n%lld\n", bytesUploaded, totalBytesUploaded, totalBytesExpectedToUploaded);
      }];
}


- (void)uploadBackupFile:(NSString *)fileName {
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSData *fileData = [NSData dataWithContentsOfFile:fileName];
    
    // For overriding on upload
    DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
    
    NSString *shortFileName = [fileName lastPathComponent];
    
    NSString *targetFileName = [@"/Backup/" stringByAppendingString:shortFileName];
    
    [[[client.filesRoutes uploadData:targetFileName
                                mode:mode
                          autorename:@(YES)
                      clientModified:nil
                                mute:@(NO)
                           inputData:fileData]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESUploadError *routeError, DBRequestError *networkError) {
          if (result) {
              NSLog(@"%@\n", result);
          } else {
              NSLog(@"%@\n%@\n", routeError, networkError);
          }
      }] setProgressBlock:^(int64_t bytesUploaded, int64_t totalBytesUploaded, int64_t totalBytesExpectedToUploaded) {
          NSLog(@"\n%lld\n%lld\n%lld\n", bytesUploaded, totalBytesUploaded, totalBytesExpectedToUploaded);
      }];

}

#pragma mark - Dropbox API local callbacks

- (void)notifyParseInfofile:(NSURL *)destinationUrl {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[destinationUrl absoluteString]]){
        p_backupInfo = [NSDictionary dictionaryWithContentsOfFile:[destinationUrl absoluteString]];
        
        NSError *error = nil;
        [fileManager removeItemAtPath:[destinationUrl absoluteString] error:&error];
        if(error){
            NSLog(@"Error during remove file. Description: %@", [error description]);
        }
    } else {
        NSLog(@"Info file is not exists at path:\n%@", destinationUrl);
    }
}

#pragma mark - Dropbox wrappers

- (void)downloadFileFrom:(NSString *)downloadPath toDestination:(NSURL *)destinationUrl successHandler:(void (^)(NSURL *downloadedUrl))successHandler errorHandler:(void (^)(NSString *message))errorHandler{
    
//    NSLog(@"YYGStorageDropbox downloadFileFrom:\n%@ \ntoDestination:\n%@", downloadPath, destinationUrl);
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    [[[client.filesRoutes
       downloadUrl:downloadPath
       overwrite:YES
       destination:destinationUrl]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *networkError, NSURL *destination) {
          
          if (result) {
              NSLog(@"%@\n", result);
              NSData *data = [[NSFileManager defaultManager] contentsAtPath:[destination path]];
              NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"%@\n", dataStr);
              
              successHandler(destinationUrl);
          } else {
              errorHandler([NSString stringWithFormat:@"%@ %@", routeError, networkError]);
              NSLog(@"%@\n%@\n", routeError, networkError);
          }
      }]
     setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
         NSLog(@"%lld\n%lld\n%lld\n", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload);
     }];
}

/**
 Download file from dropbox. Wrapper on dropbox API.

 @param downloadUrl String like @"/test/path/in/Dropbox/account/my_file.txt"
 @param destinationUrl Full file name on local.
 @param taskType Task type: download info or download backup
 */
- (void)downloadFileFrom:(NSString *)downloadPath toDestination:(NSURL *)destinationUrl forTask:(YYGDownloadTaskType)taskType {
    
//    NSLog(@"YYGStorageDropbox downloadFileFrom:\n%@ \ntoDestination:\n%@ \nforTask:\n%ld", downloadPath, destinationUrl, (long)taskType);
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    [[[client.filesRoutes
       downloadUrl:downloadPath
       overwrite:YES
       destination:destinationUrl]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *networkError, NSURL *destination) {
          
//          NSLog(@"client.files downloadURL getting result");
          
          if (result) {
              NSLog(@"%@\n", result);
              NSData *data = [[NSFileManager defaultManager] contentsAtPath:[destination path]];
              NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"%@\n", dataStr);
              
              switch (taskType) {
                  case YYGDownloadTaskTypeInfo:
                      [self notifyParseInfofile:destinationUrl];
                      [self.owner notifyIsBackupExists:YES];
                      break;
                  case YYGDownloadTaskTypeRestore:
//                      [self notifyRestoreDbFile:destinationUrl];
                      break;
                  default:
                      @throw [NSException exceptionWithName:@"Unknown download type" reason:@"downloadFileFrom:toDestination:forTask can not execute for unknown type" userInfo:nil];
              }
              
          } else {
              NSLog(@"%@\n%@\n", routeError, networkError);
          }
      }]
     setProgressBlock:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
          NSLog(@"%lld\n%lld\n%lld\n", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload);
      }];
}

@end
