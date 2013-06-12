//
//  ArithmeticHelper.m
//  TIiK
//
//  Created by Natalia Osiecka on 11.06.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//
// Based on http://pl.wikipedia.org/wiki/Kodowanie_arytmetyczne

#import "ArithmeticHelper.h"
#import "TIiKConstants.h"

#import "File.h"
#import "Letter.h"
#import "ArithmeticLetter.h"
#import "StringHelper.h"

#define ESCAPESIGN @"$"

@implementation ArithmeticHelper
@synthesize managedObjectContext = __managedObjectContext;
#warning read output from file

#pragma mark - Public

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeDecodeWithFileNumber:(NSUInteger)fileIndex files:(NSArray*)files {
    _files = files;
    
    /// LOAD DATA
    // load input string
    NSString *plainText = [StringHelper getStringFromFileNamed:[(File*)[files objectAtIndex:fileIndex] fileName]];
    // add escape sign
    plainText = [NSString stringWithFormat:@"%@%@", plainText, ESCAPESIGN];
    
    // load letters array
    NSMutableArray *lettersArray = [self loadLettersFromFileIndex:fileIndex numberOfChars:([plainText length]+1)];
    
    /// ENCODING
    // get output value
    double codedMin = [self encodeWithLettersArray:lettersArray fromPlainText:plainText];
    // log results
    NSLog(@"CODE: %f", codedMin);
    // save to file
    NSString *arithmeticLettersString = [self convertArithmeticLettersToString:lettersArray];
    [StringHelper saveString:[NSString stringWithFormat:@"%f%@", codedMin, arithmeticLettersString] toFileNamed:@"ArithmeticEncoded"];
    
    /// DECODING
    // get input string
    NSString *output = [self decodeWithArithmeticLetters:lettersArray codedValue:codedMin];
    // log results
    NSLog(@"DECODED: %@", output);
    // save to file
    [StringHelper saveString:output toFileNamed:@"ArithmeticDecoded"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)convertArithmeticLettersToString:(NSArray*)lettersArray {
    // create output
    NSString *outputString = @"";
    // iterate by all
    for (ArithmeticLetter *letter in lettersArray) {
        outputString = [NSString stringWithFormat:@"%@\n%@%f", outputString, letter.letterName, letter.code];
    }
    
    return outputString;
}

#pragma mark - Encode / Decode

////////////////////////////////////////////////////////////////////////////////////////////////////
- (double)encodeWithLettersArray:(NSArray*)lettersArray fromPlainText:(NSString*)plainText {
    // create vector array
    NSMutableArray *vectorArray = [self firstVersionOfVectorFromArithmeticLetters:lettersArray];
    
    // get each sign from input
    unichar *buffer = calloc([plainText length], sizeof(unichar));
    [plainText getCharacters:buffer];
    for (NSUInteger i = 0; i < [plainText length]; i++) {
        // get number of the letter
        NSNumber *charProbability;
        int letterNumber = [self indexOfChar:buffer[i] inLetterArray:lettersArray charProbability:&charProbability];
        // modify indexes in vector
        vectorArray = [self modifyVectorArray:vectorArray currentVectorNumber:letterNumber originalLettersArray:lettersArray];
    }
    
    // result number (always from n-1 object)
    return [[vectorArray objectAtIndex:([vectorArray count] - 2)] doubleValue];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)decodeWithArithmeticLetters:(NSMutableArray*)arithmeticLetters codedValue:(double)codedValue {
    // create string to save values into
    NSString *outputString = @"";
    // create vector array
    NSMutableArray *vectorArray = [self firstVersionOfVectorFromArithmeticLetters:arithmeticLetters];
    // run loop
    for ( ; ; ) {
        // find proper vector
        int currentVectorNumber = 0;
        while (codedValue > [[vectorArray objectAtIndex:currentVectorNumber] doubleValue]) {
            currentVectorNumber++;
        }
        currentVectorNumber--; // because first is 0.0, what we dont want to count
        NSString *newSymbol = [[arithmeticLetters objectAtIndex:currentVectorNumber] letterName];
        // stop loop if we've found last sign
        if ([newSymbol isEqualToString:ESCAPESIGN]) {
            return outputString;
        // else add newSymbol to result
        } else {
            outputString = [NSString stringWithFormat:@"%@%@", outputString, newSymbol];
        }
        // modify indexes in vector
        vectorArray = [self modifyVectorArray:vectorArray currentVectorNumber:currentVectorNumber originalLettersArray:arithmeticLetters];
    }
    
    return outputString;
}

#pragma mark - Helpers

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)modifyVectorArray:(NSMutableArray*)vectorArray currentVectorNumber:(int)currentVectorNumber originalLettersArray:(NSArray*)lettersArray {
    // select new min&max range
    double newMinRange = [[vectorArray objectAtIndex:currentVectorNumber] doubleValue];
    double newMaxRange = [[vectorArray objectAtIndex:currentVectorNumber+1] doubleValue];
    double previousMaxRange = newMinRange;
    // count new intervals
    for (int i = 0; i < [vectorArray count]; i++) {
        // if this is min range, set min value
        if (i == 0) {
            [vectorArray replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:newMinRange]];
            // if this is max range, set max value
        } else if (i == ([vectorArray count] - 1)) {
            [vectorArray replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:newMaxRange]];
            // else count value = (maxRange - minRange)*charProbability + minRange
        } else {
            double letterRangeProbability = [(ArithmeticLetter*)[lettersArray objectAtIndex:(i-1)] code];
            double rangeDifferencial = newMaxRange - newMinRange;
            double newRangeIncrease = rangeDifferencial * letterRangeProbability;
            double newRange = newRangeIncrease + previousMaxRange;
            [vectorArray replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:newRange]];
            previousMaxRange = newRange;
        }
    }
    return vectorArray;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)loadLettersFromFileIndex:(NSUInteger)fileIndex numberOfChars:(int)numberOfChars {
#warning Eventually can load these not from DB but create from plainText
    // load letters
    NSArray *letters = [self fetchRequestForLettersInFileNamed:fileIndex];
    
    // get only signs, where occurence == 0
    NSMutableArray *lettersArray = [[NSMutableArray alloc] init];
    for (Letter *letter in letters) {
        if (letter.occurence.intValue != 0) {
            ArithmeticLetter *arithmeticLetter = [[ArithmeticLetter alloc] init];
            arithmeticLetter.code = (letter.occurence.doubleValue / numberOfChars);
            arithmeticLetter.letterName = letter.letterName;
            [lettersArray addObject:arithmeticLetter];
        }
    }
    
    // add escape sign
    ArithmeticLetter *arithmeticLetter = [[ArithmeticLetter alloc] init];
    arithmeticLetter.code = (1.0 / numberOfChars);
    arithmeticLetter.letterName = ESCAPESIGN;
    [lettersArray addObject:arithmeticLetter];
    
    return lettersArray;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)firstVersionOfVectorFromArithmeticLetters:(NSArray*)arithmeticLetters {
    // make first version of vector with values
    NSMutableArray *vectorArray = [[NSMutableArray alloc] init];
    // add 0 at the beginning
    [vectorArray addObject:[NSNumber numberWithDouble:0.0]];
    // get rest of values
    float previousMax = 0;
    for (ArithmeticLetter *arithmeticLetter in arithmeticLetters) {
        float newMax = previousMax + arithmeticLetter.code;
        [vectorArray addObject:[NSNumber numberWithDouble:newMax]];
        previousMax = newMax;
    }
    
    return vectorArray;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)indexOfChar:(unichar)character inLetterArray:(NSArray*)letterArray charProbability:(NSNumber**)charProbability {
    int index = 0;
    for (ArithmeticLetter *letter in letterArray) {
        if ([letter.letterName isEqualToString:[NSString stringWithFormat:@"%c", character]]) {
            *charProbability = [NSNumber numberWithDouble:letter.code];
            return index;
        }
        index++;
    }
    // this should never happen
    return (-1);
}

#pragma mark - CoreData

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)fetchRequestForLettersInFileNamed:(NSUInteger)fileIndex {
    NSFetchRequest *letterFetch = [[NSFetchRequest alloc] init];
    [letterFetch setEntity:[NSEntityDescription entityForName:kLetter inManagedObjectContext:__managedObjectContext]];
    [letterFetch setPredicate:[NSPredicate predicateWithFormat:@"file == %@", [_files objectAtIndex:fileIndex]]];
    [letterFetch setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:kLetterName ascending:YES]]];
    return [__managedObjectContext executeFetchRequest:letterFetch error:nil];
}


@end
