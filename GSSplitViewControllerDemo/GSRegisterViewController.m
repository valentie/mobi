//
//  GSRegisterViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/17/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSRegisterViewController.h"
#import "Constants.h"
#import "GSAppDelegate.h"
#import "GSLoginViewController.h"
#import "GSForgotPasswordViewController.h"

@interface GSRegisterViewController ()

@end

@implementation GSRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"REGISTER", @"REGISTER");
    
    
    // END ADD BUTTONS
    UIButton *navBarButtonOpenMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    navBarButtonOpenMenu.bounds = CGRectMake( 0, 0, 24, 24);
    [navBarButtonOpenMenu setImage:[UIImage imageNamed:@"open-menu-burger"] forState:UIControlStateNormal];
    UIBarButtonItem *navBarButtonOpenMenuItem = [[UIBarButtonItem alloc] initWithCustomView:navBarButtonOpenMenu];
    self.navigationItem.leftBarButtonItem = navBarButtonOpenMenuItem;
    [navBarButtonOpenMenu addTarget:self action:@selector(sideMenuOpenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    // END ADD BUTTONS
    
    // ADD LOADER
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    // open keyboard
    [self.txtEmail becomeFirstResponder];
    
    
    [self.lblHeader setText:NSLocalizedString(@"Register as new user", @"Register as new user")];
    [self.lblOr setText:NSLocalizedString(@"or", @"or")];
    [self.txtEmail setPlaceholder:NSLocalizedString(@"Enter Email or Phone", @"Enter Email or Phone")];
    [self.txtPassword setPlaceholder:NSLocalizedString(@"Enter Password", @"Enter Password")];
    [self.btnLogin setTitle:NSLocalizedString(@"LOGIN", @"LOGIN") forState:UIControlStateNormal];
    [self.btnRegister setTitle:NSLocalizedString(@"REGISTER", @"REGISTER") forState:UIControlStateNormal];
    [self.btnFacebookLogin setTitle:NSLocalizedString(@"FACEBOOK LOGIN", @"FACEBOOK LOGIN") forState:UIControlStateNormal];
    
    
    // set font
    [self.lblHeader setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.lblOr setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.btnLogin.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.btnRegister.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.btnFacebookLogin.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.txtEmail setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.txtPassword setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    
}

-(void)sideMenuOpenButtonPressed:(id)sender
{
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.splitViewController setMasterPaneShown:YES animated:YES];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

-(IBAction)btnFacebookLoginPressed:(id)sender
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            // Process error
            NSLog(@" error");
            [self alertStatus:@"Sign in Failed." :@"Facebook Login Error!" :0];
            
        } else if (result.isCancelled) {
            // Handle cancellations
            NSLog(@" cancelled");
            [self alertStatus:@"Sign in Failed." :@"Cancelled by user!" :0];
            
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if ([result.grantedPermissions containsObject:@"email"]) {
                // Do work
                NSLog(@"Granted all permission");
                if ([FBSDKAccessToken currentAccessToken])
                {
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, email,gender"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                     {
                         if (!error)
                         {
                             NSLog(@"%@",[result valueForKey:@"id"]);
                             NSLog(@"%@",[result valueForKey:@"email"]);
                             NSLog(@"%@",[result valueForKey:@"name"]);
                             NSLog(@"%@",[result valueForKey:@"gender"]);
                             [self doFacebookLoginOrRegisterWithFBID:[result valueForKey:@"id"] andName:[result valueForKey:@"name"] andEmail:[result valueForKey:@"email"] andGender:[result valueForKey:@"gender"]];
                         } else {
                             [self alertStatus:@"Sign in Failed." :@"Error!" :0];
                         }
                     }];
                }
                
            } else {
                
                [self alertStatus:@"Sign in Failed." :@"Error!" :0];
                
            }
        }
    }];
}
-(void)doFacebookLoginOrRegisterWithFBID:(NSString *)fb_id andName:(NSString *)name andEmail:(NSString *)email andGender:(NSString *)gender
{
    // delegate
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    // show loader...
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.labelText = @"Connecting...";
    [HUD show:YES];
    
    
    // add params!
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
    [postParams setObject:fb_id forKey:@"fb_id"];
    [postParams setObject:name forKey:@"user_name"];
    [postParams setObject:email forKey:@"user_email"];
    [postParams setObject:gender forKey:@"user_gender"];
    [postParams setObject:SYSTEM_BRAND forKey:@"device_brand"];
    [postParams setObject:SYSTEM_MODEL forKey:@"device_model"];
    [postParams setObject:SYSTEM_VERSION forKey:@"device_os"];
    [postParams setObject:[appDelegate deviceID] forKey:@"device_uuid"];
    
    NSLog(@"post params: %@",postParams);
    
    // do upload
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:API_HOST customHeaderFields:nil];
    
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:[NSString stringWithFormat:@"%@facebook_login",API_END_POINT]];
    [self.flOperation addCompletionHandler:^(MKNetworkOperation* operation) {
        
        jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (jsonData.statusCode > 0)
        {
            // an error occurred
            HUD.labelText = jsonData.statusMessage;
            [HUD hide:YES afterDelay:2.0];
            
        } else {
            
            // no error
            // Store the data
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
            [defaults setObject:[jsonData.responseData valueForKey:@"fb_id"] forKey:@"fb_id"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_id"] forKey:@"user_id"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_name"] forKey:@"user_name"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_email"] forKey:@"user_email"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_credits"] forKey:@"user_credits"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_phone"] forKey:@"user_phone"];
            [defaults setObject:[jsonData.responseData valueForKey:@"education_activated"] forKey:@"education_activated"];
            [defaults synchronize];
            
            HUD.progress = 100;
            [HUD hide:YES afterDelay:0];
            [self alertStatus:@"Sign in success." :@"You are now signed in!" :1];
            NSLog(@"%@",jsonData.responseData);
            
            GSDetailViewController *detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
            [self.view endEditing:YES];
            [appDelegate.nav2 setViewControllers:@[detailViewController] animated:NO];
            
        }
    }
                              errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
                                  HUD.labelText = error.localizedDescription;
                                  [HUD hide:YES afterDelay:2];
                                  
                                  NSLog(@"error: %@",error);
                                  
                              }
     ];
    
    [self.flOperation onUploadProgressChanged:^(double progress) {
        HUD.progress = progress;
        HUD.labelText = [NSString stringWithFormat:@"%.0f%%",progress*100];
    }];
    
    [self.flUploadEngine enqueueOperation:self.flOperation];
}


