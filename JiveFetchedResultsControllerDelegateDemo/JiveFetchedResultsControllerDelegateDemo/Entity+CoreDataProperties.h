//
//  Entity+CoreDataProperties.h
//  NSFRC_UITableView
//
//  Created by Heath Borders on 10/9/15.
//  Copyright © 2015 Heath Borders. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Entity.h"

NS_ASSUME_NONNULL_BEGIN

@interface Entity (CoreDataProperties)

@property (nonatomic) BOOL active;
@property (nullable, nonatomic, retain) NSString *name;
@property (nonatomic) double order;

@end

NS_ASSUME_NONNULL_END
