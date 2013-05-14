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

// frameworks
#import <math.h>

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize managedObjectContext = __managedObjectContext;

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

#pragma mark - Calculations

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


#pragma mark - UITableView delegate & datasource

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
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
    switch (indexPath.row) {
        case 0:
            [self encodeDecodeWithHuffmanForFileNumber:0];
            break;
        case 1:
            [self encodeDecodeWithHuffmanForFileNumber:1];
            break;
        case 2:
            [self encodeDecodeWithHuffmanForFileNumber:2];
            break;
        default:
            break;
    }
}


@end
