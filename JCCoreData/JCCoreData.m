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

static NSManagedObjectContext *defaultManagedObjectContext_ = nil;

@implementation JCCoreData

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

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
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
        
        defaultManagedObjectContext_ = _managedObjectContext;
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
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[JCCoreData applicationModelFile]];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath:[JCCoreData applicationStoreDirectory].path];
    
    if (!dirExists) {
        [[NSFileManager defaultManager] createDirectoryAtURL:[JCCoreData applicationStoreDirectory]
                                 withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[JCCoreData applicationStoreFile] options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - Save Context Method

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}


#pragma mark - Shared Default Context

+ (NSManagedObjectContext *)defaultContext
{
    @synchronized(self) {
        NSAssert(defaultManagedObjectContext_ != nil, @"You have not initialized the Core Data Stack!");
        
        return defaultManagedObjectContext_;
    }
}


#pragma mark - Store Files and Directories

+ (NSURL *)applicationModelFile
{
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    NSString *underscoredName = [applicationName stringByReplacingOccurrencesOfString:@" " withString:@"_"];

    return [[NSBundle mainBundle] URLForResource:underscoredName withExtension:@"momd"];
}

+ (NSURL *)applicationStoreFile
{
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    NSString *underscoredName = [applicationName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *storeName = [underscoredName stringByAppendingPathExtension:@"sqlite"];
    
    return [[JCCoreData applicationStoreDirectory] URLByAppendingPathComponent:storeName];
}

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationStoreDirectory
{
    NSURL *docDir = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    return [docDir URLByAppendingPathComponent:@"Application Data" isDirectory:YES];
}


#pragma mark - Helper Methods

+ (BOOL)firstRun
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[JCCoreData applicationStoreFile].path];
}

@end


#pragma mark - Categories

@implementation NSManagedObject (JCCoreData)

+ (NSEntityDescription *)entityDescriptionInContext:(NSManagedObjectContext *)context;
{
    return [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context];
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

@end


#pragma mark -

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
