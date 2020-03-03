//
//  YYGEmptyView.m
//  Ledger
//
//  Created by Ян on 02.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import "YYGEmptyView.h"
#import "YYGApplication.h"
#import "YYGSemanticColor.h"
#import "YYGSemanticFont.h"


@interface YYGEmptyView ()

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, weak) UINavigationController *navController;
@property (nonatomic, weak) UITabBarController *tabBarController;

@end


@implementation YYGEmptyView

- (instancetype)initWithParentView:(UIView *)parentView
				  navBarController:(UINavigationController *)navBarController
				  tabBarController:(UITabBarController *)tabBarController
{
	self = [super init];
	if (self)
	{
		_parentView = parentView;
		_navController = navBarController;
		_tabBarController = tabBarController;
		
		[self createView];
		[self createLabel];
	}
	return self;
}

- (void)createView
{
	_view = [UIView new];
	_view.hidden = YES;
	_view.backgroundColor = YYGSemanticColor.emptyViewBackground;
	[_parentView addSubview:_view];
	
	_view.translatesAutoresizingMaskIntoConstraints = NO;
	
	CGFloat statusHeight = [YYGApplication statusBarHeightWithApplication:UIApplication.sharedApplication];
	CGFloat navHeight = [YYGApplication navBarHeightWithNavController:self.navController];
	CGFloat topOffset = statusHeight + navHeight;
	CGFloat bottomOffset = [YYGApplication tabBarHeightWithTabBarController:self.tabBarController];
	
	[NSLayoutConstraint activateConstraints: @[
		[_view.topAnchor constraintEqualToAnchor:_parentView.topAnchor constant:topOffset],
		[_view.rightAnchor constraintEqualToAnchor:_parentView.rightAnchor],
		[_view.bottomAnchor constraintEqualToAnchor:_parentView.bottomAnchor constant:-bottomOffset],
		[_view.leftAnchor constraintEqualToAnchor:_parentView.leftAnchor]
	]];
}

- (void)createLabel
{
	_label = [UILabel new];
	_label.numberOfLines = 1;
	_label.font = YYGSemanticFont.emptyViewMessage;
	_label.textColor = YYGSemanticColor.emptyViewMessage;
	_label.hidden = YES;
	[_view addSubview:_label];
	
	_label.translatesAutoresizingMaskIntoConstraints = NO;
	
	[NSLayoutConstraint activateConstraints: @[
		[_label.centerXAnchor constraintEqualToAnchor:_view.centerXAnchor],
		[_label.centerYAnchor constraintEqualToAnchor:_view.centerYAnchor],
		[_label.heightAnchor constraintEqualToConstant:30.0]
	]];
}


#pragma mark - Public API

- (void)showWithMessage:(NSString *)message
{
	self.view.hidden = NO;
	self.label.hidden = NO;
	self.label.text = message;
}

- (void)hide
{
	self.view.hidden = YES;
	self.label.hidden = YES;
}

@end
