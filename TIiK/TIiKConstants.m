//
//  TIiKConstants.m
//  TIiK
//
//  Created by Natalia Osiecka on 15.05.2013.
//  Copyright (c) 2013 Politechnika Poznańska. All rights reserved.
//

#import "TIiKConstants.h"

@implementation TIiKConstants

// NSUserDefaults
NSString *kHasRunBefore = @"hasRunBefore";

#warning refractor eg kH -> kFileK
// File
NSString *kFile = @"File";
NSString *kH = @"h";
NSString *kLength = @"length";
NSString *kFileName = @"fileName";

// Letter
NSString *kLetter = @"Letter";
NSString *kLetterName = @"letterName";
NSString *kI = @"i";
NSString *kP = @"p";
NSString *kOccurence = @"occurence";

// LZW
NSString *kLzwLetter = @"lzwLetter";
NSString *kCode = @"code";
NSString *kString = @"string";

#warning refractor Huffman to Hoffman
// Hoffman
NSString *kHoffmanTreeLeaf = @"";
NSString *kHoffmanTreeLeafLetterName = @"";
NSString *kHoffmanTreeLeafF = @"";
NSString *kHoffmanTreeLeafLeftLeaf = @"";
NSString *kHoffmanTreeLeafRightLeaf = @"";


@end
