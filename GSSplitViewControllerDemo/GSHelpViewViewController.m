//
//  GSHelpViewViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/18/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSHelpViewViewController.h"
#import "NSString+Common.h"

#define PLACEHOLDERMESSAGE @"Enter a message..."

@interface GSHelpViewViewController ()

@end

@implementation GSHelpViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"HELP", @"HELP");
    
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

    
    // some styling
    [self.txtName setFont:[UIFont systemFontOfSize:FONTSIZE18]];
    [self.txtEmail setFont:[UIFont systemFontOfSize:FONTSIZE18]];
    [self.txtMessage setFont:[UIFont systemFontOfSize:FONTSIZE18]];
    self.txtMessage.textColor = [UIColor darkGrayColor];
    self.txtMessage.text = PLACEHOLDERMESSAGE;
    [self.btnSend.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    
    
    
    NSString *user_name = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"];
    NSString *user_email = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_email"];
    if (user_email != nil && user_name != nil) {
        self.txtName.text = user_name;
        self.txtEmail.text = user_email;
        [self.txtMessage becomeFirstResponder];
    } else {
        [self.txtName becomeFirstResponder];
    }
    
    
    
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

-(void)showErrorWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)btnSendPressed:(id)sender
{
    
    
    
    if ( [self.txtName.text length] == 0 )
    {
        [self showErrorWithTitle:NSLocalizedString(@"Incomplete", @"Incomplete") andMessage:NSLocalizedString(@"Please fill out your name.", @"Please fill out your name.")];
        return;
    }
    if ( [self.txtEmail.text length] == 0 )
    {
        [self showErrorWithTitle:NSLocalizedString(@"Incomplete", @"Incomplete") andMessage:NSLocalizedString(@"Please fill out your e-mail address.", @"Please fill out your e-mail address.")];
        return;
    }
    if (![self.txtEmail.text stringIsValidEmail])
    {
        [self showErrorWithTitle:NSLocalizedString(@"Invalid", @"Invalid") andMessage:NSLocalizedString(@"Please enter a valid e-mail address.", @"Please enter a valid e-mail address.")];
        return;
    }
    
    if ( [self.txtMessage.text length] == 0 )
    {
        [self showErrorWithTitle:NSLocalizedString(@"Incomplete", @"Incomplete") andMessage:NSLocalizedString(@"Please enter a message", @"Please enter a message")];
        return;
    }
    if ([self.txtMessage.text isEqualToString:PLACEHOLDERMESSAGE])
    {
        [self showErrorWithTitle:NSLocalizedString(@"Incomplete", @"Incomplete") andMessage:NSLocalizedString(@"Please enter a message", @"Please enter a message")];
        return;
    }
    
    
    // show loader...
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.labelText = NSLocalizedString(@"Connecting...", @"Connecting...");
    [HUD show:YES];
    
    // do upload
    self.flUploadEngine = [[fileUploadEngine alloc] initWithHostName:API_HOST customHeaderFields:nil];
    
    // add params!
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
    [postParams setObject:self.txtName.text forKey:@"name"];
    [postParams setObject:self.txtEmail.text forKey:@"email"];
    [postParams setObject:self.txtMessage.text forKey:@"message"];
    [postParams setObject:SYSTEM_BRAND forKey:@"device_brand"];
    [postParams setObject:SYSTEM_MODEL forKey:@"device_model"];
    [postParams setObject:SYSTEM_VERSION forKey:@"device_os"];
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    if (user_id != nil && ![user_id isEqualToString:@"0"]) {
        // Code to log user in
        [postParams setObject:user_id forKey:@"user_id"];
    }

    
    
    self.flOperation = [self.flUploadEngine postDataToServer:postParams path:[NSString stringWithFormat:@"%@help",API_END_POINT]];
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
            HUD.labelText = NSLocalizedString(@"Thank you for your message.", @"Thank you for your message.");
            [HUD hide:YES afterDelay:1.0];
            
            NSLog(@"%@",jsonData.responseData);
            self.txtName.text = @"";
            self.txtEmail.text = @"";
            self.txtMessage.text = @"";
            
        }
    }
                              errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
                                  HUD.labelText = error.localizedDescription;
                                  [HUD hide:YES afterDelay:2];
                              }
     ];
    
    [self.flOperation onUploadProgressChanged:^(double progress) {
        HUD.progress = progress;
        HUD.labelText = [NSString stringWithFormat:@"%.0f%%",progress*100];
    }];
    
    [self.flUploadEngine enqueueOperation:self.flOperation];
    
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"edit mode on");
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height+KEYBOARDHEIGHT)];
    [self.scrollView setContentOffset:CGPointMake(0, self.helpView.frame.origin.y-50) animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height)];
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height+KEYBOARDHEIGHT)];
    [self.scrollView setContentOffset:CGPointMake(0, self.helpView.frame.origin.y-50) animated:YES];
    if ([textView.text isEqualToString:PLACEHOLDERMESSAGE]) {
        textView.text = @"";
        textView.textColor = [UIColor darkGrayColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height)];
    if ([textView.text isEqualToString:@""]) {
        textView.text = PLACEHOLDERMESSAGE;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}








@end
