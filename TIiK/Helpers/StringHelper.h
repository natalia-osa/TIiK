//
//  
//  TIiK
//
//  Created by Natalia Osiecka on 20.03.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringHelper : NSObject

+ (int)getNumberOfOccurenceOfString:(NSString*)smallString inString:(NSString*)bigString;
+ (void)iterateByString:(NSString*)inputString;
+ (NSString*)getStringFromFileNamed:(NSString*)name;
+ (NSString*)allCharacterString;

@end
