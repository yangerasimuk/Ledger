//
//  YYGUpdater.m
//  Ledger
//
//  Created by Ян on 03.07.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGUpdater.h"
#import "YGConfig.h"
#import "YYGLedgerDefine.h"
#import "YGTools.h"
#import "YGDirectory.h"
#import "YYGAppVersion.h"
#import "YYGConfigDefine.h"

@implementation YYGUpdater

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)checkEnvironment {
    
    YYGAppVersion *currentAppVersion = [[YYGAppVersion alloc] initWithCurruntBundle];
    YYGAppVersion *environmentVersion = [[YYGAppVersion alloc] initWithConfigEnvironmentKeys];
    
    // Check if appVersion is higher then environmentVersion
    if ([currentAppVersion compare:environmentVersion] == NSOrderedDescending){
        
        SEL updateEnvironment = [[self class] updateEnvironment:currentAppVersion];
        
        // Check if app have update for new version
        if ([self respondsToSelector:updateEnvironment]) {
            if([self performSelector:updateEnvironment]) {
                NSLog(@"Environment successfully updated to version %@", [currentAppVersion toString]);
                [self setEnvironmentVersionAsAppVersion:currentAppVersion];
            }
        } else {
            [self setEnvironmentVersionAsAppVersion:currentAppVersion];
        }
    }
}

+ (SEL)updateEnvironment:(YYGAppVersion *)appVersion {
    
    NSString *version = [NSString stringWithFormat:@"Major%ldMinor%ldBuild%ld", (long)appVersion.major, (long)appVersion.minor, (long)appVersion.build];
    
    return NSSelectorFromString([NSString stringWithFormat:@"updateToVersion%@", version]);
}

#pragma mark - Help funcs

- (BOOL)isBackupName:(NSString *)name {
    
    // src pattern
    // @"^\\d{4}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[-]\\d{2}[+-]\\d{4}\\.ledger\\.db\\.sqlite"
    NSString *pattern = kBackupFileNamePattern;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    NSMatchingOptions matchingOptions = NSMatchingReportProgress;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    
    if(error){
        printf("\nError! Cannot create regex-object. %s", [[error description] UTF8String]);
        return NO;
    }
    
    if([regex numberOfMatchesInString:name options:matchingOptions range:NSMakeRange(0, [name length])] > 0)
        return YES;
    else
        return NO;
}

- (void)setEnvironmentVersionAsAppVersion:(YYGAppVersion *)appVersion {
    
    YGDirectory *documents = [[YGDirectory alloc] initWithPathFull: [YGTools documentsDirectoryPath]];
    YGConfig *config = [[YGConfig alloc] initWithDirectory:documents name:@"ledger.config.xml"];
    
    [config setValue:@(appVersion.major) forKey:kConfigEnvironmentMajorVersion];
    [config setValue:@(appVersion.minor) forKey:kConfigEnvironmentMinorVersion];
    [config setValue:@(appVersion.build) forKey:kConfigEnvironmentBuildVersion];
}

#pragma mark - Updates to concrete version

/**
 Update to verstion 1.1(11).
 [+] Make directory for local backup: .../Documents/Backup
 [+] All local backups must be move to .../Documents/Backup

 @return Is update success or not
 */
- (BOOL)updateToVersionMajor1Minor1Build12 {
    
    NSLog(@"Update to version 1.1(12)...");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *backupDirPath = [NSString stringWithFormat:@"%@/%@", [YGTools documentsDirectoryPath], @"Backup"];
    BOOL isDirectory;
    
    if([fileManager fileExistsAtPath:backupDirPath isDirectory:&isDirectory]){
        return NO;
    } else {
        if (![fileManager createDirectoryAtPath:backupDirPath withIntermediateDirectories:NO attributes:nil error:&error]){
            NSLog(@"Can not create local backup directory");
            return NO;
        }
        
        NSArray *fileNames = [YGTools namesAtPath:[YGTools documentsDirectoryPath]];
        NSMutableArray *backupFileNames = [NSMutableArray array];
        
        for (NSString *name in fileNames){
            if ([self isBackupName:name]){
                [backupFileNames addObject:name];
            }
        }
        
        if ([backupFileNames count] > 0){
            for (NSString *name in backupFileNames){
                
                NSString *oldName = [NSString stringWithFormat:@"%@/%@", [YGTools documentsDirectoryPath], name];
                NSString *newName = [NSString stringWithFormat:@"%@/%@/%@", [YGTools documentsDirectoryPath], @"Backup", [name lastPathComponent]];
                
                if(![fileManager moveItemAtPath:oldName toPath:newName error:&error]){
                    NSLog(@"Fail to move backup file to new path. Error: %@", [error description]);
                    return NO;
                }
            }
        }
        return YES;
    }
}

@end
