//
//  ViewController.m
//  JiveFetchedResultsControllerDelegateDemo
//
//  Created by Heath Borders on 10/12/15.
//  Copyright © 2015 Heath Borders. All rights reserved.
//


#import "ViewController.h"
#import <CoreData/CoreData.h>
#import <JiveFetchedResultsControllerDelegate/JiveFetchedResultsControllerDelegate.h>
#import "Entity.h"

static BOOL useInMemoryPersistentStore = NO;
#define ADD_REMOVE_FETCHED_OBJECTS_WITH_UPDATES 0
#define USE_JIVE_FETCHED_RESULTS_CONTROLLER_DELEGATE 1
static BOOL useUpdatedManagedObjectsWorkaround = YES;

@interface NSManagedObjectContext(ViewController)

- (NSManagedObjectID *)insertAndSaveEntityWithActive:(BOOL)active
                                                name:(NSString *)name
                                               order:(double)order;
- (Entity *)insertEntityWithActive:(BOOL)active
                              name:(NSString *)name
                             order:(double)order;

- (void)updateEntityWithID:(NSManagedObjectID *)entityID
                    active:(NSNumber *)active
                      name:(NSString *)name
                     order:(NSNumber *)order;

- (void)deleteEntityWIthID:(NSManagedObjectID *)entityID;

@end

NSString *stringFromFetchedResultsChangeType(NSFetchedResultsChangeType type) {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            return @"Insert";
        case NSFetchedResultsChangeDelete:
            return @"Delete";
        case NSFetchedResultsChangeUpdate:
            return @"Update";
        case NSFetchedResultsChangeMove:
            return @"Move";
    }
}

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSManagedObjectContext *fetchedResultsControllerManagedObjectContext;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

#if USE_JIVE_FETCHED_RESULTS_CONTROLLER_DELEGATE
@property (nonatomic) JiveFetchedResultsControllerDelegate *jiveFetchedResultsControllerDelegate;
#endif

@property (nonatomic) NSManagedObjectID *entityAa02ID;
@property (nonatomic) NSManagedObjectID *entityBb01ID;
@property (nonatomic) NSManagedObjectID *entityC_ID;
#if ADD_REMOVE_FETCHED_OBJECTS_WITH_UPDATES
@property (nonatomic) NSManagedObjectID *entity_c03ID;
#endif
@property (nonatomic) NSManagedObjectID *entityD_ID;
@property (nonatomic) NSManagedObjectID *entityEe09ID;
@property (nonatomic) NSManagedObjectID *entityFF06ID;
@property (nonatomic) NSManagedObjectID *entityGg07ID;
#if ADD_REMOVE_FETCHED_OBJECTS_WITH_UPDATES
@property (nonatomic) NSManagedObjectID *entity_h08ID;
#endif
@property (nonatomic) NSManagedObjectID *entityJJ11ID;
@property (nonatomic) NSManagedObjectID *entityKK10ID;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"]]];
    
    if (useInMemoryPersistentStore) {
        if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                           configuration:nil
                                                                     URL:nil
                                                                 options:nil
                                                                   error:NULL]) {
            abort();
        }
    } else {
        NSURL *documentsURL = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]];
        // force each invocation to get a unique database
        NSURL *sqliteURL = [documentsURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
        if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                           configuration:nil
                                                                     URL:sqliteURL
                                                                 options:nil
                                                                   error:NULL]) {
            abort();
        }
    }
    
    NSManagedObjectContext *insertingManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    insertingManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    [insertingManagedObjectContext performBlockAndWait:^{
        self.entityAa02ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"A (will become 'a', switch with 'B')"
                                                                                   order:1];
        self.entityBb01ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"B (will become 'b', switch with 'A')"
                                                                                   order:2];
        self.entityC_ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                  name:@"C (will become 'c')"
                                                                                 order:3];
#if ADD_REMOVE_FETCHED_OBJECTS_WITH_UPDATES
        self.entity_c03ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:NO
                                                                                    name:@"c"
                                                                                   order:3];
