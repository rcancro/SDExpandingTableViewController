//
//  SDExpandingTableViewController.m
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 My name is kuma. All rights reserved.
//

#import "SDExpandingTableViewController.h"

static const CGSize kDefaultTableViewSize = {205.f, 350.f};
static const UIEdgeInsets kDefaultTableViewPaddingInsets = {5.f, 5.f, 5.f, 5.f};

@interface SDExpandingTableViewController ()<UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) NSMutableDictionary *identifierToTableView;
@property (nonatomic, strong) NSMutableDictionary *tableViewToIdentifier;
@property (nonatomic, strong) NSMutableArray *tableViews;

@property (nonatomic, assign) UITableViewStyle tableStyle;

@property (nonatomic, assign) NSUInteger tableIndexCounter;
@property (nonatomic, assign) BOOL needsUpdateConstraints;

@property (nonatomic, strong) UIPopoverController *popController;
@end

@implementation SDExpandingTableViewController

- (instancetype)initWithTableViewStyle:(UITableViewStyle)tableStyle
{
    self = [super init];
    if (self)
    {
        _tableStyle = tableStyle;
        _identifierToTableView = [NSMutableDictionary dictionary];
        _tableViewToIdentifier = [NSMutableDictionary dictionary];
        _tableViews = [NSMutableArray array];
        _tableViewSize = kDefaultTableViewSize;
        _tableViewsPaddingInsets = kDefaultTableViewPaddingInsets;
        _needsUpdateConstraints = YES;
        _selectedColumnColor = [UIColor whiteColor];
        _nonselectedColumnColor = [UIColor lightGrayColor];
        
//        [self appendTableView:column];
    }
    return self;
}

- (void)presentFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    self.popController = [[UIPopoverController alloc] initWithContentViewController:self];
    self.popController.delegate = self;
    [self.popController presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
    [self.delegate didSelectRowAtIndexPath:nil inColumn:[self.dataSource rootColumnIdentifier] forTableView:nil];
}

- (void)presentFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    self.popController = [[UIPopoverController alloc] initWithContentViewController:self];
    self.popController.delegate = self;
    [self.popController presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
    [self.delegate didSelectRowAtIndexPath:nil inColumn:[self.dataSource rootColumnIdentifier] forTableView:nil];
}

- (void)dismissAnimated:(BOOL)animated
{
    [self.popController dismissPopoverAnimated:animated];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popController = nil;
}


- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setContainerFrames:NO];
}

- (void)setContainerFrames:(BOOL)animated
{
    CGRect containerFrame = self.view.frame;
    NSUInteger tableViewCount = [self.tableViews count] == 0 ? 1 : [self.tableViews count];
    
    containerFrame.size.width = self.tableViewsPaddingInsets.left + self.tableViewsPaddingInsets.right + (self.tableViewSize.width * tableViewCount);
    containerFrame.size.height = self.tableViewsPaddingInsets.top + self.tableViewsPaddingInsets.bottom + self.tableViewSize.height;
    self.view.frame = containerFrame;
    [self.popController setPopoverContentSize:self.view.frame.size animated:animated];
}

- (void)appendTableView:(id<SDExpandingTableViewColumnDelegate>)column
{
    @strongify(_delegate, strongDelegate);
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:self.tableStyle];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    if ([strongDelegate respondsToSelector:@selector(setupTableView:forColumn:)])
    {
        [strongDelegate setupTableView:tableView forColumn:column];
    }
    
    for (UITableView *savedTableView in self.tableViews)
    {
        savedTableView.backgroundColor = self.nonselectedColumnColor;
    }
    tableView.backgroundColor = self.selectedColumnColor;
    
    [self.tableViews addObject:tableView];
    self.tableIndexCounter++;
    tableView.tag = self.tableIndexCounter;
    
    self.identifierToTableView[column.identifier] = tableView;
    self.tableViewToIdentifier[@(tableView.tag)] = column;
    
    [self.view addSubview:tableView];
    [tableView reloadData];
    
    self.needsUpdateConstraints = YES;
    [self.view setNeedsUpdateConstraints];
}

- (void)popBackToColumn:(id<SDExpandingTableViewColumnDelegate>)column
{
    UITableView *tableView = self.identifierToTableView[column.identifier];
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
    id<SDExpandingTableViewColumnDelegate> column = self.tableViewToIdentifier[@(tableView.tag)];
    [self.tableViewToIdentifier removeObjectForKey:@(tableView.tag)];
    [self.identifierToTableView removeObjectForKey:column.identifier];
    [self.tableViews removeObject:tableView];
    [tableView removeFromSuperview];
    
}

- (void)updateViewConstraints
{
    if (self.needsUpdateConstraints)
    {
        if (0 < [self.tableViews count])
        {
            self.needsUpdateConstraints = NO;
            [self.view removeConstraints:[self.view constraints]];
            [self setContainerFrames:YES];
        
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
                [horizontalConstraints appendFormat:@"[%@(%f)]", tableId, self.tableViewSize.width];
                
                views[tableId] = tableView;
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%f)-[tableView(%f)]-(%f)-|", self.tableViewsPaddingInsets.top, self.tableViewSize.height, self.tableViewsPaddingInsets.left] options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
                
                index++;
            }
            [horizontalConstraints appendFormat:@"-(%f)-|", self.tableViewsPaddingInsets.right];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraints options:0 metrics:nil views:views]];
        }
        
    }
    [super updateViewConstraints];
}

- (CGSize)preferredContentSize
{
    [self setContainerFrames:NO];
    return self.view.frame.size;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<SDExpandingTableViewColumnDelegate> column = self.tableViewToIdentifier[@(tableView.tag)];
    [self.delegate didSelectRowAtIndexPath:indexPath inColumn:column forTableView:tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSInteger rowCount = 0;
    id<SDExpandingTableViewColumnDelegate> column = self.tableViewToIdentifier[@(tableView.tag)];
    if (nil != column)
    {
        rowCount = [self.dataSource numberOfRowsInColumn:column section:section forTableView:tableView];
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableCell = nil;
    id<SDExpandingTableViewColumnDelegate> column = self.tableViewToIdentifier[@(tableView.tag)];
    if (nil != column)
    {
        tableCell = [self.dataSource cellForRowAtIndexPath:indexPath inColumn:column forTableView:tableView];
    }
    return tableCell;
}

- (void)navigateToColumn:(id<SDExpandingTableViewColumnDelegate>)column fromParentColumn:(id<SDExpandingTableViewColumnDelegate>)parentColumn animated:(BOOL)animated
{
    UITableView *tableView = [self.tableViews lastObject];
    id<SDExpandingTableViewColumnDelegate> lastColumn = self.tableViewToIdentifier[@(tableView.tag)];
    if ([parentColumn identifier] == [lastColumn identifier])
    {
        [self appendTableView:column];
    }
    else
    {
        [self popBackToColumn:parentColumn];
        [self appendTableView:column];
    }
}


@end
