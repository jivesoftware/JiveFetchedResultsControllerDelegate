//
//  JiveFetchedResultsControllerDelegate.h
//  Pods
//
//  Created by Heath Borders on 10/12/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

// adapted from http://www.fruitstandsoftware.com/blog/2013/02/19/uitableview-and-nsfetchedresultscontroller-updates-done-right/
// which we may license with Apache2. 
// https://twitter.com/MrRooni/status/654602640710569984
@interface JiveFetchedResultsControllerDelegate : NSObject<NSFetchedResultsControllerDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTableView:(UITableView *)tableView NS_DESIGNATED_INITIALIZER;

@end
