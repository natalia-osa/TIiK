//
//  StringHelper.m
//  TIiK
//
//  Created by Natalia Osiecka on 20.03.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import "StringHelper.h"

// data
#import "TIiKAppDelegate.h"
#import "TIiKConstants.h"

// models
#import "Letter.h"
#import "File.h"


@implementation StringHelper

- (void)emptyMethod {
}


#pragma mark - Resources

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)allCharacterString {
    return @"qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890 \n.,-";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)openFileNamed:(NSString*)fileName {
#warning TO IMPROVE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *fullPath = [[paths lastObject] stringByAppendingPathComponent:fileName];
    return [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:NULL];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)getStringFromFileNamed:(NSString*)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)saveString:(NSString*)inputString toFileNamed:(NSString*)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSError *error;
    BOOL succeed = [inputString writeToFile:[documentsDirectory stringByAppendingPathComponent:fileName]
                                 atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!succeed){
        NSLog(@"%@", error.localizedDescription);
    }
}

#pragma mark - String operation

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)iterateByString:(NSString*)inputString withName:(NSString*)inputName withManagedObjectContext:(NSManagedObjectContext*)context {
    
    // wystąpienia w całości /// overall
    NSString *allCharacterString = [StringHelper allCharacterString];
    const char *c = [allCharacterString UTF8String];
    float H = 0;
    
    // zapis do DB
    File *file = [StringHelper saveFileWithName:inputName withManagedObjectContext:context length:[inputString length] h:H];
    
    for(int i = 0; i < [allCharacterString length]; ++i) {
        // ilość wystąpień /// occurence
        int count = [StringHelper getNumberOfOccurenceOfString:[NSString stringWithFormat:@"%c", c[i]] inString:inputString];
        NSLog(@"'%c' = %d", c[i], count);
        
        // prawdopodobieństwo /// P(si) = occurence/overall
        float P = (float)count/[inputString length];
        NSLog(@"'P(%c)' = %f", c[i], P);
        
        // miara informacji /// I(si) = log2(1/P(si))
        float I = log2(1/P);
        NSLog(@"'I(%c)' = %f", c[i], I);
        
        // entropia /// H = sum P(si)I(si)
        if (P > 0.0f) {
            H += P*I;
        }
        
        [StringHelper saveLetterWithName:c[i] forFile:file withMangedObjectContext:context occurence:count p:P i:I];
    }
    NSLog(@"H = %f", H);
    [StringHelper overwriteFile:file withManagedObjectContext:context h:H];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)countEntropy {
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (int)getNumberOfOccurenceOfString:(NSString*)smallString inString:(NSString*)bigString {
    NSUInteger count = 0,
    length = [bigString length];
    NSRange range = NSMakeRange(0, length);
    
    while(range.location != NSNotFound) {
        range = [bigString rangeOfString:smallString options:0 range:range];
        if(range.location != NSNotFound) {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            count++;
        }
    }
    return count;
}


#pragma mark - Database operation

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (File*)saveFileWithName:(NSString*)fileName withManagedObjectContext:(NSManagedObjectContext*)context length:(int)length h:(float)h {
    File *file = [NSEntityDescription insertNewObjectForEntityForName:kFile inManagedObjectContext:context];
    file.fileName = fileName;
    file.h = [NSNumber numberWithFloat:h];
    file.length = [NSNumber numberWithInt:length];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    
    return file;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)overwriteFile:(File*)file withManagedObjectContext:(NSManagedObjectContext*)context h:(float)h {
    file.h = [NSNumber numberWithFloat:h];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)saveLetterWithName:(char)letterName
                   forFile:(File*)file
   withMangedObjectContext:(NSManagedObjectContext*)context
                 occurence:(int)occurence
                         p:(float)p
                         i:(float)i {
    
    Letter *letter = [NSEntityDescription insertNewObjectForEntityForName:kLetter inManagedObjectContext:context];
    letter.letterName = [NSString stringWithFormat:@"%c", letterName];
    letter.occurence = [NSNumber numberWithInt:occurence];
    letter.p = [NSNumber numberWithFloat:p];
    letter.i = [NSNumber numberWithFloat:i];
    letter.file = file;
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
}


@end
