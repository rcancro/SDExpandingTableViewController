SDExpandingTableViewController
==============================

SDExpandingTableViewController manages multiple UITableViews to provide an interface very similar to the column mode of finder.  Ideally, this will be used in a UIPopover like this:

![alt text](https://raw.githubusercontent.com/rcancro/SDExpandingTableViewController/master/tableexample.gif "amazing gif demo")

But it doesn't have to be (it was just tested a lot more in a popover....)

## How it works
SDExpandingTableViewController creates a UITableView for each "column" in its view and becomes the UITableViewDelegate and UITableViewDataSource for each of these UITableViews.  When these data source and delegate methods are called, SDExpandingTableViewController asks its own data source and delegate for the proper result.

````
@protocol SDExpandingTableViewControllerDataSource<NSObject>
@required
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column forTableView:(UITableView *)tableView;;
- (NSInteger)numberOfRowsInColumn:(id<SDExpandingTableViewColumnDelegate>)column section:(NSInteger)section;
- (NSInteger)numberOfSectionsInColumn:(id<SDExpandingTableViewColumnDelegate>)column;
- (id<SDExpandingTableViewColumnDelegate>)rootColumnIdentifier;
@end
````

You can see most of these are similar to a UITableView's data source, except that a SDExpandingTableViewColumnDelegate is also passed along. Since the client doesn't have anything to do with the UITableView's, a column is passed so that the proper data can be returned.  The SDExpandingTableViewColumnDelegate is super simple:

````
@protocol SDExpandingTableViewColumnDelegate <NSObject>
@required
- (NSString *)identifier;
@end
````
And can easily be implemented in a model object class or, like in the example, added to a class like NSString via a category.

