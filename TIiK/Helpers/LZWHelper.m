//
//  LZWHelper.m
//  TIiK
//
//  Created by Natalia Osiecka on 14.05.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//
//  Based on algorithm from http://pl.wikipedia.org/wiki/LZW (http://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Welch for english)
//  Used method to save codes (numbers) has big meaning to compression effectiveness"


#import "LZWHelper.h"
#import "StringHelper.h"

// structures
#import "File.h"
#import "Letter.h"

// constants
#define KDICTFILENAME @"LZWDictionary"
#define KENCODEDFILENAME @"LZWEncodedString"
#define KDECODEDFILENAME @"LZWDecodedString"


@implementation LZWHelper
@synthesize managedObjectContext = __managedObjectContext;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    return [super init];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeDecodeWithFileNumber:(NSUInteger)fileIndex files:(NSArray*)files {
#warning translate polish instructions into english
#warning współczynnik kompresji
    ///Jeśli przyjąć, że indeksy oraz symbole są zapisane na tej samej liczbie bitów, to współczynnik kompresji wyniesie ok. 37%. Jeśli natomiast przyjąć minimalną liczbę bitów potrzebną do zapisania danych, tj. 3 bity na symbol (w sumie 72 bity), 4 na indeks (w sumie 60 bitów), współczynnik kompresji wyniesie ok. 15%.
    
    _files = files;
    
    // Obtain information source - input file
    NSString *plainText = [StringHelper getStringFromFileNamed:[(File*)[files objectAtIndex:fileIndex] fileName]];
    unichar *buffer = calloc([plainText length], sizeof(unichar));
    [plainText getCharacters:buffer];
    
    // count time - encoding start
    NSDate *encodingStartDate = [NSDate date];
    
    // Create encodedArray
    NSMutableArray *encodedArray = [[NSMutableArray alloc] init];
    
    /// 1. Wypełnij słownik alfabetem źródła informacji
    int lastAddedCode = -1;
    NSMutableArray *lzwdict = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [plainText length]; i++) {
        // if such letter isn't already added
        if (![self dict:lzwdict containsString:[NSString stringWithFormat:@"%c", buffer[i]]]) {
            // increment counter
            lastAddedCode++;
            // add record
            [lzwdict addObject:[self createLZWLetterWithCode:lastAddedCode string:[NSString stringWithFormat:@"%c", buffer[i]]]];
//            NSLog(@"c=%@ // %d", lzwLetter.string, lzwLetter.code);
        }
    }
    /// Zapisz słownik do pliku
    [StringHelper saveString:[self convertToStringFromLZWObjectArray:lzwdict] toFileNamed:[NSString stringWithFormat:@"%@.txt", KDICTFILENAME]];
    
    /// 2. c := pierwszy symbol wejściowy
    int previousIndex = 0;
    int currentIndex = 0;
    NSString *c = [NSString stringWithFormat:@"%c", buffer[currentIndex]];
    
    /// 3. Dopóki są dane na wejściu
    while (currentIndex < [plainText length]-1) {
        currentIndex++;
        /// Wczytaj znak s
        NSString *s = [NSString stringWithFormat:@"%c", buffer[currentIndex]];
        /// Jeżeli ciąg c + s znajduje się w słowniku
        if ([self dict:lzwdict containsString:[NSString stringWithFormat:@"%@%@", c, s]]) {
            /// przedłuż ciąg c, tj. c := c + s
            c = [NSString stringWithFormat:@"%@%@", c, s];
        } else {
            /// wypisz kod dla c (c znajduje się w słowniku)
            NSInteger cCode = [self codeForString:c usingDict:lzwdict];
            [encodedArray addObject:[NSNumber numberWithInteger:cCode]];
            /// dodaj ciąg c + s do słownika
            [lzwdict addObject:[self createLZWLetterWithCode:[lzwdict count] string:[NSString stringWithFormat:@"%@%@", c, s]] ];
//            NSLog(@"c=%@ // %d", lzwLetter.string, lzwLetter.code);
            /// przypisz c := s.
            c = s;
            previousIndex = currentIndex;
        }
    }
    
    // free memony
    free(buffer);
    
    /// 4. Na końcu wypisz na wyjście kod związany c.
    if ([self dict:lzwdict containsString:c]) {
        NSInteger cCode = [self codeForString:c usingDict:lzwdict];
        [encodedArray addObject:[NSNumber numberWithInteger:cCode]];
//        NSLog(@"c=%@ // %d", c, cCode);
    } else {
        NSLog(@"This shouldn't happen according to algorithm // last 'c' code do not have its code added to dict");
    }
    
    // count time - encoding stop
    NSTimeInterval encodingTimeInterval = [encodingStartDate timeIntervalSinceNow];
    
    // encodedArray is compressed output, save it to file
    [StringHelper saveString:[self createStringFromNumberArray:encodedArray] toFileNamed:[NSString stringWithFormat:@"%@.txt", KENCODEDFILENAME]];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
                                        /// decode ///
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    /// 1. Wypełnij słownik alfabetem źródła informacji
#warning read values from file
#warning put encode / decode into separate methods
    // got it in lzwdict - temp
    
    // count time - decoding start
    NSDate *decodingStartDate = [NSDate date];
    
    // Create decodedArray
    NSMutableArray *decodedArray = [[NSMutableArray alloc] init];
    
    /// 2. pk := pierwszy kod skompresowanych danych
    /*int*/ currentIndex = 0;
    NSInteger pk = [encodedArray[currentIndex] integerValue];
    
    /// 3. Wypisz na wyjście ciąg związany z kodem pk, tj. słownik[pk]
    [decodedArray addObject:[self stringForCode:pk usingDict:lzwdict]];
