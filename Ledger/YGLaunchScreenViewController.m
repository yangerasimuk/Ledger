//
//  YGLaunchScreenViewController.m
//  Ledger
//
//  Created by Ян on 06.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YGLaunchScreenViewController.h"
#import "YGOperationSectionManager.h"
#import "AppDelegate.h"

@interface YGLaunchScreenViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;


@end

@implementation YGLaunchScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init UI
    self.appNameLabel.text = NSLocalizedString(@"LAUNCH_SCREEN_APP_NAME_LABEL", @"Application name on Launch screen.");
    self.logLabel.text = NSLocalizedString(@"LAUNCH_SCREEN_LOG_LOADING_LABEL", @"Log text during loading Launch screen.");
    
    [self.activityIndicator startAnimating];
    
    // Subscribe to end loadin section event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(loadMainUI)
                   name:@"OperationSectionManagerMakeSectionsEvent"
                 object:nil];
    
    // Load operations and convert it to sections & rows in tableView
    [self runBackgroundTasks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma mark - Background tasks

- (void)runBackgroundTasks {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [YGOperationSectionManager sharedInstance];
    });
}

- (void)loadMainUI {
    __weak YGLaunchScreenViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf) {
            YGLaunchScreenViewController *strongSelf = weakSelf;
            [strongSelf.activityIndicator stopAnimating];
            id<UIApplicationDelegate> appDelegate = [UIApplication.sharedApplication delegate];
            if ([appDelegate respondsToSelector:@selector(loadMainUI)])
                [appDelegate performSelector:@selector(loadMainUI)];
        }
    });
}

@end
