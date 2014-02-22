//
//  Book.h
//  JCCoreData
//
//  Created by Joseph Collins on 2/21/14.
//  Copyright (c) 2014 Joseph Collins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * copyright;
@property (nonatomic, retain) NSString * title;

@end
