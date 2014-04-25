//
//  SDExpandingTableViewController.h
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 My name is kuma. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SDExpandingTableViewDataDelegate <NSObject>
- (NSString *)identifier;
@end

@interface SDIndexPath : NSObject
@property (nonatomic, weak) id<SDExpandingTableViewDataDelegate> tableIdentifier;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger section;

+ (instancetype)indexPathWithTable:(id<SDExpandingTableViewDataDelegate>)table sections:(NSInteger)section row:(NSInteger)row;
+ (instancetype)indexPathWithTable:(id<SDExpandingTableViewDataDelegate>)table indexPath:(NSIndexPath *)indexPath;
@end

@protocol SDExpandingTableViewControllerDelegate<NSObject>

// data source methods
- (UITableViewCell *)cellForRowAtIndexPath:(SDIndexPath *)indexPath;
- (NSInteger)numberOfRowsInTableView:(id<SDExpandingTableViewDataDelegate>)table section:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(id<SDExpandingTableViewDataDelegate>)table;

// delegate methods
- (void)didSelectRowAtIndexPath:(SDIndexPath *)indexPath;

@end

@interface SDExpandingTableViewController : UIViewController
@property (nonatomic, weak) id<SDExpandingTableViewControllerDelegate> dataSource;
@property (nonatomic, assign) CGFloat tableViewWidth;
@property (nonatomic, assign) UIEdgeInsets tableViewsPaddingInsets;

- (instancetype)initWithTableViewIdentifier:(id<SDExpandingTableViewDataDelegate>)identifier tableViewStyle:(UITableViewStyle)tableStyle;
- (void)navigateToTableViewWithIdentifier:(id<SDExpandingTableViewDataDelegate>)tableViewIdentifier fromParent:(id<SDExpandingTableViewDataDelegate>)parentIdentifier animated:(BOOL)animated;
@end
