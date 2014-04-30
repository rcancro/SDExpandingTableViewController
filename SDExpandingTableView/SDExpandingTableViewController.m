//
//  SDExpandingTableViewController.m
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//

#import "SDExpandingTableViewController.h"

static const CGSize kDefaultTableViewSize = {205.f, 350.f};
static const UIEdgeInsets kDefaultTableViewPaddingInsets = {5.f, 5.f, 5.f, 5.f};
static const CGFloat kMaxWidthPadding = 20.f;
static const CGFloat kMaxHeightPadding = 20.f;

@interface SDExpandingTableViewController ()<UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) NSMutableDictionary *identifierToTableView;
@property (nonatomic, strong) NSMutableDictionary *tableViewToIdentifier;
@property (nonatomic, strong) NSMutableArray *tableViews;

@property (nonatomic, assign) UITableViewStyle tableStyle;

@property (nonatomic, assign) NSUInteger tableIndexCounter;
@property (nonatomic, assign) BOOL needsUpdateConstraints;

@property (nonatomic, strong) UIPopoverController *popController;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) id orientationChangeListener;
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
        _nonselectedColumnColor = [UIColor colorWithRed:.95f green:.95f blue:.95f alpha:1.f];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        _maxSizePortrait = screenBounds.size;
        _maxSizePortrait.width -= kMaxWidthPadding * 2;
        _maxSizePortrait.height -= kMaxHeightPadding * 2;
        
        _maxSizeLandscape = CGSizeMake(_maxSizePortrait.height, _maxSizePortrait.width);
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    
    SDExpandingTableViewController *weakSelf = self;
    self.orientationChangeListener = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarFrameNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        SDExpandingTableViewController *strongSelf = weakSelf;
        [strongSelf setContainerFrames:YES];
    }];
    
    [self setContainerFrames:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.orientationChangeListener];
}

#pragma mark - presentation methods

- (void)presentFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    self.popController = [[UIPopoverController alloc] initWithContentViewController:self];
    self.popController.delegate = self;
    [self.popController presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
    [self navigateToColumn:[self.dataSource rootColumnIdentifier] fromParentColumn:nil animated:YES];
}

- (void)presentFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    self.popController = [[UIPopoverController alloc] initWithContentViewController:self];
    self.popController.delegate = self;
    [self.popController presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
    [self navigateToColumn:[self.dataSource rootColumnIdentifier] fromParentColumn:nil animated:YES];
}

- (void)dismissAnimated:(BOOL)animated
{
    [self.popController dismissPopoverAnimated:animated];
    self.popController = nil;
    [self.delegate didDismissExpandingTables];
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popController = nil;
    [self.delegate didDismissExpandingTables];
}

#pragma mark - Table Navigation Methods

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

- (void)appendTableView:(id<SDExpandingTableViewColumnDelegate>)column
{
    id<SDExpandingTableViewControllerDelegate> strongDelegate = self.delegate;
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
    
    [self.scrollView addSubview:tableView];
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

#pragma mark constraints and layout

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
            
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_scrollView)]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_scrollView)]];
        }
        
    }
    [super updateViewConstraints];
}

- (CGSize)preferredContentSize
{
    [self setContainerFrames:NO];
    return self.view.frame.size;
}

- (void)setContainerFrames:(BOOL)animated
{
    CGRect containerFrame = self.view.frame;
    NSUInteger tableViewCount = [self.tableViews count] == 0 ? 1 : [self.tableViews count];
    
    containerFrame.size.width = self.tableViewsPaddingInsets.left + self.tableViewsPaddingInsets.right + (self.tableViewSize.width * tableViewCount);
    containerFrame.size.height = self.tableViewsPaddingInsets.top + self.tableViewsPaddingInsets.bottom + self.tableViewSize.height;
    
    CGRect viewFrame = containerFrame;
    CGSize currentMaxSize = [self currentMaxSize];
    if (viewFrame.size.height > currentMaxSize.height)
    {
        viewFrame.size.height = currentMaxSize.height;
    }
    
    if (viewFrame.size.width > currentMaxSize.width)
    {
        viewFrame.size.width = currentMaxSize.width;
    }
    
    self.view.frame = viewFrame;
    self.scrollView.contentSize = containerFrame.size;
    
    
    CGPoint offset = CGPointMake(containerFrame.size.width - self.view.frame.size.width, containerFrame.size.height - self.view.frame.size.height);
    [self.scrollView setContentOffset:offset animated:animated];
    
    [self.popController setPopoverContentSize:self.view.frame.size animated:animated];
}

- (CGSize)currentMaxSize
{
    CGSize currentMaxSize = self.maxSizeLandscape;
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        currentMaxSize = self.maxSizePortrait;
    }
    return currentMaxSize;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<SDExpandingTableViewColumnDelegate> column = self.tableViewToIdentifier[@(tableView.tag)];
    [self.delegate didSelectRowAtIndexPath:indexPath inColumn:column forTableView:tableView];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSInteger rowCount = 0;
    id<SDExpandingTableViewColumnDelegate> column = self.tableViewToIdentifier[@(tableView.tag)];
    if (nil != column)
    {
        rowCount = [self.dataSource numberOfRowsInColumn:column section:section];
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

@end
