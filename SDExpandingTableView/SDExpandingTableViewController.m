//
//  SDExpandingTableViewController.m
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 My name is kuma. All rights reserved.
//

#import "SDExpandingTableViewController.h"
#import "JTTree.h"

@implementation SDIndexPath

+ (instancetype)indexPathWithTable:(id<SDExpandingTableViewProtocol>)table sections:(NSInteger)section row:(NSInteger)row
{
    SDIndexPath *path = [[SDIndexPath alloc] init];
    path.tableIdentifier = table;
    path.indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return path;
}

+ (instancetype)indexPathWithTable:(id<SDExpandingTableViewProtocol>)table indexPath:(NSIndexPath *)indexPath
{
    SDIndexPath *path = [[SDIndexPath alloc] init];
    path.tableIdentifier = table;
    path.indexPath = indexPath;
    return path;
}

@end

@interface SDExpandingTableViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSDictionary *identifierToTableView;
@property (nonatomic, strong) NSDictionary *tableViewToIdentifier;
@property (nonatomic, strong) NSArray *tableViews;

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) JTTree *taxonomyTree;
@property (nonatomic, assign) UITableViewStyle tableStyle;

@property (nonatomic, assign) NSUInteger tableIndexCounter;
@end

@implementation SDExpandingTableViewController

- (instancetype)initWithTableViewIdentifier:(id<SDExpandingTableViewProtocol>)identifier tableViewStyle:(UITableViewStyle)tableStyle
{
    self = [super init];
    if (self)
    {
        _taxonomyTree = [[JTTree alloc] initWithObject:identifier];
        _tableStyle = tableStyle;
    }
    return self;
}


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
        id<SDExpandingTableViewProtocol> rootNode = [self.taxonomyTree rootObject];
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:self.tableStyle];
        tableView.dataSource = self;
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.tableViews = @[tableView];
        tableView.tag = self.tableIndexCounter;
        
        self.identifierToTableView = @{[rootNode identifier]:tableView};
        self.tableViewToIdentifier = @{@(tableView.tag):rootNode};
        
        [self.view addSubview:tableView];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
        
//        NSArray *children = [self.dataSource childrenIdentifiersForIdentifier:rootNode];
//        
//        NSUInteger index = 0;
//        for (id<SDExpandingTableViewProtocol> child in children)
//        {
//            [self.taxonomyTree insertChild:child atIndex:index];
//            index++;
//        }
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<SDExpandingTableViewProtocol> identifier = self.tableViewToIdentifier[@(tableView.tag)];
    SDIndexPath *sdPath = [SDIndexPath indexPathWithTable:identifier indexPath:indexPath];
    [self.dataSource didSelectRowAtIndexPath:sdPath];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSInteger rowCount = 0;
    id<SDExpandingTableViewProtocol> identifier = self.tableViewToIdentifier[@(tableView.tag)];
    if (nil != identifier)
    {
        rowCount = [self.dataSource numberOfRowsInTableView:identifier section:section];
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableCell = nil;
    id<SDExpandingTableViewProtocol> identifier = self.tableViewToIdentifier[@(tableView.tag)];
    if (nil != identifier)
    {
        SDIndexPath *sdPath = [SDIndexPath indexPathWithTable:identifier indexPath:indexPath];
        tableCell = [self.dataSource cellForRowAtIndexPath:sdPath];
    }
    return tableCell;
}

- (void)navigateToTableViewWithIdentifier:(id<SDExpandingTableViewProtocol>)tableViewIdentifier
{
    
}


@end