#endif
        self.entityD_ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                  name:@"D (will disappear)"
                                                                                 order:4];
        self.entityEe09ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"E (will become 'e', move below inserted 'h')"
                                                                                   order:5];
        self.entityFF06ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"F (will remain unchanged)"
                                                                                   order:6];
        self.entityGg07ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"G (will become 'g')"
                                                                                   order:7];
#if ADD_REMOVE_FETCHED_OBJECTS_WITH_UPDATES
        self.entity_h08ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:NO
                                                                                    name:@"h"
                                                                                   order:8];
#endif
        self.entityJJ11ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"J (will switch with 'K')"
                                                                                   order:10];
        self.entityKK10ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"K (will switch with 'J')"
                                                                                   order:11];
    }];
    
    self.fetchedResultsControllerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.fetchedResultsControllerManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"active == true"];
    fetchRequest.sortDescriptors = @[
                                     [NSSortDescriptor sortDescriptorWithKey:@"order"
                                                                   ascending:YES],
                                     ];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.fetchedResultsControllerManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
#if USE_JIVE_FETCHED_RESULTS_CONTROLLER_DELEGATE
    self.jiveFetchedResultsControllerDelegate = [[JiveFetchedResultsControllerDelegate alloc] initWithTableView:self.tableView];
    self.fetchedResultsController.delegate = self.jiveFetchedResultsControllerDelegate;
#else
    self.fetchedResultsController.delegate = self;
