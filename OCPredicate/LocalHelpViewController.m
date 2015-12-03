//
//  LocalHelpViewController.m
//  OCPredicate
//
//  Created by 胡金友 on 15/5/16.
//  Copyright (c) 2015年 胡金友. All rights reserved.
//

#import "LocalHelpViewController.h"
#import <WebKit/WebKit.h>

@interface LocalHelpViewController ()

@property (weak) IBOutlet WebView *localHelpWebView;

@end

@implementation LocalHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSString *localHelpPath = [[NSBundle mainBundle] pathForResource:@"rehel"
                                                              ofType:@"html"];
    
    NSString *htmlString = [[NSString alloc] initWithContentsOfFile:localHelpPath
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
    
    // 加载本地帮助文件
    [[self.localHelpWebView mainFrame] loadHTMLString:htmlString
                                              baseURL:[NSURL URLWithString:localHelpPath]];
}

@end
