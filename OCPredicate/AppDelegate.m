//
//  AppDelegate.m
//  OCPredicate
//
//  Created by 胡金友 on 15/5/14.
//  Copyright (c) 2015年 胡金友. All rights reserved.
//

#import "AppDelegate.h"
#import "REControl.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSMenu *menu = [[NSApplication sharedApplication] menu];
    
    NSArray *menuItems = menu.itemArray;
    
    NSString *pp = [[NSBundle mainBundle] pathForResource:@"SampleRE" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:pp];
    NSArray *reTips = [[dict objectForKey:@"toolTips"] objectForKey:@"reTips"];
    NSArray *maTips = [[dict objectForKey:@"toolTips"] objectForKey:@"matchTips"];
    
    // 添加菜单项
    for (NSMenuItem *menuItem in menuItems)
    {
        if (menuItem.tag == 100)
        {
            menuItems = menuItem.submenu.itemArray;
            
            for (NSMenuItem *item in menuItems)
            {
                switch (item.tag)
                {
                    case 110:
                    case 120:
                    case 130:
                    {
                        item.action = @selector(reHelp:);
                    }
                        break;
                        
                    case 140:
                    {
                        NSArray *subItems = item.submenu.itemArray;
                        
                        for (NSMenuItem *si in subItems)
                        {
                            si.action = @selector(reOptions:);
                            
                            if (si.tag == 141)
                            {
                                si.state = 1;
                            }
                            
                            NSInteger index = si.tag - 141;
                            
                            if (index < reTips.count)
                            {
                                si.toolTip = [reTips objectAtIndex:index];
                            }
                        }
                    }
                        break;
                        
                    case 150:
                    {
                        NSArray *subItems = item.submenu.itemArray;
                        
                        for (NSMenuItem *si in subItems)
                        {
                            si.action = @selector(matchOptions:);
                            
                            if (si.tag == 159)
                            {
                                si.state = 1;
                                
                                si.toolTip = [maTips lastObject];
                                
                                continue;
                            }
                            
                            NSInteger index = si.tag - 151;
                            
                            if (index < maTips.count)
                            {
                                si.toolTip = [maTips objectAtIndex:index];
                            }
                        }
                    }
                        break;
                        
                    case 160:
                    {
                        item.action = @selector(matchGroupZero:);
                        item.toolTip = @"如果需要截取分组内容，建议打开此项。";
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
}

// 正则帮助的菜单项
- (void)reHelp:(NSMenuItem *)item
{
    switch (item.tag)
    {
        case 120:
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.jb51.net/tools/zhengze.html"]];
            break;
            
        case 130:
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://tool.oschina.net/regex"]];
            break;
            
        default:
            break;
    }
}

// 正则属性菜单项
- (void)reOptions:(NSMenuItem *)item
{
    NSInteger flag = (1 << (item.tag - 141));
    
    NSInteger options = [REControl shareControl].reOptions;
    
    if (options == flag)
    {
        return;
    }
    
    if (item.state == 0)
    {
        options = options | flag;
    }
    else
    {
        options = options & ~flag;
    }
    
    [REControl shareControl].reOptions = options;
    
    item.state = 1 - item.state;
    
    NSLog(@"%@ - %@",@([REControl shareControl].reOptions), @(item.tag));
}

// 匹配属性菜单项
- (void)matchOptions:(NSMenuItem *)item
{
    if (item.tag == 159)
    {
        NSArray *arr = item.parentItem.submenu.itemArray;
        
        for (NSMenuItem *i in arr)
        {
            if (i.tag != 159)
            {
                i.state = 0;
            }
        }
        
        item.state = 1;
    }
    else
    {
        NSInteger flag = (1 << (item.tag - 151));
        
        NSInteger options = [REControl shareControl].matchOptions;
        
        if (!options)
        {
            [REControl shareControl].matchOptions = flag;
            
            item.state = 1 - item.state;
        }
        else
        {
            if (options == flag)
            {
                return;
            }
            
            if (item.state == 0)
            {
                options = options | flag;
            }
            else
            {
                options = options & ~flag;
            }
            
            [REControl shareControl].matchOptions = options;
            
            item.state = 1 - item.state;
        }
        
        NSMenuItem *dItem = [item.parentItem.submenu itemWithTag:159];
        
        dItem.state = 0;
    }
}

// 匹配0组的菜单选择项
- (void)matchGroupZero:(NSMenuItem *)item
{
    item.state = 1 - item.state;
    
    [REControl shareControl].matchGroupZero = (BOOL)item.state;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
