//
//  GSProfileViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/24/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import "GSProfileViewController.h"

@interface GSProfileViewController ()

@end

@implementation GSProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"PROFILE", @"PROFILE");
    
    // END ADD BUTTONS
    UIButton *navBarButtonOpenMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    navBarButtonOpenMenu.bounds = CGRectMake( 0, 0, 24, 24);
    [navBarButtonOpenMenu setImage:[UIImage imageNamed:@"open-menu-burger"] forState:UIControlStateNormal];
    UIBarButtonItem *navBarButtonOpenMenuItem = [[UIBarButtonItem alloc] initWithCustomView:navBarButtonOpenMenu];
    self.navigationItem.leftBarButtonItem = navBarButtonOpenMenuItem;
    [navBarButtonOpenMenu addTarget:self action:@selector(sideMenuOpenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    // END ADD BUTTONS
    
    
    // MAKE PROFILE IMAGE CIRCLE
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2.0;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.borderWidth =3.0;
    self.imageView.layer.borderColor=[UIColor whiteColor].CGColor;
    // END PROFILE IMAGE CIRCLE
    
    
    // some info
    self.txtName.font = [UIFont systemFontOfSize:FONTSIZE21];
    self.txtEmail.font = [UIFont systemFontOfSize:FONTSIZE21];
    self.txtPhone.font = [UIFont systemFontOfSize:FONTSIZE21];
    self.txtPassword.font = [UIFont systemFontOfSize:FONTSIZE21];
    self.lblPasswordWarning.font = [UIFont systemFontOfSize:FONTSIZE16];
    self.btnSave.titleLabel.font = [UIFont systemFontOfSize:FONTSIZE21];
    
    
    // ADD LOADER
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    
    //NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    NSString *user_name = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"];
    NSString *user_email = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_email"];
    NSString *user_phone = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_phone"];
    NSString *user_credits = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_credits"];
    NSString *fb_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"fb_id"];
    
    if (user_credits != nil && user_email != nil) {
        // Code to log user in
        self.txtName.text = user_name;
        self.txtEmail.text = user_email;
        self.txtPhone.text = user_phone;
    }
    if (fb_id != nil && ![fb_id isEqualToString:@"0"]) {
        // Code to log user in

        self.imageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=640&height=640",fb_id]];
        self.btnSave.enabled = NO;
        [self.btnSave setTitle:NSLocalizedString(@"Facebook User", @"Facebook User") forState:UIControlStateNormal];
        
        
    } else {
        self.btnSave.enabled = YES;
        [self.btnSave setTitle:NSLocalizedString(@"Save", @"Save") forState:UIControlStateNormal];
        
    }
    
    // open keyboard
    [self.txtName becomeFirstResponder];
    
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
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


-(IBAction)btnSavePressed:(id)sender
{
    
    // delegate
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    // show loader...
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.labelText = NSLocalizedString(@"Connecting...", @"Connecting...");
    [HUD show:YES];
    
    
    // add params!
     NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
    [postParams setObject:user_id forKey:@"user_id"];
    [postParams setObject:self.txtEmail.text forKey:@"user_email"];
    [postParams setObject:self.txtName.text forKey:@"user_name"];
    [postParams setObject:self.txtPhone.text forKey:@"user_phone"];
    [postParams setObject:SYSTEM_BRAND forKey:@"device_brand"];
    [postParams setObject:SYSTEM_MODEL forKey:@"device_model"];
    [postParams setObject:SYSTEM_VERSION forKey:@"device_os"];
    [postParams setObject:[appDelegate deviceID] forKey:@"device_uuid"];
    if ([self.txtPassword.text length] != 0) [postParams setObject:self.txtPassword.text forKey:@"user_password"];
    

    // do upload
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:API_HOST customHeaderFields:nil];
    
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:[NSString stringWithFormat:@"%@profile_update",API_END_POINT]];
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
            [defaults setObject:[jsonData.responseData valueForKey:@"fb_id"] forKey:@"fb_id"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_id"] forKey:@"user_id"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_name"] forKey:@"user_name"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_email"] forKey:@"user_email"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_credits"] forKey:@"user_credits"];
            [defaults setObject:[jsonData.responseData valueForKey:@"user_phone"] forKey:@"user_phone"];
            [defaults synchronize];
            
            HUD.progress = 100;
            [HUD hide:YES afterDelay:0];
            [self alertStatus:NSLocalizedString(@"Updated", @"Updated") :NSLocalizedString(@"Your profile has been updated", @"Your profile has been updated") :1];

            
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


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"edit mode on");
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height+KEYBOARDHEIGHT)];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height)];
}


@end
