//
//  AuthorsViewController.m
//  JCCoreData
//
//  Created by Joseph Collins on 2/21/14.
//  Copyright (c) 2014 Joseph Collins. All rights reserved.
//

#import "AuthorsViewController.h"
#import "DetailViewController.h"
#import "Book.h"


@interface AuthorsViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@end


#pragma mark -

@implementation AuthorsViewController


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set up the edit and add buttons.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.fetchedResultsController = [Book fetchAllWithDelegate:self sortedBy:@"author,title" groupedBy:@"author" cached:YES];
}


- (void)viewWillAppear {
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.fetchedResultsController numberOfRowsInSection:section];
}


// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = book.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // Display the authors' names as section headings.
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        Book *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [book delete];
    }
}


#pragma mark - Table view editing

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // The table view should not be re-orderable.
    return NO;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    if (editing) {
        self.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
        self.rightBarButtonItem = nil;
    }
}


#pragma mark - Segue management

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"AddBook"]) {
        
        /*
         The destination view controller for this segue is an AddViewController to manage addition of the book.
         This block creates a new managed object context as a child of the root view controller's context. It then creates a new book using the child context. This means that changes made to the book remain discrete from the application's managed object context until the book's context is saved.
         The root view controller sets itself as the delegate of the add controller so that it can be informed when the user has completed the add operation -- either saving or canceling (see addViewController:didFinishWithSave:).
         IMPORTANT: It's not necessary to use a second context for this. You could just use the existing context, which would simplify some of the code -- you wouldn't need to perform two saves, for example. This implementation, though, illustrates a pattern that may sometimes be useful (where you want to maintain a separate set of edits).
         */
        
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        AddViewController *addViewController = (AddViewController *)[navController topViewController];
        addViewController.delegate = self;
        
        // Create a new managed object context for the new book; set its parent to the fetched results controller's context.
        NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [addingContext setParentContext:[self.fetchedResultsController managedObjectContext]];
        
        addViewController.book = [Book newInContext:addingContext];
        addViewController.managedObjectContext = addingContext;
    }
    
    if ([[segue identifier] isEqualToString:@"ShowSelectedBook"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Book *selectedBook = (Book *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        // Pass the selected book to the new view controller.
        DetailViewController *detailViewController = (DetailViewController *)[segue destinationViewController];
        detailViewController.book = selectedBook;
    }
}


#pragma mark - Add controller delegate

/*
 Add controller's delegate method; informs the delegate that the add operation has completed, and indicates whether the user saved the new book.
 */
- (void)addViewController:(AddViewController *)controller didFinishWithSave:(BOOL)save {
    
    if (save) {
        /*
         The new book is associated with the add controller's managed object context.
         This means that any edits that are made don't affect the application's main managed object context -- it's a way of keeping disjoint edits in a separate scratchpad. Saving changes to that context, though, only push changes to the fetched results controller's context. To save the changes to the persistent store, you have to save the fetch results controller's context as well.
         */
        NSError *error;
        NSManagedObjectContext *addingManagedObjectContext = [controller managedObjectContext];
        if (![addingManagedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    // Dismiss the modal view to return to the main list
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
