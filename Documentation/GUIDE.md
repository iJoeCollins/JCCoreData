# Usage Guide

## Setup and Configuration

1. Drag the files into your project.
2. Import into your prefix file using, #import "JCCoreData.h"

### Basic App Delegate Example
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // Setup the default Core Data stack.
    [JCCoreData setup];

    return YES;
}
```
The setup method in the above example does a few things. 
* It instantiates a singleton instance that can be accessed using [JCCoreData defaultData].
* Registers itself as an observer of UIApplicationWillTerminateNotification (For the purposes of making sure the default context is saved when the application is closed.)
* The setup of the core data stack doesn't actually occur here as we want to delay this until it is actually needed. Which may very well be in the App Delegate, but for the purposes of this example it is not. Just using Core Data later on such as creating a new object will setup the default stack.

### App Delegate Example Using JCCoreData's Category on UIViewController
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UIViewController *viewController = self.window.rootViewController;
    
    viewController.managedObjectContext = [JCCoreData defaultContext];

    return YES;
}
```
The setup method above does the exact same thing as just calling "setup", but it also sets up the default stack and returns an instance of the default managed object context.
**NOTE:** Something here that is not readily apparent is that I am using a category on UIViewController to add a managedObjectContext property to all objects that inherit from UIViewController. This is done using "Associated References" and the objective c runtime.

Having both pros and cons it is just a matter of context when you might decide to use this setup.  It saves me the hassle of having to import view controller subclasses and add core data boiler plate properties to everything. It really doesn't matter what the rootViewController is, it just works. However if it is a container class, you may want to use the correct subclass so you may call for example navigationController.topViewController.managedObjectContext.

Cons would be...because these are associated references setup during runtime, they obviously don't show up in the debugger. Correct me if I am wrong, but I haven't been able to find them! Lol. This just means you have to go about it a little differently if you want a pointer showing up there.

## NSManagedObject Category

Provides a bunch of useful helper methods to insert new objects, find objects, etc.

### NSManagedObject Instantiation example "Before/After JCCoreData"
```objc
// Before
CustomObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"CustomObject" inManagedObjectContext:self.managedObjectContext];

// Now with JCCoreData
CustomObject *object = [CustomObject new];
```

### NSFetchedResultsController setup and instantiation

##### Before
```objc
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"author" ascending:NO];
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = @[authorDescriptor, titleDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"author" cacheName:@"Root"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}    
```

##### After
```objc
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.fetchedResultsController = [Book fetchAllWithDelegate:self sortedBy:@"author:NO,title" groupedBy:@"author" cached:YES];
}
```

Note: the sortedBy: parameter takes a string in the format @"key:ascending,key:ascending". You may also leave off the :ascending as the default is set to YES.

Also of major note, a category is setup on UITableViewController that implements standard NSFetchedResultsControllerDelegate methods. So if you don't have to do anything special, just don't worry about it anymore. The table views will update on their own with JCCoreData.

:]

