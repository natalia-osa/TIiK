//
//  TIiKAppDelegate.h
//  TIiK
//
//  Created by Natalia Osiecka on 19.03.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TIiKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
