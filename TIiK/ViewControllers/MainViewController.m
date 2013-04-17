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


#pragma mark - Load data

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadDatabaseDataForFileAtIndex:(NSUInteger)fileIndex {
    NSLog(@"In file: %@", [(File*)[_files objectAtIndex:fileIndex] fileName]);
    
    // load letters
    NSFetchRequest *letterFetch = [[NSFetchRequest alloc] init];
    [letterFetch setEntity:[NSEntityDescription entityForName:@"Letter" inManagedObjectContext:__managedObjectContext]];
    [letterFetch setPredicate:[NSPredicate predicateWithFormat:@"file == %@", [_files objectAtIndex:fileIndex]]];
    [letterFetch setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"occurence" ascending:YES]]];
    NSArray *letters = [__managedObjectContext executeFetchRequest:letterFetch error:nil];
    
    NSMutableArray *unusedLeafs = [[NSMutableArray alloc] init];
    for (Letter *letter in letters) {
        NSLog(@"occurence of %@ is %d", letter.letterName, letter.occurence.intValue);
        
        // create leafs of tree
        if ([letter.occurence integerValue] > 0) {
            // only if letter apprears in text
            HuffmannTreeLeaf *leaf = [[HuffmannTreeLeaf alloc] init];
            [leaf setF:[letter.occurence integerValue]];
            [leaf setLetterName:letter.letterName];
            [unusedLeafs addObject:leaf];
        }
    }

    // create table of codes
    NSMutableArray *usedLeafs = [[NSMutableArray alloc] init];
    
    HuffmannTreeLeaf *parentLeaf;
    HuffmannTreeLeaf *topLeaf;
    while ([unusedLeafs count] > 0) {
        // keep list sorted
        [unusedLeafs sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"f" ascending:YES]]];
        if (parentLeaf == nil) {
            parentLeaf = [[HuffmannTreeLeaf alloc] init];
            [parentLeaf setLetterName:@""];
            [parentLeaf setF:0];
        }
        
        // set leafs
        HuffmannTreeLeaf *currentLeaf = [unusedLeafs objectAtIndex:0];
        [parentLeaf setF:(parentLeaf.f + currentLeaf.f)];
        // set left
        if (parentLeaf.leftLeaf == nil) {
            // add code
            [parentLeaf setLetterName:[NSString stringWithFormat:@"%@%@", parentLeaf.letterName, currentLeaf.letterName]];
            // move current leaf to used
            [usedLeafs addObject:currentLeaf];
            [parentLeaf setLeftLeaf:currentLeaf];
            [unusedLeafs removeObject:currentLeaf];
        // if left already is, set right
        } else if (parentLeaf.rightLeaf == nil) {
            // add code
            [parentLeaf setLetterName:[NSString stringWithFormat:@"%@%@", currentLeaf.letterName, parentLeaf.letterName]];
            // move current leaf to used
            [usedLeafs addObject:currentLeaf];
            [parentLeaf setRightLeaf:currentLeaf];
            [unusedLeafs removeObject:currentLeaf];
            // add parentLeaf to unused
            [unusedLeafs addObject:parentLeaf];
            parentLeaf = nil;
        }
        // save reference to top leaf
        if ([unusedLeafs count] == 0) {
            topLeaf = currentLeaf;
        }
    }
    
    NSLog(@" ");NSLog(@" ");
    
    // read codes
    huffmanCodes = [[NSMutableArray alloc] init];
    [self readChildLeafOf:topLeaf withSuperCode:@""];
    
    // show codes
    for (HuffmanCode *huffmanCode in huffmanCodes) {
        NSLog(@"H: %@, %@", huffmanCode.code, huffmanCode.sign);
    }
    
    NSLog(@" ");
    NSLog(@" ");

    // show leafs and their occurence
