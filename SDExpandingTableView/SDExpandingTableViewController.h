//
//  SDExpandingTableViewController.h
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 My name is kuma. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SDExpandingTableViewColumnDelegate <NSObject>
- (NSString *)identifier;
@end

@protocol SDExpandingTableViewControllerDelegate<NSObject>

// data source methods
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column;
- (NSInteger)numberOfRowsInColumn:(id<SDExpandingTableViewColumnDelegate>)column section:(NSInteger)section;
- (NSInteger)numberOfSectionsInColumn:(id<SDExpandingTableViewColumnDelegate>)column;

// delegate methods
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column;;

@end

@interface SDExpandingTableViewController : UIViewController
@property (nonatomic, weak) id<SDExpandingTableViewControllerDelegate> dataSource;
@property (nonatomic, assign) CGFloat tableViewWidth;
@property (nonatomic, assign) UIEdgeInsets tableViewsPaddingInsets;

- (instancetype)initWithColumn:(id<SDExpandingTableViewColumnDelegate>)column tableViewStyle:(UITableViewStyle)tableStyle;
- (void)navigateToColumn:(id<SDExpandingTableViewColumnDelegate>)column fromParentColumn:(id<SDExpandingTableViewColumnDelegate>)parent animated:(BOOL)animated;
@end
