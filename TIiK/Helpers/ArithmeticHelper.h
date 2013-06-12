//
//  ArithmeticHelper.h
//  TIiK
//
//  Created by Natalia Osiecka on 11.06.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArithmeticHelper : NSObject {
    NSMutableArray *huffmanCodes;
    NSArray *_files;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)encodeDecodeWithFileNumber:(NSUInteger)fileIndex files:(NSArray*)files;

@end
