//
//  StringHelper.m
//  TIiK
//
//  Created by Natalia Osiecka on 20.03.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import "StringHelper.h"

@implementation StringHelper

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)allCharacterString {
    return @"qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890 ";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)getStringFromFileNamed:(NSString*)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)iterateByString:(NSString*)inputString {
    // wystąpienia w całości /// overall
    NSString *allCharacterString = [StringHelper allCharacterString];
    const char *c = [allCharacterString UTF8String];
    float H = 0;
    
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
    }
    NSLog(@"H = %f", H);
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

@end
