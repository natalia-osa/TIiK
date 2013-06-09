//
//  CRCHelper.h
//  TIiK
//
//  Created by Natalia Osiecka on 28.05.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRCHelper : NSObject {
    NSArray *_files;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)crcDataWithFileNumber:(NSUInteger)fileIndex files:(NSArray*)files;

@end
