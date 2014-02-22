//
//  AppDelegate.m
//  Demo
//
//  Created by Joseph Collins on 2/14/14.
//  Copyright (c) 2014 Joseph Collins. All rights reserved.
//

#import "AppDelegate.h"
#import "JCCoreData.h"
#import "AuthorsViewController.h"

@implementation AppDelegate

#pragma mark - Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // Override point for customization after application launch.
    
    // Setup Core Data
    JCCoreData *coreData = [JCCoreData defaultData];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    AuthorsViewController *authorsViewController = (AuthorsViewController *)[[navigationController viewControllers] objectAtIndex:0];
    authorsViewController.managedObjectContext = coreData.managedObjectContext;
}

@end
