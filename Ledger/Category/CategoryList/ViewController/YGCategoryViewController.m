//
//  YGCategoryViewController.m
//  Ledger
//
//  Created by Ян on 13/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCategoryViewController.h"
#import "YYGCategoryOneRowCell.h"
#import "YYGCategorySection.h"
#import "YYGCategoryRow.h"
#import "YYGCategoryViewModel.h"
#import "YYGNoDataView.h"

@interface YGCategoryViewController () {
    YYGNoDataView *p_noDataView;
}
@end

@implementation YGCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // add button on nav bar
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // title
    self.title = [self.viewModel title];
    
    // cell classes for one and two rows
    [self.tableView registerClass:[YYGCategoryOneRowCell class] forCellReuseIdentifier:kCategoryOneRowCellId];
    
    // add observers to reload table when concrete cache update
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(reloadDataFromCache)
                   name:[self.viewModel cashUpdateNotificationName]
                 object:nil];
        
    [self reloadDataFromCache];
    
    // Remove empty cells
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)updateUI {
    if([[self.viewModel section].rows count] == 0) {
        [self.tableView setUserInteractionEnabled:NO];
        [self showNoDataView];
    } else {
        [self.tableView setUserInteractionEnabled:YES];
        [self hideNoDataView];
        [self.tableView reloadData];
    }
}


/**
 Reload tableView to update outdated cache. Method generated by observer when updated cache in category manager.
 */
- (void)reloadDataFromCache {
    [self.viewModel loadSection];
    [self updateUI];
}

/**
 Dealloc of object. Remove all notifications.
 */
- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma mark - Actions

- (void)addButtonPressed {
    
    YGCategoryType type = [self.viewModel type];
    id<YYGCategoryViewModelable> viewModel = [YYGCategoryViewModel viewModelWith:type];
    viewModel.isNew = YES;
    viewModel.category = nil;
    
    UIViewController <YYGCategoryViewControllerViewModelable> *vc = [self.storyboard instantiateViewControllerWithIdentifier:[self.viewModel viewControllerStoryboardName]];
    vc.viewModel = viewModel;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YGCategoryType type = [self.viewModel type];
    id<YYGCategoryViewModelable> viewModel = [YYGCategoryViewModel viewModelWith:type];
    
    viewModel.type = self.categoryType;
    viewModel.isNew = NO;
    viewModel.category = [[self.viewModel section].rows[indexPath.row].category copy];
    
    UIViewController <YYGCategoryViewControllerViewModelable> *vc = [self.storyboard instantiateViewControllerWithIdentifier:[self.viewModel viewControllerStoryboardName]];
    vc.viewModel = viewModel;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.viewModel section].rows count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YYGCategoryRow *row = [self.viewModel section].rows[indexPath.row];
    YYGCategoryOneRowCell *cellCategory = (YYGCategoryOneRowCell *)cell;
        
    // left text
    cellCategory.textLeft = [self.viewModel textLeftOf:row];
    
    // right text
    cellCategory.textRight = [self.viewModel textRightOf:row];
    
    // need to be colored at any way
    if(row.category.active)
        cellCategory.colorTextLeft = [UIColor blackColor];
    else
        cellCategory.colorTextLeft = [UIColor grayColor];
    
    cellCategory.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YYGCategoryOneRowCell *cell = [tableView dequeueReusableCellWithIdentifier:kCategoryOneRowCellId];
    if(cell == nil) {
        cell = [[YYGCategoryOneRowCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCategoryOneRowCellId];
    }
    return cell;
}

#pragma mark - Control NoDataView
// TODO: remove dirty
- (void)showNoDataView {
    
    if(!p_noDataView) {
        p_noDataView = [[YYGNoDataView alloc] initWithFrame:self.tableView.bounds forView:self.tableView];
    }
    
    [p_noDataView showMessage:[self.viewModel noDataMessage]];
}

- (void)hideNoDataView {
    if(p_noDataView)
        [p_noDataView hide];
}

@end
