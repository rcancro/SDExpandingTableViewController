//
//  SDExpandingTableViewController.h
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 My name is kuma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDIndexPath : NSObject
@property (nonatomic, assign) NSInteger table;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;

+ (instancetype)indexPathWithTable:(NSInteger)table sections:(NSInteger)section row:(NSInteger)row;
+ (instancetype)indexPathWithTable:(NSInteger)table indexPath:(NSIndexPath *)indexPath;
@end

@protocol SDExpandingTableViewControllerDataSource<NSObject>


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(SDIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInTableView:(NSInteger)table section:(NSInteger)section;
@end

@interface SDExpandingTableViewController : UIViewController
@property (nonatomic, weak) id<SDExpandingTableViewControllerDataSource> dataSource;

- (void)addNewTableViewWithIdentifier:(NSString *)tableViewIdentifier;
- (void)popTableView;
@end
