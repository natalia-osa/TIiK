//
//  MainViewController.m
//  TIiK
//
//  Created by Natalia Osiecka on 19.03.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import "MainViewController.h"

// helpers
#import "StringHelper.h"
#import "HuffmanHelper.h"
#import "LZWHelper.h"

// frameworks
#import <math.h>

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize managedObjectContext = __managedObjectContext;

#warning add 'detail' screens - show table & files for just calculated option - detail would be file contents
#warning add Constants file & save Models name there

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDatabase];
    
    // load files
    NSFetchRequest *fileFetch = [[NSFetchRequest alloc] init];
    [fileFetch setEntity:[NSEntityDescription entityForName:@"File" inManagedObjectContext:__managedObjectContext]];
    [fileFetch setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"fileName" ascending:YES]]];
    
    UIBarButtonItem *clearBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(clearDatabaseTapped:)];
    self.navigationItem.rightBarButtonItem = clearBarButtonItem;
    
    _files = [__managedObjectContext executeFetchRequest:fileFetch error:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

#pragma mark - Actions

////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)clearDatabaseTapped:(id)sender {
    [self clearEntityNamed:@"File"];
    [self clearEntityNamed:@"Letter"];
    
    [self setupDatabase];
}

#pragma mark - Calculations

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)clearEntityNamed:(NSString*)entityName {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:__managedObjectContext]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *objects = [__managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) NSLog(@"%@", error.localizedDescription);
    
    for (NSManagedObject *object in objects) {
        [__managedObjectContext deleteObject:object];
    }
    NSError *saveError = nil;
    [__managedObjectContext save:&saveError];
    if (saveError) NSLog(@"%@", saveError.localizedDescription);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupDatabase {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // run only once
    if (![userDefaults boolForKey:@"hasRunBefore"]) {
        _engString = [StringHelper getStringFromFileNamed:@"Eng"];
        NSLog(@"Eng Length: %d", [_engString length]);
        [StringHelper iterateByString:_engString withName:@"Eng" withManagedObjectContext:__managedObjectContext];
        
        _polString = [StringHelper getStringFromFileNamed:@"Pol"];
        NSLog(@"Pol Length: %d", [_polString length]);
        [StringHelper iterateByString:_polString withName:@"Pol" withManagedObjectContext:__managedObjectContext];
        
        _infString = [StringHelper getStringFromFileNamed:@"Inf"];
        NSLog(@"Inf Length: %d", [_infString length]);
        [StringHelper iterateByString:_infString withName:@"Inf" withManagedObjectContext:__managedObjectContext];
        
        // save to run only once
        [userDefaults setBool:YES forKey:@"hasRunBefore"];
        [userDefaults synchronize];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeDecodeWithHuffmanForFileNumber:(NSUInteger)fileNumber {
    HuffmanHelper *huffmanHelper = [[HuffmanHelper alloc] init];
    [huffmanHelper setManagedObjectContext:__managedObjectContext];
    [huffmanHelper encodeDecodeWithFileNumber:fileNumber files:_files];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeDecodeWithLZWForFileNumber:(NSUInteger)fileNumber {
    LZWHelper *lzwHelper = [[LZWHelper alloc] init];
    [lzwHelper setManagedObjectContext:__managedObjectContext];
    [lzwHelper encodeDecodeWithFileNumber:fileNumber files:_files];
}


#pragma mark - UITableView delegate & datasource

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: // hoffman
            return 3;
            break;
        case 1: // lzw
            return 3;
            break;
        default:
            return 1;
            break;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Huffman - encode & decode", nil);
            break;
        case 1:
            return NSLocalizedString(@"LZW", nil);
            break;
        default:
            return @"";
            break;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"fileCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    switch (indexPath.row) {
        case 0: {
            [cell.textLabel setText:[NSString stringWithFormat:NSLocalizedString(@"File %@", nil), [(File*)[_files objectAtIndex:0] fileName]]];
            break;
        } case 1: {
            [cell.textLabel setText:[NSString stringWithFormat:NSLocalizedString(@"File %@", nil), [(File*)[_files objectAtIndex:1] fileName]]];
            break;
        } case 2: {
            [cell.textLabel setText:[NSString stringWithFormat:NSLocalizedString(@"File %@", nil), [(File*)[_files objectAtIndex:2] fileName]]];
            break;
        } default: {
            break;
        }
    }
    
    return cell;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: { // hoffman
            switch (indexPath.row) {
                case 0: {
                    [self encodeDecodeWithHuffmanForFileNumber:0];
                    break;
                }
                case 1: {
                    [self encodeDecodeWithHuffmanForFileNumber:1];
                    break;
                }
                case 2: {
                    [self encodeDecodeWithHuffmanForFileNumber:2];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1: { // lzw
            switch (indexPath.row) {
                case 0: {
                    [self encodeDecodeWithLZWForFileNumber:0];
                    break;
                }
                case 1: {
                    [self encodeDecodeWithLZWForFileNumber:1];
                    break;
                }
                case 2: {
                    [self encodeDecodeWithLZWForFileNumber:2];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}


@end
