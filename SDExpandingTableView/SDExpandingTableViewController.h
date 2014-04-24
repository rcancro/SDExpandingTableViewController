//
//  SDExpandingTableViewController.h
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 My name is kuma. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SDExpandingTableViewProtocol <NSObject>
- (NSString *)identifier;
@end

@interface SDIndexPath : NSObject
@property (nonatomic, weak) id<SDExpandingTableViewProtocol> tableIdentifier;
@property (nonatomic, strong) NSIndexPath *indexPath;

+ (instancetype)indexPathWithTable:(id<SDExpandingTableViewProtocol>)table sections:(NSInteger)section row:(NSInteger)row;
+ (instancetype)indexPathWithTable:(id<SDExpandingTableViewProtocol>)table indexPath:(NSIndexPath *)indexPath;
@end

@protocol SDExpandingTableViewControllerDataSource<NSObject>
- (UITableViewCell *)cellForRowAtIndexPath:(SDIndexPath *)indexPath;
- (NSInteger)numberOfRowsInTableView:(id<SDExpandingTableViewProtocol>)table section:(NSInteger)section;

- (NSArray *)childrenIdentifiersForIdentifier:(id<SDExpandingTableViewProtocol>)identifier;

- (void)didSelectRowAtIndexPath:(SDIndexPath *)indexPath;

@end

@interface SDExpandingTableViewController : UIViewController
@property (nonatomic, weak) id<SDExpandingTableViewControllerDataSource> dataSource;

- (instancetype)initWithTableViewIdentifier:(id<SDExpandingTableViewProtocol>)identifier tableViewStyle:(UITableViewStyle)tableStyle;

- (void)navigateToTableViewWithIdentifier:(id<SDExpandingTableViewProtocol>)tableViewIdentifier;
@end
