//
//  DetailViewController.h
//  JCCoreData
//
//  Created by Joseph Collins on 2/21/14.
//  Copyright (c) 2014 Joseph Collins. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Book;

@interface DetailViewController : UITableViewController

@property (nonatomic, strong) Book *book;

@end


// These methods are used by the AddViewController, so are declared here, but they are private to these classes.

@interface DetailViewController (Private)

- (void)setUpUndoManager;
- (void)cleanUpUndoManager;

@end
