//
//  HuffmanHelper.m
//  TIiK
//
//  Created by Natalia Osiecka on 17.04.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import "HuffmanHelper.h"
#import "StringHelper.h"
#import "TIiKConstants.h"

// structures
#import "File.h"
#import "Letter.h"

@implementation HuffmanHelper
@synthesize managedObjectContext = __managedObjectContext;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    return [super init];
#warning should save into file collecting each 8signs to 1
#warning calculate entrophy
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeDecodeWithFileNumber:(NSUInteger)fileIndex files:(NSArray*)files {
    _files = files;
    
    // load letters
    NSArray *letters = [self fetchRequestForLettersInFileNamed:fileIndex];
    
    // save basic leafs
    NSMutableArray *unusedLeafs = [self getbasicUnusedLeafsForLetters:letters];
    
    // create tree of codes
    HuffmannTreeLeaf *topLeaf = [self createTreeOfCodesFromUnusedLeafs:unusedLeafs];
    
    // create codes
    huffmanCodes = [[NSMutableArray alloc] init];
    [self readChildLeafOf:topLeaf withSuperCode:@""];
    // save huffman codes to file
    NSString *huffmanCodesString = [self getHuffmanCodesString];
    [StringHelper saveString:huffmanCodesString toFileNamed:@"code"];
    
    // encode
    NSString *plainText = [StringHelper getStringFromFileNamed:[(File*)[files objectAtIndex:fileIndex] fileName]];
    NSString *encodedString = [self encodePlainText:plainText];
    // save encoded string to file
    [StringHelper saveString:encodedString toFileNamed:@"encoded"];
    
    // decode
#warning Should read huffman codes from file!
    NSString *decodedString = [self decodeEncryptedTextF:encodedString];
    // save to file
    [StringHelper saveString:decodedString toFileNamed:@"decoded"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Size"
                                                        message:[NSString stringWithFormat:@"decoded: %d; encoded: %d", [decodedString length], (int)floorf([encodedString length]/8.0f)]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)decodeEncryptedTextF:(NSString*)encodedString {
    NSString *decodedString = @"";
    // for each sign
    const char *d = [encodedString UTF8String];
    NSString *unknownSign = @"";
    for(int i = 0; i < [encodedString length]; ++i) {
        unknownSign = [NSString stringWithFormat:@"%@%c", unknownSign, d[i]];
        NSString *compareResult = [self compareHuffmanCodesToString:unknownSign];
        if (![compareResult isEqualToString:@""]) {
            decodedString = [NSString stringWithFormat:@"%@%@", decodedString, compareResult];
            unknownSign = @"";
        }
    }
    return decodedString;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (HuffmannTreeLeaf*)createTreeOfCodesFromUnusedLeafs:(NSMutableArray*)unusedLeafs {
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
        // save reference to root
        if ([unusedLeafs count] == 0) {
            topLeaf = currentLeaf;
        }
    }
    return topLeaf;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)getbasicUnusedLeafsForLetters:(NSArray*)letters {
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (Letter *letter in letters) {
        // only if letter apprears in text
        if ([letter.occurence integerValue] > 0) {
            HuffmannTreeLeaf *leaf = [[HuffmannTreeLeaf alloc] init];
            [leaf setF:[letter.occurence integerValue]];
            [leaf setLetterName:letter.letterName];
            [resultArray addObject:leaf];
        }
    }
    return resultArray;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)fetchRequestForLettersInFileNamed:(NSUInteger)fileIndex {
    NSFetchRequest *letterFetch = [[NSFetchRequest alloc] init];
    [letterFetch setEntity:[NSEntityDescription entityForName:kLetter inManagedObjectContext:__managedObjectContext]];
    [letterFetch setPredicate:[NSPredicate predicateWithFormat:@"file == %@", [_files objectAtIndex:fileIndex]]];
    [letterFetch setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:kOccurence ascending:YES]]];
    return [__managedObjectContext executeFetchRequest:letterFetch error:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)encodePlainText:(NSString*)plainText {
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
        }
    }
    
    // free memory
    free(buffer);
    
    return encodedString;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)getHuffmanCodesString {
    NSString *huffmanCodesString = @"";
    for (HuffmanCode *huffmanCode in huffmanCodes) {
        huffmanCodesString = [NSString stringWithFormat:@"%@%@ %@\n", huffmanCodesString, huffmanCode.code, huffmanCode.sign];
    }
    return huffmanCodesString;
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


@end
