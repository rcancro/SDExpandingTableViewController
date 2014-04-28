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
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column;
- (NSInteger)numberOfRowsInColumn:(id<SDExpandingTableViewColumnDelegate>)column section:(NSInteger)section;
- (NSInteger)numberOfSectionsInColumn:(id<SDExpandingTableViewColumnDelegate>)column;
@end

@protocol SDExpandingTableViewControllerDelegate<NSObject>
// delegate methods
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column;;
- (void)didDismissExpandingTables;
@end

@interface SDExpandingTableViewController : UIViewController
@property (nonatomic, weak) id<SDExpandingTableViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<SDExpandingTableViewControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *tableContainerView;

@property (nonatomic, assign) CGSize tableViewSize;
@property (nonatomic, assign) UIEdgeInsets tableViewsPaddingInsets;

- (instancetype)initWithColumn:(id<SDExpandingTableViewColumnDelegate>)column tableViewStyle:(UITableViewStyle)tableStyle;
- (void)navigateToColumn:(id<SDExpandingTableViewColumnDelegate>)column fromParentColumn:(id<SDExpandingTableViewColumnDelegate>)parent animated:(BOOL)animated;

- (void)presentFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)presentFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;

@end