//    NSLog(@"%@ // %d", [self stringForCode:pk usingDict:lzwdict], pk);
    
    /// Dopóki są jeszcze jakieś słowa kodu:
    while (currentIndex < [encodedArray count]-1) {
        // increment counter
        currentIndex++;
        /// Wczytaj kod k
        NSInteger k = [encodedArray[currentIndex] integerValue];
        /// pc := słownik[pk] – ciąg skojarzony z poprzednim kodem
        NSString *pc = [self stringForCode:pk usingDict:lzwdict];
        /// Jeśli kod k jest w słowniku
        NSString *codeK = [self stringForCode:k usingDict:lzwdict];
        if (codeK) {
            /// dodaj do słownika ciąg (pc + pierwszy symbol ciągu słownik[k])
            // get word
            NSString *kWord = [self stringForCode:pk usingDict:lzwdict];
            // get first character of lzwdict[k]
            NSString *firstLetter = [kWord substringWithRange:[kWord rangeOfComposedCharacterSequenceAtIndex:0]];
            // save string to dictionary
            [lzwdict addObject:[self createLZWLetterWithCode:[lzwdict count] string:[NSString stringWithFormat:@"%@%@", pc, firstLetter]]];
            /// na wyjście wypisz cały ciąg słownik[k].
            [decodedArray addObject:[self stringForCode:k usingDict:lzwdict]];
//            NSLog(@"%@ // %d", [self stringForCode:k usingDict:lzwdict], [lzwdict count]);
        } else { /// przypadek scscs
            /// dodaj do słownika ciąg (pc + pierwszy symbol pc)
            // get first character of pc
            NSString *firstLetter = [pc substringWithRange:[pc rangeOfComposedCharacterSequenceAtIndex:0]];
            // save string to dictionary
            [lzwdict addObject:[self createLZWLetterWithCode:[lzwdict count] string:[NSString stringWithFormat:@"%@%@", pc, firstLetter]]];
            /// tenże ciąg wypisz na wyjście.
            [decodedArray addObject:[NSString stringWithFormat:@"%@%@", pc, firstLetter]];
//            NSLog(@"%@ // %d", [NSString stringWithFormat:@"%@%@", pc, firstLetter], [lzwdict count]);
        }
        /// pk := k
        pk = k;
    }
    
    // count time - decoding stop
    NSTimeInterval decodingTimeInterval = [decodingStartDate timeIntervalSinceNow];
    
    // decodedArray is uncompressed output, save it to file
    [StringHelper saveString:[self createStringFromStringArray:decodedArray] toFileNamed:[NSString stringWithFormat:@"%@.txt", KDECODEDFILENAME]];
    
    // NSLog compression
    NSInteger inputSize = [plainText length]*8;
    NSLog(@"input filesize: %d", inputSize);
    
    NSInteger outputSize = [[StringHelper getStringFromFileNamed:KENCODEDFILENAME] length]*3 + [[StringHelper getStringFromFileNamed:KDICTFILENAME] length]*8;
    NSLog(@"output filesize: %d", outputSize);
    
    CGFloat compressionRate = (CGFloat)outputSize/inputSize*1.0f;
    NSLog(@"compression rate: %f", compressionRate);
    
    /// PRINT TIME
    NSLog(@"Encoding: %f", -encodingTimeInterval);
    NSLog(@"Decoding: %f", -decodingTimeInterval);
}

