//
//  JCCoreData.m
//
//  Version 1.0
//
//  Created by Joseph Collins on 2/10/14.
//
//  Distributed under The MIT License (MIT)
//  Get the latest version here:
//
//  http://www.github.com/ijoecollins/JCCoreData
//
//  Copyright (c) 2014 Joseph Collins.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "JCCoreData.h"
#import <objc/runtime.h>

static NSString *const kJCCoreDataModelFileName = @"Model";
static NSString *const kJCCoreDataStoreFileName = @"CoreData";
static NSString *const kJCCoreDataStoreFileExt = @"sqlite";
static NSUInteger kJCCoreDataBatchSize = 20;

@interface JCCoreData ()
+ (NSManagedObjectContext *)defaultContext;
@end

@implementation JCCoreData

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Setup Methods

+ (instancetype)setup
{
    return [self defaultData];
}

#pragma mark - Initializers and lifetime management

static JCCoreData *defaultData = nil;

+ (JCCoreData *)defaultData
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        defaultData = [[JCCoreData alloc] init];
        
    });
    
    return defaultData;
}

- (instancetype)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:UIApplicationWillTerminateNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[JCCoreData defaultModelFile]];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath:[JCCoreData defaultStoreDirectory].path];
    
    if (!dirExists) {
        [[NSFileManager defaultManager] createDirectoryAtURL:[JCCoreData defaultStoreDirectory]
                                 withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSURL *storeURL = [JCCoreData defaultStoreFile];
    
    // Check if store file exists in main bundle
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:[storeURL path]]) {
        NSString *resource = [[storeURL lastPathComponent] stringByDeletingPathExtension];
        NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:resource withExtension:kJCCoreDataStoreFileExt];
        
        if (defaultStoreURL) {
            [fileManager copyItemAtURL:defaultStoreURL toURL:storeURL error:NULL];
        }
    }

    NSError *error = nil;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Save Method

- (void)save
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

#pragma mark - Default Store Files and Directories

+ (NSURL *)defaultModelFile
{
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    
    if (!applicationName) {
        applicationName = kJCCoreDataModelFileName;
    }
    
    // Default templates replace any spaces in the project name with underscores
    NSString *underscoredName = [applicationName stringByReplacingOccurrencesOfString:@" " withString:@"_"];

    return [[NSBundle mainBundle] URLForResource:underscoredName withExtension:@"momd"];
}

+ (NSURL *)defaultStoreFile
{
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    
    if (!applicationName) {
        applicationName = kJCCoreDataStoreFileName;
    }
    
    // Default templates replace any spaces in the project name with underscores
    NSString *underscoredName = [applicationName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    NSString *storeName = [underscoredName stringByAppendingPathExtension:kJCCoreDataStoreFileExt];
    
    return [[JCCoreData defaultStoreDirectory] URLByAppendingPathComponent:storeName];
}

// Returns the URL to the default store directory: /Documents/Application Data/
+ (NSURL *)defaultStoreDirectory
{
    NSURL *docDir = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    
    return [docDir URLByAppendingPathComponent:@"Application Data" isDirectory:YES];
}

#pragma mark - Helper Methdos

+ (NSManagedObjectContext *)defaultContext
{
    return [[JCCoreData defaultData] managedObjectContext];
}

@end

#pragma mark - Categories

#pragma mark - NSManagedObjectContext

@implementation NSManagedObjectContext (JCCoreData)

@end

#pragma mark - NSManagedObject

@implementation NSManagedObject (JCCoreData)

+ (instancetype)new
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:[JCCoreData defaultContext]];
}

+ (instancetype)newInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

- (void)delete
{
    [self.managedObjectContext deleteObject:self];
    [[JCCoreData defaultData] save];
}

+ (NSArray *)findAllObjects
{
    NSManagedObjectContext *context = [JCCoreData defaultContext];
    
    return [self findAllObjectsInContext:context];
}

+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context;
{
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error != nil) {
        //handle errors
    }
    
    return results;
}

+ (NSFetchedResultsController *)fetchAllWithDelegate:(id <NSFetchedResultsControllerDelegate>)delegate sortedBy:(NSString *)sortTerm groupedBy:(NSString *)groupName cached:(BOOL)isCached
{
    NSManagedObjectContext *context = [JCCoreData defaultContext];
    
    // Create and configure a fetch request with the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [self entityDescriptionInContext:context];
    [fetchRequest setEntity:entity];
    
    // Set Batch Size
    [fetchRequest setFetchBatchSize:kJCCoreDataBatchSize];
    
    // Add sort descriptors
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    BOOL ascending = YES;
    NSArray* sortKeys = [sortTerm componentsSeparatedByString:@","];
    for (NSString * __strong sortKey in sortKeys)
    {
        NSArray * sortComponents = [sortKey componentsSeparatedByString:@":"];
        if (sortComponents.count > 1)
        {
            sortKey = sortComponents[0];
            ascending = [sortComponents[1] boolValue];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        [sortDescriptors addObject:sortDescriptor];
    }
    
	[fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString *cacheName = nil;
    if (isCached) {
        cacheName = @"Root";
    }
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:groupName cacheName:cacheName];
    fetchedResultsController.delegate = delegate;
    
    NSError *error;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return fetchedResultsController;
}

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
{
    return [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
}

@end


#pragma mark - NSFetchedResultsController

@implementation NSFetchedResultsController (JCCoreData)

- (NSUInteger)numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

@end

#pragma mark - UITableViewController

@implementation UITableViewController (JCCoreData)

// UITableViewController's cell configuration method. This should be subclassed as this implementation does nothing.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


@end


#pragma mark - UIViewController

@implementation UIViewController (JCCoreData)

- (NSManagedObjectContext *)managedObjectContext
{
    return objc_getAssociatedObject(self, @selector(managedObjectContext));
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)context
{
    objc_setAssociatedObject(self, @selector(managedObjectContext), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
