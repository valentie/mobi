//
//  GSForgotPasswordViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/17/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSForgotPasswordViewController.h"
#import "Constants.h"
#import "GSAppDelegate.h"
#import "GSLoginViewController.h"
#import "GSRegisterViewController.h"


@interface GSForgotPasswordViewController ()

@end

@implementation GSForgotPasswordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"PASSWORD", @"PASSWORD");
    
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
    
    
    
    [self.lblHeader setText:NSLocalizedString(@"Forgot Password?", @"Forgot Password?")];
    [self.btnLogin.titleLabel setText:NSLocalizedString(@"LOGIN", @"LOGIN")];
    [self.btnReset.titleLabel setText:NSLocalizedString(@"RESET", @"RESET")];
    [self.txtEmail setPlaceholder:NSLocalizedString(@"Enter Email", @"Enter Email")];
    [self.lblSubHeader setText:NSLocalizedString(@"Please enter your email address to recover your password.", @"Please enter your email address to recover your password.")];
    
    
    
    // set font
    [self.lblHeader setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.btnLogin.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.btnReset.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.txtEmail setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.lblSubHeader setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    
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



-(IBAction)btnResetPressed:(id)sender
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
    [postParams setObject:SYSTEM_BRAND forKey:@"device_brand"];
    [postParams setObject:SYSTEM_MODEL forKey:@"device_model"];
    [postParams setObject:SYSTEM_VERSION forKey:@"device_os"];
    [postParams setObject:[appDelegate deviceID] forKey:@"device_uuid"];
    
    NSLog(@"post params: %@",postParams);
    
    // do upload
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:API_HOST customHeaderFields:nil];
    
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:[NSString stringWithFormat:@"%@password",API_END_POINT]];
    [self.flOperation addCompletionHandler:^(MKNetworkOperation* operation) {
        
        jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (jsonData.statusCode > 0)
        {
            // an error occurred
            HUD.labelText = jsonData.statusMessage;
            [HUD hide:YES afterDelay:2.0];
            
        } else {
            
            // no error
            HUD.progress = 100;
            [HUD hide:YES afterDelay:0];
            [self alertStatus:@"Reset success." :@"Check Email for instructions." :1];
            
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
    [self.scrollView setContentOffset:CGPointMake(0, self.forgotPasswordView.frame.origin.y-50) animated:YES];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height)];
}

@end
