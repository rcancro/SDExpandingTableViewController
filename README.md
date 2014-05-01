SDExpandingTableViewController
==============================

SDExpandingTableViewController manages multiple UITableViews to provide an interface very similar to the column mode of finder.  Ideally, this will be used in a UIPopover like this:

![alt text](https://raw.githubusercontent.com/rcancro/SDExpandingTableViewController/master/tableexample.gif "amazing gif demo")

But it doesn't have to be (it was just tested a lot more in a popover....)

## How it works

#### SDExpandingTableViewControllerDataSource
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
It can easily be implemented in a model object class or, like in the example, added to a class like NSString via a category.  The data source also must implement the rootColumnIdentifier method.  This returns the column that is the "root" of the taxonomy tree.  This root is what will appear in the first column of a SDExpandingTableViewController.

#### SDExpandingTableViewControllerDelegate

The client can respond to a (minimal) number of table actions via the SDExpandingTableViewControllerDelegate:
````
@protocol SDExpandingTableViewControllerDelegate<NSObject>
@required
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column forTableView:(UITableView *)tableView;
- (void)didDismissExpandingTables;

@optional
- (void)setupTableView:(UITableView *)tableView forColumn:(id<SDExpandingTableViewColumnDelegate>)column;
@end
````

To create functionality like the example gif above, the client would implement the didSelectRowAtIndexPath:inColumn:forTableView: method.  The client can then look up the children for the object at the indexPath of the column.  Once this data is loaded (from a web service or whatever), the client calls:

````
- (void)navigateToColumn:(id<SDExpandingTableViewColumnDelegate>)column fromParentColumn:(id<SDExpandingTableViewColumnDelegate>)parent animated:(BOOL)animated;
````

on the SDExpandingTableViewController.  From here the SDExpandingTableViewController will handle popping and/or appending new tableviews.

Take a look at the file SDViewController.m to see how this interaction works.  The SDExpandingTableViewController header file is also well commented.

## Importing into your project
To use SDExpandingTableViewController simply add the following files to your project:
* SDExpandingTableViewController.h
* SDExpandingTableViewController.m
* SDMacros.h

That's it!

Please let me know if you have any additions/comments/etc.

This class is part of SetDirection's ios-shared repository.
https://github.com/setdirection/ios-shared

