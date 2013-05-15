//
//  LZWHelper.h
//  TIiK
//
//  Created by Natalia Osiecka on 14.05.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZWLetter.h"

@interface LZWHelper : NSObject {
    NSArray *_files;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)encodeDecodeWithFileNumber:(NSUInteger)fileIndex files:(NSArray*)files;

@end
