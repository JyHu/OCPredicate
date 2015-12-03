//
//  REControl.m
//  OCPredicate
//
//  Created by 胡金友 on 15/5/15.
//  Copyright (c) 2015年 胡金友. All rights reserved.
//

#import "REControl.h"

@implementation REControl

@synthesize reOptions = _reOptions;

@synthesize matchOptions = _matchOptions;

@synthesize matchGroupZero = _matchGroupZero;

+ (REControl *)shareControl
{
    static REControl *control;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        control = [[REControl alloc] init];
    });
    
    return control;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _reOptions = NSRegularExpressionCaseInsensitive;
        _matchOptions = 0;
        _matchGroupZero = YES;
    }
    
    return self;
}

@end
