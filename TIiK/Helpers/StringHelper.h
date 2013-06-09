//
//  
//  TIiK
//
//  Created by Natalia Osiecka on 20.03.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringHelper : NSObject

// documents folder
+ (NSString*)getStringFromFileNamed:(NSString*)name;
+ (NSString*)openFileNamed:(NSString*)fileName;
+ (void)saveString:(NSString*)inputString toFileNamed:(NSString*)fileName;
// string operations
+ (int)getNumberOfOccurenceOfString:(NSString*)smallString inString:(NSString*)bigString;
+ (void)iterateByString:(NSString*)inputString withName:(NSString*)inputName withManagedObjectContext:(NSManagedObjectContext*)context;
+ (NSString*)allCharacterString;

@end
