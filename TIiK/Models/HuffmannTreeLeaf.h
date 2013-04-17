//
//  HuffmannTreeLeaf.h
//  TIiK
//
//  Created by Natalia Osiecka on 03.04.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HuffmannTreeLeaf : NSObject

@property (nonatomic, strong) NSString *letterName;
@property (nonatomic, assign) NSInteger f;
@property (nonatomic, strong) HuffmannTreeLeaf *leftLeaf;
@property (nonatomic, strong) HuffmannTreeLeaf *rightLeaf;

@end
