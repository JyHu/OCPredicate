//
//  REControl.h
//  OCPredicate
//
//  Created by 胡金友 on 15/5/15.
//  Copyright (c) 2015年 胡金友. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface REControl : NSObject

// 单例管理中心
+ (REControl *)shareControl;

// 正则属性
@property (assign, nonatomic) NSRegularExpressionOptions reOptions;

// 匹配属性
@property (assign, nonatomic) NSMatchingOptions matchOptions;

// 是否匹配0组
@property (assign, nonatomic) BOOL matchGroupZero;

@end
