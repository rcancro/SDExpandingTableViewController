//
//  SDExpandingTableViewController.m
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 My name is kuma. All rights reserved.
//

#import "SDExpandingTableViewController.h"

@interface SDIndexPath()
@end

@implementation SDIndexPath

+ (instancetype)indexPathWithTable:(id<SDExpandingTableViewDataDelegate>)table sections:(NSInteger)section row:(NSInteger)row
{
    SDIndexPath *path = [[SDIndexPath alloc] init];
    path.tableIdentifier = table;
    path.row = row;
    path.section = section;
    return path;
}

+ (instancetype)indexPathWithTable:(id<SDExpandingTableViewDataDelegate>)table indexPath:(NSIndexPath *)indexPath
{
    SDIndexPath *path = [[SDIndexPath alloc] init];
    path.tableIdentifier = table;
    path.row = indexPath.row;
    path.section = indexPath.section;
    return path;
}

@end

static const CGFloat kDefaultTableViewWidth = 205.f;
static const UIEdgeInsets kDefaultTableViewPaddingInsets = {5.f, 5.f, 5.f, 5.f};

@interface SDExpandingTableViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *identifierToTableView;
@property (nonatomic, strong) NSMutableDictionary *tableViewToIdentifier;
@property (nonatomic, strong) NSMutableArray *tableViews;

@property (nonatomic, assign) UITableViewStyle tableStyle;

@property (nonatomic, assign) NSUInteger tableIndexCounter;
@property (nonatomic, assign) BOOL needsUpdateConstraints;
@end

@implementation SDExpandingTableViewController

- (instancetype)initWithTableViewIdentifier:(id<SDExpandingTableViewDataDelegate>)identifier tableViewStyle:(UITableViewStyle)tableStyle
{
    self = [super init];
    if (self)
    {
        _tableStyle = tableStyle;
        _identifierToTableView = [NSMutableDictionary dictionary];
        _tableViewToIdentifier = [NSMutableDictionary dictionary];
        _tableViews = [NSMutableArray array];
        _tableViewWidth = kDefaultTableViewWidth;
        _tableViewsPaddingInsets = kDefaultTableViewPaddingInsets;
        
        [self appendTableView:identifier];
    }
    return self;
}

- (void)appendTableView:(id<SDExpandingTableViewDataDelegate>)tableIdentifier
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:self.tableStyle];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.tableViews addObject:tableView];
    tableView.tag = self.tableIndexCounter;
    self.tableIndexCounter++;
    
    self.identifierToTableView[tableIdentifier.identifier] = tableView;
    self.tableViewToIdentifier[@(tableView.tag)] = tableIdentifier;
    
    [self.view addSubview:tableView];
    [tableView reloadData];
    
    self.needsUpdateConstraints = YES;
    [self.view setNeedsUpdateConstraints];
}

- (void)popBackToTableView:(id<SDExpandingTableViewDataDelegate>)tableIdentifier
{
    UITableView *tableView = self.identifierToTableView[tableIdentifier.identifier];
    if (tableView)
    {
        NSUInteger index = [self.tableViews indexOfObject:tableView];
        NSArray *tableViewsToRemove = [self.tableViews subarrayWithRange:NSMakeRange(index + 1, [self.tableViews count] - (index + 1))];
        
        for (UITableView *tableViewToRemove in tableViewsToRemove)
        {
            [self removeTableView:tableViewToRemove];
        }
    }
}

- (void)removeTableView:(UITableView *)tableView
{
    id<SDExpandingTableViewDataDelegate> tableIdentifier = self.tableViewToIdentifier[@(tableView.tag)];
    [self.tableViewToIdentifier removeObjectForKey:@(tableView.tag)];
    [self.identifierToTableView removeObjectForKey:tableIdentifier.identifier];
    [self.tableViews removeObject:tableView];
    [tableView removeFromSuperview];
    
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    if (self.needsUpdateConstraints)
    {
        self.needsUpdateConstraints = NO;
        
        [self.view removeConstraints:[self.view constraints]];
        
        NSUInteger index = 0;
        NSMutableDictionary *views = [NSMutableDictionary dictionaryWithCapacity:[self.tableViews count]];
        NSMutableString *horizontalConstraints = [NSMutableString stringWithString:@"H:"];
        
        for (UITableView *tableView in self.tableViews)
        {
            if (index == 0)
            {
                [horizontalConstraints appendFormat:@"|-(%f)-", self.tableViewsPaddingInsets.left];
            }
            NSString *tableId = [NSString stringWithFormat:@"tableView%tu", index];
            [horizontalConstraints appendFormat:@"[%@(%f)]", tableId, self.tableViewWidth];
            
            views[tableId] = tableView;
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%f)-[tableView]-(%f)-|", self.tableViewsPaddingInsets.top, self.tableViewsPaddingInsets.left] options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
            
            index++;
        }
        [horizontalConstraints appendFormat:@"-(%f)-|", self.tableViewsPaddingInsets.right];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraints options:0 metrics:nil views:views]];
        
        CGRect newFrame = self.view.frame;
        newFrame.size.width = (self.tableViewWidth * [self.tableViews count]) + self.tableViewsPaddingInsets.right + self.tableViewsPaddingInsets.left;
        self.view.frame = newFrame;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.94 blue:0.97 alpha:1.0];
    self.view.layer.cornerRadius = 5.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<SDExpandingTableViewDataDelegate> identifier = self.tableViewToIdentifier[@(tableView.tag)];
    SDIndexPath *sdPath = [SDIndexPath indexPathWithTable:identifier indexPath:indexPath];
    [self.dataSource didSelectRowAtIndexPath:sdPath];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSInteger rowCount = 0;
    id<SDExpandingTableViewDataDelegate> identifier = self.tableViewToIdentifier[@(tableView.tag)];
    if (nil != identifier)
    {
        rowCount = [self.dataSource numberOfRowsInTableView:identifier section:section];
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableCell = nil;
    id<SDExpandingTableViewDataDelegate> identifier = self.tableViewToIdentifier[@(tableView.tag)];
    if (nil != identifier)
    {
        SDIndexPath *sdPath = [SDIndexPath indexPathWithTable:identifier indexPath:indexPath];
        tableCell = [self.dataSource cellForRowAtIndexPath:sdPath];
    }
    return tableCell;
}

- (void)navigateToTableViewWithIdentifier:(id<SDExpandingTableViewDataDelegate>)tableViewIdentifier fromParent:(id<SDExpandingTableViewDataDelegate>)parentIdentifier animated:(BOOL)animated
{
    UITableView *tableView = [self.tableViews lastObject];
    id<SDExpandingTableViewDataDelegate> lastTable = self.tableViewToIdentifier[@(tableView.tag)];
    if ([[parentIdentifier identifier] isEqualToString:[lastTable identifier]])
    {
        [self appendTableView:tableViewIdentifier];
    }
    else
    {
        [self popBackToTableView:parentIdentifier];
        [self appendTableView:tableViewIdentifier];
    }
}


@end
