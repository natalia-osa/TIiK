//
//  MainViewController.h
//  TIiK
//
//  Created by Natalia Osiecka on 19.03.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Letter.h"
#import "File.h"

@interface MainViewController : UITableViewController {
    NSString *_polString;
    NSString *_engString;
    NSString *_infString;
    
    NSArray *_files;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
