//
//  File.h
//  TIiK
//
//  Created by Natalia Osiecka on 20.03.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Letter;

@interface File : NSManagedObject

@property (nonatomic, retain) NSNumber * h;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSSet *letter;
@end

@interface File (CoreDataGeneratedAccessors)

- (void)addLetterObject:(Letter *)value;
- (void)removeLetterObject:(Letter *)value;
- (void)addLetter:(NSSet *)values;
- (void)removeLetter:(NSSet *)values;

@end
