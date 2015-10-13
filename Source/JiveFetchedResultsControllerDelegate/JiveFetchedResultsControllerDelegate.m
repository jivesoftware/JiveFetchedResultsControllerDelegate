//
//  JiveFetchedResultsControllerDelegate.m
//  Pods
//
//  Created by Heath Borders on 10/12/15.
//
//

#import "JiveFetchedResultsControllerDelegate.h"

static NSString *stringFromFetchedResultsChangeType(NSFetchedResultsChangeType type) {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            return @"Insert";
        case NSFetchedResultsChangeDelete:
            return @"Delete";
        case NSFetchedResultsChangeMove:
            return @"Move";
        case NSFetchedResultsChangeUpdate:
            return @"Update";
    }
}

@interface JiveFetchedResultsControllerDelegate()

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic) NSMutableIndexSet *insertedSectionIndexes;

@property (nonatomic) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic) NSMutableArray *updatedRowIndexPaths;

// When building against iOS9, if an entity moves and needs an update,
// we get an update change and then a move change. However, UITableView
// crashes when we do this:
// Without JiveFetchedResultsControllerDelegate (simply mapping change types to their UITableView equivalents)
// *** Assertion failure in -[_UITableViewUpdateSupport _setupAnimationsForExistingVisibleCells], /SourceCache/UIKit_Sim/UIKit-3347.44.2/UITableViewSupport.m:883
// CoreData: error: Serious application error.  An exception was caught from the delegate of NSFetchedResultsController during a call to -controllerDidChangeContent:.  Attempt to create two animations for cell with userInfo (null)

// With JiveFetchedResultsControllerDelegate, but without stopping the update:
// *** Assertion failure in -[UITableView _endCellAnimationsWithContext:], /SourceCache/UIKit_Sim/UIKit-3347.44.2/UITableView.m:1222
// CoreData: error: Serious application error.  An exception was caught from the delegate of NSFetchedResultsController during a call to -controllerDidChangeContent:.  attempt to delete and reload the same index path (<NSIndexPath: 0xc000000000000016> {length = 2, path = 0 - 0}) with userInfo (null)
@property (nonatomic) NSIndexPath *maybePreMoveUpdateIndexPath;

@end

@implementation JiveFetchedResultsControllerDelegate

- (instancetype)init {
    @throw nil;
}

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        
        self.deletedSectionIndexes = [NSMutableIndexSet new];
        self.insertedSectionIndexes = [NSMutableIndexSet new];
        
        self.deletedRowIndexPaths = [NSMutableArray new];
        self.insertedRowIndexPaths = [NSMutableArray new];
        self.updatedRowIndexPaths = [NSMutableArray new];
    }
    return self;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // nothing to do
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    void (^abortWithUnexpected)(void) = ^{
        NSLog(@"Unexpected (type, indexPath, newIndexPath): (%@, %@, %@) for object %@ in NSFetchedResultsController: %@",
              @(type),
              indexPath,
              newIndexPath,
              anObject,
              controller);
        abort();
    };
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            if (!indexPath && newIndexPath) {
                [self existingUpdateIndexPathWasNotPreMove];
                if ([self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
                    // If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
                } else {
                    [self.insertedRowIndexPaths addObject:newIndexPath];
                }
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeDelete:
            if (indexPath && !newIndexPath) {
                [self existingUpdateIndexPathWasNotPreMove];
                if ([self.deletedSectionIndexes containsIndex:indexPath.section]) {
                    // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
                } else {
                    [self.deletedRowIndexPaths addObject:indexPath];
                }
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeMove:
            if (indexPath && newIndexPath) {
                if ([indexPath isEqual:self.maybePreMoveUpdateIndexPath]) {
                    // Since we need to delete and reinsert the row to
                    // properly move it, we don't need to update it.
                    self.maybePreMoveUpdateIndexPath = nil;
                } else {
                    [self existingUpdateIndexPathWasNotPreMove];
                }
                // Instead of moving a row around the table, adding and deleting avoids errors that occur when trying to move a row from a deleted section
                // This also causes the UITableView to update any moved rows.
                // -[UITableView moveRowFromIndexPath:toIndexPath:] doesn't reconfigure the cell.
                [self.deletedRowIndexPaths addObject:indexPath];
                [self.insertedRowIndexPaths addObject:newIndexPath];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeUpdate:
            if (indexPath && !newIndexPath) {
                self.maybePreMoveUpdateIndexPath = indexPath;
            } else {
                abortWithUnexpected();
            }
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            break;
        case NSFetchedResultsChangeDelete:
            break;
        default:
            NSLog(@"Unexpected controller: %@, didChangeSection: %@, atIndex: %@, forChangeType: %@",
                  controller,
                  sectionInfo,
                  @(sectionIndex),
                  stringFromFetchedResultsChangeType(type));
            abort();
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self existingUpdateIndexPathWasNotPreMove];
    
    [self.tableView beginUpdates];
    
    [self.tableView deleteSections:self.deletedSectionIndexes
                  withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView insertSections:self.insertedSectionIndexes
                  withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView deleteRowsAtIndexPaths:self.deletedRowIndexPaths
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView insertRowsAtIndexPaths:self.insertedRowIndexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:self.updatedRowIndexPaths
                          withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
    
    self.deletedSectionIndexes = [NSMutableIndexSet new];
    self.insertedSectionIndexes = [NSMutableIndexSet new];
    
    self.deletedRowIndexPaths = [NSMutableArray new];
    self.insertedRowIndexPaths = [NSMutableArray new];
    self.updatedRowIndexPaths = [NSMutableArray new];
}

#pragma mark - Private API

- (void)existingUpdateIndexPathWasNotPreMove {
    if (self.maybePreMoveUpdateIndexPath) {
        // there are no more updates, so it wasn't a pre-move update. :)
        [self.updatedRowIndexPaths addObject:self.maybePreMoveUpdateIndexPath];
        self.maybePreMoveUpdateIndexPath = nil;
    }
}

@end
