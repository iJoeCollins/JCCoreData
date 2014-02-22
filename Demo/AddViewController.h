//
//  AddViewController.h
//  JCCoreData
//
//  Created by Joseph Collins on 2/21/14.
//  Copyright (c) 2014 Joseph Collins. All rights reserved.
//

#import "DetailViewController.h"

@protocol AddViewControllerDelegate;


@interface AddViewController : DetailViewController

@property (nonatomic, weak) id <AddViewControllerDelegate> delegate;

@end


@protocol AddViewControllerDelegate

- (void)addViewController:(AddViewController *)controller didFinishWithSave:(BOOL)save;

@end