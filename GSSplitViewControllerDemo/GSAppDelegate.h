//
//  GSAppDelegate.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 2015-08-10.
//  Copyright (c) 2014 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "GSSplitViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "GSDetailViewController.h"
#import "GSMasterViewController.h"
#import "GSMediaPlayerView.h"







@interface GSAppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *nav2;
    UIView *playerView;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GSSplitViewController *splitViewController;
@property (readwrite, retain) UINavigationController *nav2;

@property (readwrite, strong) UIView *playerView;

@property (readwrite, strong) NSMutableArray *categories;

-(void)createPlayerView;
-(void)removePlayerView;
-(NSString*)deviceID;
-(void)showApplication;

@end
