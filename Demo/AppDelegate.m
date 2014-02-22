//
//  AppDelegate.m
//  Demo
//
//  Created by Joseph Collins on 2/14/14.
//  Copyright (c) 2014 Joseph Collins. All rights reserved.
//

#import "AppDelegate.h"
#import "JCCoreData.h"

@implementation AppDelegate

#pragma mark - Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // Setup Core Data
    [JCCoreData setup];
}

@end
