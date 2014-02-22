//
//  JCCoreData.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface JCCoreData : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)setup;
+ (instancetype)defaultData;

- (void)save;

@end

#pragma mark - Categories

#pragma mark - NSManagedObject

@interface NSManagedObject (JCCoreData)

// Create Objects
+ (instancetype)new;
+ (instancetype)newInContext:(NSManagedObjectContext *)context;

// Delete Objects
- (void)delete;

// Get Objects
+ (NSArray *)findAllObjects;
+ (NSArray *)findAllObjectsInContext:(NSManagedObjectContext *)context;
+ (NSFetchedResultsController *)fetchAllWithDelegate:(id <NSFetchedResultsControllerDelegate>)delegate sortedBy:(NSString *)sortTerm groupedBy:(NSString *)groupTerm cached:(BOOL)isCached;

// Get Objects Entity Descriptions
+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;

@end

#pragma mark - NSFetchedResultsController

@interface NSFetchedResultsController (JCCoreData)
- (NSUInteger)numberOfRowsInSection:(NSInteger)section;
@end

#pragma mark - UITableViewController

@interface UITableViewController (JCCoreData) <NSFetchedResultsControllerDelegate>

// UITableViewController's cell configuration method. This should be subclassed as this implementation does nothing.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// NSFetchedResultsController Delegate Methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;

@end

#pragma mark - UIViewController

@interface UIViewController (JCCoreData)

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSManagedObjectContext *)managedObjectContext;
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
