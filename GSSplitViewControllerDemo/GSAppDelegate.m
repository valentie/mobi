//
//  GSAppDelegate.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 2015-08-10.
//  Copyright (c) 2014 Mindzone Company Limited. All rights reserved.
//

#import "GSAppDelegate.h"
#import "KeychainItemWrapper.h"
#import "PayPalMobile.h"
#import "GSSharedData.h"
#import <AudioToolbox/AudioToolbox.h>
#import "GSSplashViewController.h"
#import "UIDevice+FCUUID.h"
#import "RMStore.h"
#import "DeviceUID.h"

@implementation GSAppDelegate

@synthesize splitViewController, nav2, playerView, categories;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:11/255.0 green:167/255.0 blue:157/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithWhite:.0f alpha:0.f];
    shadow.shadowOffset = CGSizeMake(0, 0);
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSShadowAttributeName: shadow,
                                                           NSFontAttributeName: [UIFont systemFontOfSize:21.0f]
                                                           }];
    

    
    // push notifictions
    // Have to explicitly use the iOS8 api as the deprecated API is silently ignored on iOS8, surprisingly.
    if ([UIDevice currentDevice].systemVersion.intValue >= 8) { // iOS8+ API.
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else { // iOS7.
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
    
 
    
    //Display error is there is no URL
    if (![launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        NSLog(@"NO LAUNCH OPTIONS");
    }

    
    // Set the GSSplitViewController as the root view controller
    GSSplashViewController *viewController = [[GSSplashViewController alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
   // [self ShowApplication];
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}


-(void)showApplication
{
    // Initialize the view controllers
    GSMasterViewController *masterViewController = [[GSMasterViewController alloc] initWithNibName:@"GSMasterViewController" bundle:nil];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    
    GSDetailViewController *detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
    nav2 = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    masterViewController.detailViewNavController = nav2;
    
    // Create the GSSplitViewController
    splitViewController = [[GSSplitViewController alloc] init];
    splitViewController.delegate = masterViewController;
    splitViewController.viewControllers = @[nav1, nav2];
    splitViewController.presentsWithGesture = YES;
    splitViewController.masterPaneWidth = MAXWIDTHMASTERVIEW;
    
    
    
    // Set the GSSplitViewController as the root view controller
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = splitViewController;
    
    //[self.window makeKeyAndVisible];
}


-(void)createPlayerView
{
    if (playerView == nil)
    {
        playerView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        playerView.backgroundColor = [UIColor colorWithRed:0.21 green:0.21 blue:0.1 alpha:0.0];
        [self.window addSubview:playerView];
    }
}

-(void)removePlayerView
{
    [self performSelector:@selector(removePlayerViewDelayed) withObject:nil afterDelay:0.2];
}
-(void)removePlayerViewDelayed
{

    [[playerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [playerView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
    playerView = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[GSSharedData sharedManager] touch];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[GSSharedData sharedManager] touch];
    [FBSDKAppEvents activateApp];
}



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    
    if ([[url scheme] isEqualToString:@"mobitv"])
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:[url host]
                                                          message:[NSString stringWithFormat:@"%@",[url port]]
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                otherButtonTitles:nil];
        
        [message show];
    }
    
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

-(NSString*)deviceID
{
    //NSString *s = [[UIDevice currentDevice] uuid];
    return [DeviceUID uid];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

    
    [[GSSharedData sharedManager] submitAPNDeviceToken:hexToken];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    

    
#if !TARGET_IPHONE_SIMULATOR
    
    NSLog(@"remote notification: %@",[userInfo description]);
    
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    NSString *alert = [apsInfo objectForKey:@"alert"];
    NSLog(@"Received Push Alert: %@", alert);
    
    
    NSString *sound = [apsInfo objectForKey:@"sound"];
    NSLog(@"Received Push Sound: %@", sound);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    NSString *badge = [apsInfo objectForKey:@"badge"];
    NSLog(@"Received Push Badge: %@", badge);
    
    application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSLog(@"Notification received while running app");
        
        GSNewsViewController *detailViewController = [[GSNewsViewController alloc] initWithNibName:@"GSNewsViewController" bundle:nil];
        [self.nav2 setViewControllers:@[detailViewController] animated:NO];
        [self alertStatus:alert :@"MOBI TV" :1];
    } else {
        
        GSNewsViewController *detailViewController = [[GSNewsViewController alloc] initWithNibName:@"GSNewsViewController" bundle:nil];
        [self.nav2 setViewControllers:@[detailViewController] animated:NO];
        
        
    }

#endif
}


- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}
@end


@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end