//    for (HuffmannTreeLeaf *leaf in usedLeafs) {
//        NSLog(@"%@ - %d",leaf.letterName, leaf.f);
//    }
    
    // encode
    NSString *plainText = [StringHelper getStringFromFileNamed:[(File*)[_files objectAtIndex:fileIndex] fileName]];
    NSString *encodedString = @"";
    
    // for each sign
    unichar *buffer = calloc([plainText length], sizeof(unichar));
    [plainText getCharacters:buffer];
    
    for(NSUInteger i = 0; i < [plainText length]; i++) {
        // search for code
        for (HuffmanCode *huffmanCode in huffmanCodes) {
            if ([huffmanCode.sign isEqualToString:[NSString stringWithFormat:@"%c", buffer[i]]]) {
                // add the code to encoded string
                encodedString = [NSString stringWithFormat:@"%@%@", encodedString, huffmanCode.code];
                break;
            }
//            if ([huffmanCode isEqual:[huffmanCodes lastObject]]) {
//                encodedString = [NSString stringWithFormat:@"%@%@", encodedString, [NSString stringWithUTF8String:buffer[i]/*&c[i]*/]];
//                break;
//            }
        }
    }
    NSLog(@" ");NSLog(@" ");
    
    // save to file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSError *error;
    BOOL succeed = [encodedString writeToFile:[documentsDirectory stringByAppendingPathComponent:@"encoded"]
                              atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!succeed){
        NSLog(@"%@", error.localizedDescription);
    }
    
    // save hoffman codes to files
    NSString *huffmanCodesString = @"";
    for (HuffmanCode *huffmanCode in huffmanCodes) {
        huffmanCodesString = [NSString stringWithFormat:@"%@%@ %@\n", huffmanCodesString, huffmanCode.code, huffmanCode.sign];
    }
    succeed = [huffmanCodesString writeToFile:[documentsDirectory stringByAppendingPathComponent:@"code"]
                                   atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!succeed){
        NSLog(@"%@", error.localizedDescription);
    }
    
    
    // decode
    NSString *decodedString = @"";
    
    // for each sign
    const char *d = [encodedString UTF8String];
    NSString *unknownSign = @"";
    for(int i = 0; i < [encodedString length]; ++i) {
        unknownSign = [NSString stringWithFormat:@"%@%c", unknownSign, d[i]];
//        if (d[i] != '0' || d[i] != '1') {
//            decodedString = [NSString stringWithFormat:@"%@%c", decodedString, d[i]];
//            unknownSign = @"";
//        }
        NSString *compareResult = [self compareHuffmanCodesToString:unknownSign];
        if (![compareResult isEqualToString:@""]) {
            decodedString = [NSString stringWithFormat:@"%@%@", decodedString, compareResult];
            unknownSign = @"";
        }
    }
    
    // save to file
    succeed = [decodedString writeToFile:[documentsDirectory stringByAppendingPathComponent:@"decoded"]
                                   atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!succeed){
        NSLog(@"%@", error.localizedDescription);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)compareHuffmanCodesToString:(NSString*)inputString {
    for (HuffmanCode *huffmanCode in huffmanCodes) {
        if ([huffmanCode.code isEqualToString:inputString]) {
            return huffmanCode.sign;
        }
    }
    // if didn't find return nothing
    return @"";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)readChildLeafOf:(HuffmannTreeLeaf *)parentLeaf withSuperCode:(NSString *)superCode {
    if (parentLeaf.leftLeaf) {
        [self readChildLeafOf:parentLeaf.leftLeaf withSuperCode:[NSString stringWithFormat:@"%@0", superCode]];
    }
    if (parentLeaf.rightLeaf) {
        [self readChildLeafOf:parentLeaf.rightLeaf withSuperCode:[NSString stringWithFormat:@"%@1", superCode]];
    }
    if (!parentLeaf.rightLeaf && !parentLeaf.leftLeaf) { // there is no child
        HuffmanCode *currentCode = [[HuffmanCode alloc] init];
        [currentCode setCode:superCode];
        [currentCode setSign:parentLeaf.letterName];
        [huffmanCodes addObject:currentCode];
    }
}


#pragma mark - Adding records

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
            [self loadDatabaseDataForFileAtIndex:0];
            break;
        case 1:
            [self loadDatabaseDataForFileAtIndex:1];
            break;
        case 2:
            [self loadDatabaseDataForFileAtIndex:2];
            break;
        default:
            break;
    }
}


@end
