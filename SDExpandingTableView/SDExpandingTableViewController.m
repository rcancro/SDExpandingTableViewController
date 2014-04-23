//
//  SDExpandingTableViewController.m
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 My name is kuma. All rights reserved.
//

#import "SDExpandingTableViewController.h"

@implementation SDIndexPath

+ (instancetype)indexPathWithTable:(NSInteger)table sections:(NSInteger)section row:(NSInteger)row
{
    SDIndexPath *path = [[SDIndexPath alloc] init];
    path.table = table;
    path.row = row;
    path.section = section;
    return path;
}

+ (instancetype)indexPathWithTable:(NSInteger)table indexPath:(NSIndexPath *)indexPath
{
    SDIndexPath *path = [[SDIndexPath alloc] init];
    path.table = table;
    path.row = indexPath.row;
    path.section = indexPath.section;
    return path;
}

@end

@interface SDExpandingTableViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *tableViews;
@property (nonatomic, strong) NSArray *tableData;
@end

@implementation SDExpandingTableViewController

- (id)initWithInitialTableData:(NSArray *)tableData
{
    self = [super init];
    if (self)
    {
        _tableData = [NSArray arrayWithObject:tableData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (0 == [self.tableViews count])
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableViews = [NSArray arrayWithObject:tableView];
        
    }
}

- (NSUInteger)indexForTableView:(UITableView *)tableView
{
    return [self.tableViews indexOfObject:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSInteger sectionCount = 0;
    NSInteger tableIndex = [self indexForTableView:tableView];
    if (NSNotFound != tableIndex)
    {
        sectionCount = [self.dataSource tableView:tableView numberOfRowsInTableView:tableIndex section:section];
    }
    return sectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableCell = nil;
    NSInteger tableIndex = [self indexForTableView:tableView];
    if (NSNotFound != tableIndex)
    {
        SDIndexPath *sdPath = [SDIndexPath indexPathWithTable:tableIndex indexPath:indexPath];
        tableCell = [self.dataSource tableView:tableView cellForRowAtIndexPath:sdPath];
    }
    return tableCell;
}

@end