#endif
    if (![self.fetchedResultsController performFetch:NULL]) {
        abort();
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(managedObjectContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.fetchedResultsController.fetchedObjects.count;
        case 1:
            return 1;
        default:
            NSLog(@"Unexpected section: %@", @(section));
            abort();
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"cell"];
            }
            Entity *entity = self.fetchedResultsController.fetchedObjects[indexPath.row];
            if (entity) {
                cell.textLabel.text = entity.name;
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"Unexpected object in row: %@",
                                       @(indexPath.row)];
            }
            
            return cell;
        }
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"button"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"button"];
            }
            cell.textLabel.text = @"Change Data";
            return cell;
        }
            
        default:
            NSLog(@"Unexpected indexPath section: %@", @(indexPath.section));
            abort();
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        NSManagedObjectContext *updatingManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        updatingManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        [updatingManagedObjectContext performBlockAndWait:^{
            [updatingManagedObjectContext updateEntityWithID:self.entityBb01ID
                                              active:nil
                                                name:@"b"
                                               order:@(1)];
            [updatingManagedObjectContext updateEntityWithID:self.entityAa02ID
                                              active:nil
                                                name:@"a"
                                               order:@(2)];
            
#if ADD_REMOVE_FETCHED_OBJECTS_WITH_UPDATES
            [managedObjectContext updateEntityWithID:self.entityC_ID
                                              active:@NO
                                                name:nil
                                               order:nil];
            [managedObjectContext updateEntityWithID:self.entity_c03ID
                                              active:@YES
                                                name:nil
                                               order:nil];
            [managedObjectContext updateEntityWithID:self.entityD_ID
                                              active:@NO
                                                name:nil
                                               order:nil];
#else
            [updatingManagedObjectContext deleteEntityWIthID:self.entityC_ID];
            Entity *entity_c03 = [updatingManagedObjectContext insertEntityWithActive:YES
                                                                         name:@"c"
                                                                        order:3];
            [updatingManagedObjectContext deleteEntityWIthID:self.entityD_ID];
#endif
            // entityFF06 is unchanged
            [updatingManagedObjectContext updateEntityWithID:self.entityGg07ID
                                              active:nil
                                                name:@"g"
                                               order:nil];
            
#if ADD_REMOVE_FETCHED_OBJECTS_WITH_UPDATES
            [managedObjectContext updateEntityWithID:self.entity_h08ID
                                              active:@YES
                                                name:nil
                                               order:nil];
#else
            Entity *entity_h08 = [updatingManagedObjectContext insertEntityWithActive:YES
                                                                         name:@"h (will be inserted between 'g' and 'e')"
                                                                        order:8];
#endif
            
            [updatingManagedObjectContext updateEntityWithID:self.entityEe09ID
                                              active:nil
                                                name:@"e"
                                               order:@(9)];
            [updatingManagedObjectContext updateEntityWithID:self.entityKK10ID
                                              active:nil
                                                name:nil
                                               order:@(10)];
            [updatingManagedObjectContext updateEntityWithID:self.entityJJ11ID
                                              active:nil
                                                name:nil
                                               order:@(11)];
            
            [updatingManagedObjectContext save:NULL];
            
#if ADD_REMOVE_FETCHED_OBJECTS_WITH_UPDATES
#else
            // wait until after saving to print objectIDs since they change after the initial save.
            NSLog(@"inserted %@ as %@", entity_c03.name, entity_c03.objectID);
            NSLog(@"inserted %@ as %@", entity_h08.name, entity_h08.objectID);
#endif
        }];
        
        NSManagedObjectContext *fetchingManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        fetchingManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        [fetchingManagedObjectContext performBlockAndWait:^{
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"active == true"];
            fetchRequest.sortDescriptors = @[
                                             [NSSortDescriptor sortDescriptorWithKey:@"order"
                                                                           ascending:YES],
                                             ];
            
            NSArray *entities = [fetchingManagedObjectContext executeFetchRequest:fetchRequest
                                                                    error:NULL];
            if (entities) {
                NSLog(@"Begin expected data");
                for (Entity *entity in entities) {
                    NSLog(@"%@", entity.name);
                }
                NSLog(@"End expected data");
            } else {
                abort();
            }
        }];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    Entity *entity = anObject;
    NSLog(@"entity: %@, type: %@, indexPath: %@, newIndexPath: %@",
          entity.name,
          stringFromFetchedResultsChangeType(type),
          indexPath ? @(indexPath.row) : nil,
          newIndexPath ? @(newIndexPath.row) : nil);
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
                [self.tableView insertRowsAtIndexPaths: @[
                                                          newIndexPath,
                                                          ]
                                      withRowAnimation:UITableViewRowAnimationFade];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeDelete:
            if (indexPath && !newIndexPath) {
                [self.tableView deleteRowsAtIndexPaths:@[
                                                         indexPath,
                                                         ]
                                      withRowAnimation:UITableViewRowAnimationLeft];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeMove:
            if (indexPath && newIndexPath) {
                [self.tableView moveRowAtIndexPath:indexPath
                                       toIndexPath:newIndexPath];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeUpdate:
            if (indexPath && !newIndexPath) {
                [self.tableView reloadRowsAtIndexPaths:@[
                                                         indexPath,
                                                         ]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                abortWithUnexpected();
            }
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - notifications

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    NSManagedObjectContext *(^findSavingManagedObjectContext)(NSString *) = ^(NSString *key) {
        NSSet *managedObjects = notification.userInfo[key];
        for (NSManagedObject *managedObject in managedObjects) {
            NSManagedObjectContext *managedObjectContext = managedObject.managedObjectContext;
            if (managedObjectContext) {
                return managedObjectContext;
            } else {
                // NSManagedObjectContexts and NSManagedObjects don't retain each other by default
                // so it's legal for `managedObject.managedObjectContext` to be nil.
            }
        }
        
        return (NSManagedObjectContext *)nil;
    };
    
    NSManagedObjectContext *savingManagedObjectContext = findSavingManagedObjectContext(NSInsertedObjectsKey);
    if (!savingManagedObjectContext) {
        savingManagedObjectContext = findSavingManagedObjectContext(NSUpdatedObjectsKey);
    }
    if (!savingManagedObjectContext) {
        savingManagedObjectContext = findSavingManagedObjectContext(NSDeletedObjectsKey);
    }
    
    if (savingManagedObjectContext &&
        savingManagedObjectContext.persistentStoreCoordinator == self.persistentStoreCoordinator &&
        savingManagedObjectContext != self.fetchedResultsControllerManagedObjectContext) {
        void (^printEntitiesForUserInfoKey)(NSString *) = ^(NSString *key) {
            NSLog(@"Begin %@", key);
            
            for (Entity *entity in notification.userInfo[key]) {
                NSLog(@"Entity(active: %@, name: %@, order: %@)",
                      @(entity.active),
                      entity.name,
                      @(entity.order));
            }
            
            NSLog(@"End %@", key);
        };
        
        printEntitiesForUserInfoKey(NSInsertedObjectsKey);
        printEntitiesForUserInfoKey(NSUpdatedObjectsKey);
        printEntitiesForUserInfoKey(NSDeletedObjectsKey);
        
        if (useUpdatedManagedObjectsWorkaround) {
            // this method is guaranteed to be called on the saving NSManagedObjectContext's thread.
            // thus, it is only safe to access the updated NSManagedObjects from here.
            NSMutableArray *updatedOrMovedManagedObjectIDs = [NSMutableArray new];
            void (^appendManagedObjectIDsFromNSSetInUserInfoWithKey)(NSString *) = ^(NSString *key) {
                for (NSManagedObject *managedObject in notification.userInfo[key]) {
                    [updatedOrMovedManagedObjectIDs addObject:managedObject.objectID];
                }
            };
            appendManagedObjectIDsFromNSSetInUserInfoWithKey(NSUpdatedObjectsKey);
            [self.fetchedResultsControllerManagedObjectContext performBlock:^{
                // Fix/workaround from http://stackoverflow.com/a/3927811/9636
                for (NSManagedObjectID *updatedManagedObjectID in updatedOrMovedManagedObjectIDs) {
                    [[self.fetchedResultsControllerManagedObjectContext objectWithID:updatedManagedObjectID] willAccessValueForKey:nil];
                }
                [self.fetchedResultsControllerManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            }];
        } else {
            // this method is guaranteed to be called on the saving NSManagedObjectContext's thread.
            // we're allowed to pass a notification from this thread into mergeChangesFromContextDidSaveNotification,
            // but the documentation doesn't say we're allowed to call mergeChangesFromContextDidSaveNotification
            // from the other thread, so out of caution, we call it on fetchedResultsControllerManagedObjectContext's.
            [self.fetchedResultsControllerManagedObjectContext performBlock:^{
                [self.fetchedResultsControllerManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            }];
        }
    }
}

@end

@implementation NSManagedObjectContext(ViewController)

- (NSManagedObjectID *)insertAndSaveEntityWithActive:(BOOL)active
                                                name:(NSString *)name
                                               order:(double)order {
    Entity *entity = [self insertEntityWithActive:active
                                             name:name
                                            order:order];
    
    [self save:NULL];
    
    NSLog(@"Inserted and saved %@ as %@", name, entity.objectID);
    
    return entity.objectID;
}

- (Entity *)insertEntityWithActive:(BOOL)active
                              name:(NSString *)name
                             order:(double)order {
    Entity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Entity"
                                                   inManagedObjectContext:self];
    entity.active = active;
    entity.name = name;
    entity.order = order;
    
    return entity;
}

- (void)updateEntityWithID:(NSManagedObjectID *)entityID
                    active:(NSNumber *)active
                      name:(NSString *)name
                     order:(NSNumber *)order {
    Entity *entity = (Entity *)[self objectWithID:entityID];
    if (active) {
        entity.active = [active boolValue];
    }
    if (name) {
        entity.name = name;
    }
    if (order) {
        entity.order = [order doubleValue];
    }
}

- (void)deleteEntityWIthID:(NSManagedObjectID *)entityID {
    [self deleteObject:[self objectWithID:entityID]];
}

@end