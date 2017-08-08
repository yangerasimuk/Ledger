//
//  AppDelegate.m
//  Ledger
//
//  Created by Ян on 28/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "AppDelegate.h"
#import "YGSQLite.h"
#import "YGDBManager.h"
#import "YGTools.h"
#import <YGConfig.h>
#import "YYGLedgerDefine.h"
#import "YYGDBConfig.h"

static NSString *const kIsFirstLaunch = @"IsFirstLaunch";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Hello world!");
    });
        

    
#ifdef DEBUG
    
    // save screen sizes for default font calc
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    UIScreen *screen = [UIScreen mainScreen];
    NSInteger width = [screen nativeBounds].size.width;
    NSInteger height = [screen nativeBounds].size.height;
    
    [defaults setObject:@(width) forKey:@"DeviceScreenWidth"];
    [defaults setObject:@(height) forKey:@"DeviceScreenHeight"];
    
    // create new work db
    YGDBManager *dm = [YGDBManager sharedInstance];
    
#ifdef DEBUG_REBUILD_BASE
    [dm createDatabase];
#else
    if(![dm databaseExists])
        [dm createDatabase];
#endif
    
    // set config for app
    YGConfig *config = [YGTools config];
    
    NSArray *storageAvailible = @[@"Local"];
    [config setValue:storageAvailible forKey:@"StoragesAvailible"];
    
    [defaults setBool:NO forKey:kIsFirstLaunch];
    
#else
    
    // Check for first launch
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![defaults objectForKey:kIsFirstLaunch] || [defaults valueForKey:kIsFirstLaunch] == NO){
        
        // save screen sizes for default font calc
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        UIScreen *screen = [UIScreen mainScreen];
        NSInteger width = [screen nativeBounds].size.width;
        NSInteger height = [screen nativeBounds].size.height;
        
        [defaults setObject:@(width) forKey:@"DeviceScreenWidth"];
        [defaults setObject:@(height) forKey:@"DeviceScreenHeight"];
        
        // create new work db
        YGDBManager *dm = [YGDBManager sharedInstance];
        
        if(![dm databaseExists])
            [dm createDatabase];
        
        // set config for app
        YGConfig *config = [YGTools config];
        
        NSArray *storageAvailible = @[@"Local"];
        [config setValue:storageAvailible forKey:@"StoragesAvailible"];
        
        [defaults setBool:YES forKey:kIsFirstLaunch];
    }
#endif
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
