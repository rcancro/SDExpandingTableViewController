//
//  SDViewController.m
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 My name is kuma. All rights reserved.
//

#import "SDViewController.h"
#import "SDExpandingTableViewController.h"

static NSString const *kIdKey = @"identifier";
static NSString const *kDataKey = @"data";

@interface NSString(SDExpandingTableViewColumnDelegate)<SDExpandingTableViewColumnDelegate>
- (NSString *)identifier;
@end

@implementation NSString(SDExpandingTableViewColumnDelegate)

- (NSString *)identifier
{
    return self;
}

@end

@interface SDViewController ()<SDExpandingTableViewControllerDataSource, SDExpandingTableViewControllerDelegate>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSDictionary *level0;

@property (nonatomic, strong) NSDictionary *level1;
@property (nonatomic, strong) NSDictionary *level2;

@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) SDExpandingTableViewController *expandingVC;
@end

@implementation SDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    

    self.level0 = @{@"root":@[@"Food",@"Drinks",@"Laundry"]};
    
    self.level1 = @{@"Food":@[@"Fresh Fruit", @"Fresh Meat", @"Dairy & Eggs", @"Chilled"],
                             @"Drinks":@[@"Hot Drinks", @"Soft Drinks", @"Hard Drinks"],
                             @"Laundry":@[@"Pets", @"Car care"]};
    
    self.level2 = @{@"Fresh Fruit":@[@"Fruit", @"Vegtables", @"Potates"],
                             @"Fresh Meat":@[@"Roast Dinners", @"Sausage", @"Beef"],
                             @"Hard Drinks":@[@"Vodka", @"Rum", @"Whiskey"],
                             @"Soft Drinks":@[@"Coke", @"Cheery Coke", @"hello"],
                             @"Pets":@[@"Cats", @"Dogs"],
                             @"Car Care":@[@"Car", @"Truck"]};
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapMeAction:(id)sender
{
    self.expandingVC = [[SDExpandingTableViewController alloc] initWithTableViewStyle:UITableViewStylePlain];
    self.expandingVC.dataSource = self;
    self.expandingVC.delegate = self;
    
    [self.expandingVC presentFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (NSArray *)dataForID:(id<SDExpandingTableViewColumnDelegate>)column
{
    NSArray *data = [self.level1 objectForKey:column.identifier];
    if (!data)
    {
        data = [self.level2 objectForKey:column.identifier];
    }
    
    if (!data)
    {
        data = [self.level0 objectForKey:column.identifier];
    }
    return data;
}

- (NSString *)rootColumnIdentifier
{
    return @"root";
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column forTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    NSArray *data = [self dataForID:column];
    NSString *item = [data objectAtIndex:indexPath.row];
    cell.textLabel.text = item;
    return cell;
}

- (NSInteger)numberOfRowsInColumn:(id<SDExpandingTableViewColumnDelegate>)column section:(NSInteger)section
{
    NSArray *data = [self dataForID:column];
    return [data count];
}

- (NSInteger)numberOfSectionsInColumn:(id<SDExpandingTableViewColumnDelegate>)table forTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)numberOfRowsInColumn:(id<SDExpandingTableViewColumnDelegate>)column section:(NSInteger)section forTableView:(UITableView *)tableView
{
    NSArray *data = [self dataForID:column];
    return [data count];
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column forTableView:(UITableView *)tableView
{
    NSArray *data = [self dataForID:column];
    if ([data count] > indexPath.row)
    {
        NSString *tableId = data[indexPath.row];
        [self.expandingVC navigateToColumn:tableId fromParentColumn:column animated:YES];
    }
}

- (void)didDismissExpandingTables
{
    [self.expandingVC removeFromParentViewController];
    [self.expandingVC.view removeFromSuperview];
}

@end
