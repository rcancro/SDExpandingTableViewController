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

@protocol SDExpandingTableViewControllerDataSource<NSObject>

// data source methods
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column forTableView:(UITableView *)tableView;
- (NSInteger)numberOfRowsInColumn:(id<SDExpandingTableViewColumnDelegate>)column section:(NSInteger)section;
- (NSInteger)numberOfSectionsInColumn:(id<SDExpandingTableViewColumnDelegate>)column;

- (id<SDExpandingTableViewColumnDelegate>)rootColumnIdentifier;
@end

@protocol SDExpandingTableViewControllerDelegate<NSObject>
// delegate methods
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column forTableView:(UITableView *)tableView;;
- (void)didDismissExpandingTables;

@optional
- (void)setupTableView:(UITableView *)tableView forColumn:(id<SDExpandingTableViewColumnDelegate>)column;
@end

@interface SDExpandingTableViewController : UIViewController
@property (nonatomic, weak) id<SDExpandingTableViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<SDExpandingTableViewControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *tableContainerView;

@property (nonatomic, assign) CGSize tableViewSize;
@property (nonatomic, assign) UIEdgeInsets tableViewsPaddingInsets;

@property (nonatomic, strong) UIColor *selectedColumnColor;
@property (nonatomic, strong) UIColor *nonselectedColumnColor;

- (instancetype)initWithTableViewStyle:(UITableViewStyle)tableStyle;
- (void)navigateToColumn:(id<SDExpandingTableViewColumnDelegate>)column fromParentColumn:(id<SDExpandingTableViewColumnDelegate>)parent animated:(BOOL)animated;

- (void)presentFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)presentFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;

@end
