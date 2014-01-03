//
//  DYNoteListViewController.m
//  Diary
//
//  Created by Jon Manning on 3/01/2014.
//  Copyright (c) 2014 Secret Lab. All rights reserved.
//

#import "DYNoteListViewController.h"
#import "DYNote.h"

// This is a 'class extension', which lets you add methods, properties and variables
// to a class without having to put them in the header file, which other classes can see.
// Anything you put in the class extension can only be accessed by this class.
@interface DYNoteListViewController () {
    NSMutableArray* _notes;
}

@end

@implementation DYNoteListViewController

- (void)viewDidLoad {
    
    // Create the array that stores the notes
    _notes = [NSMutableArray array];
    
    // Create 100 test notes
    
    for (int i = 1; i <= 100; i++) {
        // Make a note
        DYNote* note = [[DYNote alloc] init];
        
        // Create the note's text
        NSString* text = [NSString stringWithFormat:@"Note %i", i];
        note.text = text;
        
        // Add the note to the list
        [_notes addObject:note];
    }
}

@end
