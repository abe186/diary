//
//  DYNoteStorage.m
//  Diary
//
//  Created by Jon Manning on 6/01/2014.
//  Copyright (c) 2014 Secret Lab. All rights reserved.
//

#import "DYNoteStorage.h"

static DYNoteStorage* _sharedStorage;

@interface DYNoteStorage ()

@property (nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic) NSManagedObjectModel* managedObjectModel;
@property (nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation DYNoteStorage {
}

+ (DYNoteStorage*) sharedStorage {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedStorage = [[DYNoteStorage alloc] init];
    });
    
    return _sharedStorage;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel*) managedObjectModel {
    
    if (_managedObjectModel != nil)
        return _managedObjectModel;
    
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"Diary" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
    
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil)
        return _managedObjectContext;
    
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator*) persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil)
        return _persistentStoreCoordinator;
    

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Diary.sqlite"];
    
    NSError* error = nil;
    
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    if (error != nil) {
        NSLog(@"Failed to open the store! Error: %@", error);
        _persistentStoreCoordinator = nil;
        return nil;
    }
    
    return _persistentStoreCoordinator;
    
}

- (DYNote *)createNote {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    
    DYNote* newNote = [NSEntityDescription insertNewObjectForEntityForName:entity.name inManagedObjectContext:self.managedObjectContext];
    
    NSError* error = nil;
    
    [self.managedObjectContext save:&error];
    
    if (error != nil) {
        NSLog(@"Couldn't save the context: %@", error);
        return nil;
    }
    
    return newNote;
}

- (void)deleteNote:(DYNote *)note {
    [self.managedObjectContext deleteObject:note];
    
    NSError* error = nil;
    
    [self.managedObjectContext save:&error];
    
    if (error != nil) {
        NSLog(@"Couldn't save the context: %@", error);
    }
}


- (NSFetchedResultsController *)createFetchedResultsController {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    
    fetchRequest.fetchBatchSize = 20;
    
    // Sort the results in order of most recently edited.
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"modifiedDate" ascending:NO];
    
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    NSFetchedResultsController* newFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest // What to look for
                                            managedObjectContext:self.managedObjectContext // Where to find it
                                              sectionNameKeyPath:nil // How to group them (nil = no sections)
                                                       cacheName:@"MainCache"]; // Where to cache them
    
    return newFetchedResultsController;
}


@end