#pragma mark - Helpers

////////////////////////////////////////////////////////////////////////////////////////////////////
- (LZWLetter*)createLZWLetterWithCode:(NSInteger)code string:(NSString*)string {
    LZWLetter *lzwLetter = [[LZWLetter alloc] init];
    lzwLetter.code = code;
    lzwLetter.string = string;
    return lzwLetter;
}

#pragma mark - Search for properties in LZWLetters

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stringForCode:(NSInteger)code usingDict:(NSArray*)dict {
    for (LZWLetter *letter in dict) {
        if (letter.code == code) {
            return letter.string;
        }
    }
    return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)codeForString:(NSString*)inputString usingDict:(NSArray*)dict {
    for (LZWLetter *letter in dict) {
        if ([letter.string isEqualToString:inputString]) {
            return letter.code;
        }
    }
    NSLog(@"This should never happen, please call dict:containsString: to ensure such inputString is in dict");
    return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)dict:(NSArray*)dict containsString:(NSString*)inputString {
    for (LZWLetter *letter in dict) {
        if ([letter.string isEqualToString:inputString]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Convert to string/from string (saving to/from file)

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)convertToStringFromLZWObjectArray:(NSArray*)inputArray {
    NSString *outputString = nil;
    for (LZWLetter *letter in inputArray) {
        if (!outputString) {
            outputString = [NSString stringWithFormat:@"%d %@", letter.code, letter.string];
        } else {
            outputString = [NSString stringWithFormat:@"%@\n%d %@", outputString, letter.code, letter.string];
        }
    }
    return outputString;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)convertToLZWArrayFromString:(NSString*)inputString {
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    unichar *buffer = calloc([inputString length], sizeof(unichar));
    [inputString getCharacters:buffer];
    
    NSString *code = @"";
    NSString *string = @"";
    BOOL codeRead = NO;
    for (NSUInteger i = 0; i < [inputString length]; i++) {
        if (!codeRead && buffer[i] != ' ') {
            code = [NSString stringWithFormat:@"%@%c", code, buffer[i]];
        } else if (buffer[i] == ' ') {
            codeRead = YES;
        } else if (buffer[i] == '\n') {
            // add new letter
            [outputArray addObject:[self createLZWLetterWithCode:code.integerValue string:string]];
            // reset values
            codeRead = NO;
            code = @"";
            string = @"";
        } else {
            string = [NSString stringWithFormat:@"%@%c", string, buffer[i]];
        }
    }
    
    // free memory
    free(buffer);
    
    // if there wasn't new line at the end of file
    if (codeRead == YES) {
        // add new letter
        [outputArray addObject:[self createLZWLetterWithCode:code.integerValue string:string]];
    }
    
    return outputArray;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)createStringFromNumberArray:(NSArray*)numberArray {
    NSString *encodedString = nil;
    for (NSNumber *code in numberArray) {
        if (!encodedString) {
            encodedString = [NSString stringWithFormat:@"%d", code.integerValue];
        } else {
            encodedString = [NSString stringWithFormat:@"%@\n%d", encodedString, code.integerValue];
        }
    }
    return encodedString;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)createStringFromStringArray:(NSArray*)stringArray {
    NSString *outputString = nil;
    for (NSString *string in stringArray) {
        if (!outputString) {
            outputString = [NSString stringWithFormat:@"%@", string];
        } else {
            outputString = [NSString stringWithFormat:@"%@%@", outputString, string];
        }
    }
    return outputString;
}


@end
