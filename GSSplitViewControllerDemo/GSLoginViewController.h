//
//  GSLoginViewController.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/17/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "fileUploadEngine.h"
#import "GSApiResponseObjectItem.h"
#import "MBProgressHUD.h"
#import "Constants.h"
#import "GSAppDelegate.h"


@interface GSLoginViewController : UIViewController <UITextFieldDelegate, MBProgressHUDDelegate>
{

    MBProgressHUD *HUD;
    GSApiResponseObjectItem *jsonData;
}

@property (strong, nonatomic) fileUploadEngine *flUploadEngine;
@property (strong, nonatomic) MKNetworkOperation *flOperation;



@property (readwrite, retain) IBOutlet UIScrollView *scrollView;
@property (readwrite, retain) IBOutlet UIView *loginView;
@property (readwrite, retain) IBOutlet UILabel *lblHeader;
@property (readwrite, retain) IBOutlet UILabel *lblOr;
@property (readwrite, retain) IBOutlet UIButton *btnLogin;
@property (readwrite, retain) IBOutlet UIButton *btnFacebookLogin;
@property (readwrite, retain) IBOutlet UIButton *btnForgotPassword;
@property (readwrite, retain) IBOutlet UITextField *txtEmail;
@property (readwrite, retain) IBOutlet UITextField *txtPassword;



-(IBAction)btnLoginPressed:(id)sender;
-(IBAction)btnFacebookLoginPressed:(id)sender;
-(IBAction)btnForgotPasswordPressed:(id)sender;

@end