-(IBAction)btnRegisterPressed:(id)sender
{
    // delegate
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    // show loader...
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.labelText = @"Connecting...";
    [HUD show:YES];
    
    
    // add params!
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
    [postParams setObject:self.txtEmail.text forKey:@"user_email"];
    [postParams setObject:self.txtPassword.text forKey:@"user_password"];
    [postParams setObject:SYSTEM_BRAND forKey:@"device_brand"];
    [postParams setObject:SYSTEM_MODEL forKey:@"device_model"];
    [postParams setObject:SYSTEM_VERSION forKey:@"device_os"];
    [postParams setObject:[appDelegate deviceID] forKey:@"device_uuid"];
    
    NSLog(@"post params: %@",postParams);
    
    // do upload
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:API_HOST customHeaderFields:nil];
    
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:[NSString stringWithFormat:@"%@register",API_END_POINT]];
    [self.flOperation addCompletionHandler:^(MKNetworkOperation* operation) {
        
        jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (jsonData.statusCode > 0)
        {
            // an error occurred
            HUD.labelText = jsonData.statusMessage;
            [HUD hide:YES afterDelay:2.0];
            
        } else {
            
            // no error
            // Store the data
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
            [defaults setObject:[jsonData.responseData valueForKey:@"fb_id"] forKey:@"fb_id"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_id"] forKey:@"user_id"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_name"] forKey:@"user_name"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_email"] forKey:@"user_email"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_credits"] forKey:@"user_credits"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_phone"] forKey:@"user_phone"];
            [defaults setObject:[jsonData.responseData valueForKey:@"education_activated"] forKey:@"education_activated"];
            [defaults synchronize];
            
            HUD.progress = 100;
            [HUD hide:YES afterDelay:0];
            [self alertStatus:@"Sign in success." :@"You are now signed in!" :1];
            
            NSLog(@"%@",jsonData.responseData);
            
            GSDetailViewController *detailViewController = [[GSDetailViewController alloc] initWithNibName:@"GSDetailViewController" bundle:nil];
            [self.view endEditing:YES];
            [appDelegate.nav2 setViewControllers:@[detailViewController] animated:NO];
            
        }
    }
                              errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
                                  HUD.labelText = error.localizedDescription;
                                  [HUD hide:YES afterDelay:2];
                                  
                                  NSLog(@"error: %@",error);
                                  
                              }
     ];
    
    [self.flOperation onUploadProgressChanged:^(double progress) {
        HUD.progress = progress;
        HUD.labelText = [NSString stringWithFormat:@"%.0f%%",progress*100];
    }];
    
    [self.flUploadEngine enqueueOperation:self.flOperation];
    
    
    
    @try {
        
        
    }
    @catch (NSException * e) {
        
        NSLog(@"Exception: %@", e);
        
    }

}

-(IBAction)btnLoginPressed:(id)sender
{
    GSLoginViewController *detailViewController = [[GSLoginViewController alloc] initWithNibName:@"GSLoginViewController" bundle:nil];
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.nav2 setViewControllers:@[detailViewController] animated:NO];

}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"edit mode on");
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height+KEYBOARDHEIGHT)];
    [self.scrollView setContentOffset:CGPointMake(0, self.registerView.frame.origin.y-50) animated:YES];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height)];
}
@end
