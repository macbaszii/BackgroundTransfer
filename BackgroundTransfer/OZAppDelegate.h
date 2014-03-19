//
//  OZAppDelegate.h
//  BackgroundTransfer
//
//  Created by Kiattisak Anoochitarom on 3/18/2557 BE.
//  Copyright (c) 2557 Kiattisak Anoochitarom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OZAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) void (^backgroundSessionCompletionHandler)();

@end
