//
//  YYGDebtorsViewController.m
//  Ledger
//
//  Created by Ян on 20.07.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGDebtorsViewController.h"
#import "YYGDebtorCell.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface YYGDebtorsViewController () <UITableViewDelegate, UITableViewDataSource> {
    UITableView *p_tableView;
    YYGDebtorsViewModel *p_viewModel;
    NSArray <YGCategory *> *p_debtors;
    BOOL debtorsLoaded;
}
@end

@implementation YYGDebtorsViewController

- (instancetype)initWithViewModel:(YYGDebtorsViewModel *)viewModel {
    self = [super init];
    if(self){
        p_viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self subscribeRAC];
    [p_viewModel loadDebtors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createUI {
    // Title
    self.title = @"Debtors/Creditors";
    
    // Create table
    CGRect tableFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    p_tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    p_tableView.tableFooterView = [[UIView alloc] init];
    [p_tableView registerClass:[YYGDebtorCell class] forCellReuseIdentifier:@"YYGDebtorCell"];
    p_tableView.delegate = self;
    p_tableView.dataSource = self;
    
    [self.view addSubview:p_tableView];
}

- (void)updateUI {
    [p_tableView reloadData];
}

- (void)subscribeRAC {
    
    RACSignal *debtorsLoadedSignal = RACObserve(p_viewModel, debtorsLoaded);
    [[debtorsLoadedSignal skip:1] subscribeNext:^(NSNumber *debtorsLoaded) {
        if(debtorsLoaded.boolValue == YES){
            p_debtors = p_viewModel.debtors;
            [p_tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [p_debtors count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YYGDebtorCell *debtorCell = [tableView dequeueReusableCellWithIdentifier:@"YYGDebtorCell" forIndexPath:indexPath];
    debtorCell.viewModel = [[YYGDebtorCellViewModel alloc] initWithDebtor:p_debtors[indexPath.row]];

    return debtorCell;
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
