//
//  EditingViewController.h
//  JCCoreData
//
//  Created by Joseph Collins on 2/21/14.
//  Copyright (c) 2014 Joseph Collins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditingViewController : UIViewController

@property (nonatomic, strong) NSManagedObject *editedObject;
@property (nonatomic, strong) NSString *editedFieldKey;
@property (nonatomic, strong) NSString *editedFieldName;

@end
