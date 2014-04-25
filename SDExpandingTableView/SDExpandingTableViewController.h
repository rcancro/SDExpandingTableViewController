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

@interface SDIndexPath : NSObject
@property (nonatomic, weak) id<SDExpandingTableViewColumnDelegate> column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger section;

+ (instancetype)indexPathWithColumn:(id<SDExpandingTableViewColumnDelegate>)column sections:(NSInteger)section row:(NSInteger)row;
+ (instancetype)indexPathWithColumn:(id<SDExpandingTableViewColumnDelegate>)column indexPath:(NSIndexPath *)indexPath;
@end

@protocol SDExpandingTableViewControllerDelegate<NSObject>

// data source methods
- (UITableViewCell *)cellForRowAtIndexPath:(SDIndexPath *)indexPath;
- (NSInteger)numberOfRowsInColumn:(id<SDExpandingTableViewColumnDelegate>)column section:(NSInteger)section;
- (NSInteger)numberOfSectionsInColumn:(id<SDExpandingTableViewColumnDelegate>)column;

// delegate methods
- (void)didSelectRowAtIndexPath:(SDIndexPath *)indexPath;

@end

@interface SDExpandingTableViewController : UIViewController
@property (nonatomic, weak) id<SDExpandingTableViewControllerDelegate> dataSource;
@property (nonatomic, assign) CGFloat tableViewWidth;
@property (nonatomic, assign) UIEdgeInsets tableViewsPaddingInsets;

- (instancetype)initWithColumn:(id<SDExpandingTableViewColumnDelegate>)column tableViewStyle:(UITableViewStyle)tableStyle;
- (void)navigateToColumn:(id<SDExpandingTableViewColumnDelegate>)column fromParentColumn:(id<SDExpandingTableViewColumnDelegate>)parent animated:(BOOL)animated;
@end
