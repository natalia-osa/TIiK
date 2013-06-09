//
//  HuffmanHelper.h
//  TIiK
//
//  Created by Natalia Osiecka on 17.04.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HuffmannTreeLeaf.h"
#import "HuffmanCode.h"

@interface HuffmanHelper : NSObject {
    NSMutableArray *huffmanCodes;
    NSArray *_files;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)encodeDecodeWithFileNumber:(NSUInteger)fileIndex files:(NSArray*)files;
- (NSString*)onlyEncodeWithFileNumber:(NSUInteger)fileIndex files:(NSArray*)files;

@end
