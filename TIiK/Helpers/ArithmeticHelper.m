//
//  ArithmeticHelper.m
//  TIiK
//
//  Created by Natalia Osiecka on 11.06.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import "ArithmeticHelper.h"
#import "TIiKConstants.h"

#import "File.h"
#import "Letter.h"
#import "ArithmeticLetter.h"
#import "StringHelper.h"

@implementation ArithmeticHelper
@synthesize managedObjectContext = __managedObjectContext;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeDecodeWithFileNumber:(NSUInteger)fileIndex files:(NSArray*)files {
    _files = files;
    
    /// ENCODING
    // load letters array
    NSMutableArray *lettersArray = [self loadLettersFromFileIndex:fileIndex];
    
    // load input string
    NSString *plainText = [StringHelper getStringFromFileNamed:[(File*)[files objectAtIndex:fileIndex] fileName]];
    
    // create vector array
    NSMutableArray *vectorArray = [self firstVersionOfVectorFromLettersArray:lettersArray];
    
    // get each sign from input
    unichar *buffer = calloc([plainText length], sizeof(unichar));
    [plainText getCharacters:buffer];
    int numberOfIterations = 0;
    for (NSUInteger i = 0; i < [plainText length]; i++) {
        // get number of the letter
        NSNumber *charProbability;
        int letterNumber = [self indexOfChar:buffer[i] inLetterArray:lettersArray charProbability:&charProbability];
        // select new min&max range
        double newMinRange = [[vectorArray objectAtIndex:letterNumber] doubleValue];
        double newMaxRange = [[vectorArray objectAtIndex:letterNumber+1] doubleValue];
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
        numberOfIterations++;
    }

    /// save output
    // result number
    double codedMin = [[vectorArray objectAtIndex:0] doubleValue];
    // a little modification here - i don't use end sign, but save number of iterations as beginning of code
    codedMin = codedMin + numberOfIterations;
    // log results
    NSLog(@"CODE: %f, %@", codedMin, lettersArray);
    
    /// DECODING
    // get input string
    NSString *output = [self decodeWithArithmeticLetters:lettersArray codedValue:codedMin];
    // print string
    NSLog(@"%@", output);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)decodeWithArithmeticLetters:(NSMutableArray*)arithmeticLetters codedValue:(double)codedValue {
    // create string to save values into
    NSString *outputString;
    // create vector array
    NSMutableArray *vectorArray = [self firstVersionOfVectorFromArithmeticLetters:arithmeticLetters];
    // run loop
    for (int i = 0 ; i < floorf(codedValue) ; i++) {
        // find proper vector
        int currentVectorNumber = 0;
        while (codedValue < [[vectorArray objectAtIndex:currentVectorNumber] doubleValue]) {
            currentVectorNumber++;
        }
        outputString = [NSString stringWithFormat:@"%@%@", outputString, [[arithmeticLetters objectAtIndex:currentVectorNumber] letterName]];
    }
    
    return outputString;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)loadLettersFromFileIndex:(NSUInteger)fileIndex {
    // load letters
    NSArray *letters = [self fetchRequestForLettersInFileNamed:fileIndex];
    
    // get only signs, where occurence == 0
    NSMutableArray *lettersArray = [[NSMutableArray alloc] init];
    for (Letter *letter in letters) {
        if (letter.occurence.intValue != 0) {
            ArithmeticLetter *arithmeticLetter = [[ArithmeticLetter alloc] init];
            arithmeticLetter.code = letter.p.doubleValue;
            arithmeticLetter.letterName = letter.letterName;
            [lettersArray addObject:arithmeticLetter];
        }
    }
    
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
- (NSMutableArray*)firstVersionOfVectorFromLettersArray:(NSArray*)lettersArray {
    // make first version of vector with values
    NSMutableArray *vectorArray = [[NSMutableArray alloc] init];
    // add 0 at the beginning
    [vectorArray addObject:[NSNumber numberWithDouble:0.0]];
    // get rest of values
    float previousMax = 0;
    for (ArithmeticLetter *letter in lettersArray) {
        float newMax = previousMax + letter.code;
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

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)fetchRequestForLettersInFileNamed:(NSUInteger)fileIndex {
    NSFetchRequest *letterFetch = [[NSFetchRequest alloc] init];
    [letterFetch setEntity:[NSEntityDescription entityForName:kLetter inManagedObjectContext:__managedObjectContext]];
    [letterFetch setPredicate:[NSPredicate predicateWithFormat:@"file == %@", [_files objectAtIndex:fileIndex]]];
    [letterFetch setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:kLetterName ascending:YES]]];
    return [__managedObjectContext executeFetchRequest:letterFetch error:nil];
}


@end
