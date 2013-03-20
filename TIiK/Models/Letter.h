//
//  Letter.h
//  TIiK
//
//  Created by Natalia Osiecka on 20.03.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File;

@interface Letter : NSManagedObject

@property (nonatomic, retain) NSString * letterName;
@property (nonatomic, retain) NSNumber * i;
@property (nonatomic, retain) NSNumber * p;
@property (nonatomic, retain) NSNumber * occurence;
@property (nonatomic, retain) File *file;

@end
