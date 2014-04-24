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

@interface NSString(hello)<SDExpandingTableViewProtocol>
- (NSString *)identifier;
@end

@implementation NSString(hello)

- (NSString *)identifier
{
    return self;
}

@end

@interface SDViewController ()<SDExpandingTableViewControllerDataSource>
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
    
    
    self.data = @[
                  @{kIdKey:@"Food",
                    kDataKey: @[
                                @{kIdKey:@"Fresh Fruit",
                                  kDataKey:@[
                                          @{kIdKey:@"Fruit",
                                            kDataKey:@[]},
                                          @{kIdKey:@"Vegtable",
                                            kDataKey:@[]},
                                          @{kIdKey:@"Potatoes",
                                            kDataKey:@[]}
                                          ]},
                                @{kIdKey:@"Fresh Meat",
                                  kDataKey:@[
                                          @{kIdKey:@"Roast Dinners",
                                            kDataKey:@[]},
                                          @{kIdKey:@"Sausage",
                                            kDataKey:@[]},
                                          @{kIdKey:@"Beef",
                                            kDataKey:@[]}
                                          ]},
                                @{kIdKey:@"Dairy & Eggs",
                                  kDataKey:@[]},
                                @{kIdKey:@"Chilled",
                                  kDataKey:@[]}
                                ]
                    },
                  
                  @{kIdKey:@"Drinks",
                    kDataKey: @[
                            @{kIdKey:@"Hot Drinks",
                              kDataKey:@[]},
                            @{kIdKey:@"Soft Drinks",
                              kDataKey:@[]},
                            @{kIdKey:@"Hard Drinks",
                              kDataKey:@[
                                      @{kIdKey:@"Vodka",
                                        kDataKey:@[]},
                                      @{kIdKey:@"Rum",
                                        kDataKey:@[]},
                                      @{kIdKey:@"Whiskey",
                                        kDataKey:@[]}
                                      ]},
                            @{kIdKey:@"Medium Drinks",
                              kDataKey:@[
                                      @{kIdKey:@"Coke",
                                        kDataKey:@[]},
                                      @{kIdKey:@"Cherry Coke",
                                        kDataKey:@[]},
                                      @{kIdKey:@"hello",
                                        kDataKey:@[]}
                                      ]}
                            ]
                    },
                  
                  @{kIdKey:@"Laundry",
                    kDataKey: @[
                            @{kIdKey:@"Laundry & household",
                              kDataKey:@[]},
                            @{kIdKey:@"Pets",
                              kDataKey:@[]},
                            @{kIdKey:@"Batteries",
                              kDataKey:@[]},
                            @{kIdKey:@"Car Care",
                              kDataKey:@[]}
                            ]
                    }
                  ];
    
    self.level0 = @{@"root":@[@"Food",@"Drinks",@"Laundry"]};
    
    self.level1 = @{@"Food":@[@"Fresh Fruit", @"Fresh Meat", @"Dairy & Eggs", @"Chilled"],
                             @"Drinks":@[@"Hot Drinks", @"Soft Drinks", @"Hard Drinks"],
                             @"Laundry":@[@"Pets", @"Car care"]};
    
    self.level2 = @{@"Fresh Fruit":@[@"Fruit", @"Vegtables", @"Potates"],
                             @"FreshMeat":@[@"Roast Dinners", @"Sausage", @"Beef"],
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
    self.expandingVC = [[SDExpandingTableViewController alloc] initWithTableViewIdentifier:@"root" tableViewStyle:UITableViewStylePlain];
    self.expandingVC.dataSource = self;
    self.popover = [[UIPopoverController alloc] initWithContentViewController:self.expandingVC];
    [self.popover presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (NSArray *)dataForID:(id<SDExpandingTableViewProtocol>)identifier
{
    NSArray *data = [self.level1 objectForKey:identifier.identifier];
    if (!data)
    {
        data = [self.level2 objectForKey:identifier.identifier];
    }
    
    if (!data)
    {
        data = [self.level0 objectForKey:identifier.identifier];
    }
    return data;
}


- (UITableViewCell *)cellForRowAtIndexPath:(SDIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    NSArray *data = [self dataForID:indexPath.tableIdentifier];
    NSString *item = [data objectAtIndex:indexPath.indexPath.row];
    cell.textLabel.text = item;
    return cell;
}

- (NSInteger)numberOfRowsInTableView:(id<SDExpandingTableViewProtocol>)table section:(NSInteger)section
{
    NSArray *data = [self dataForID:table];
    return [data count];
}

- (NSArray *)childrenIdentifiersForIdentifier:(id<SDExpandingTableViewProtocol>)identifier
{
    NSArray *data = [self dataForID:identifier];
    return data;
}

- (void)didSelectRowAtIndexPath:(SDIndexPath *)indexPath
{
//    NSArray *data = [self dataForID:indexPath.tableIdentifier];
    [self.expandingVC navigateToTableViewWithIdentifier:indexPath.tableIdentifier];
}


@end