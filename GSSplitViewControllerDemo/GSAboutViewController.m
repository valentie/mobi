//
//  GSAboutViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/18/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSAboutViewController.h"
#import "URLConnection.h"

@interface GSAboutViewController ()

@end

@implementation GSAboutViewController
@synthesize tvDetails,lblHeader;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"ABOUT US", @"ABOUT US");
    
    
    tvDetails.font = [UIFont systemFontOfSize:FONTSIZE16];
    lblHeader.font = [UIFont systemFontOfSize:FONTSIZE21];
    
    
    
    // END ADD BUTTONS
    UIButton *navBarButtonOpenMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    navBarButtonOpenMenu.bounds = CGRectMake( 0, 0, 24, 24);
    [navBarButtonOpenMenu setImage:[UIImage imageNamed:@"open-menu-burger"] forState:UIControlStateNormal];
    UIBarButtonItem *navBarButtonOpenMenuItem = [[UIBarButtonItem alloc] initWithCustomView:navBarButtonOpenMenu];
    self.navigationItem.leftBarButtonItem = navBarButtonOpenMenuItem;
    [navBarButtonOpenMenu addTarget:self action:@selector(sideMenuOpenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    // END ADD BUTTONS
    
    [self loadAbout];
}

-(void)sideMenuOpenButtonPressed:(id)sender
{
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.splitViewController setMasterPaneShown:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)loadAbout
{
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@about",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    [URLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response)
     {
         GSApiResponseObjectItem *jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         if (jsonData.statusCode > 0)
         {
             // an error occurred
             
         } else {
             // no error
             
             NSString *title = [jsonData.responseData valueForKey:@"title"];
             NSString *description = [jsonData.responseData valueForKey:@"description"];
             
             tvDetails.text = description;
             lblHeader.text = title;
             tvDetails.font = [UIFont systemFontOfSize:FONTSIZE16];
             lblHeader.font = [UIFont systemFontOfSize:FONTSIZE21];
         }
         
     } errorBlock:^(NSError *error) {
         // when error occurs

     } uploadProgressBlock:^(float progress) {
         // when upload progresses
         
     } downloadProgressBlock:^(float progress) {
         // when download progressses
         
     }];
    
}

@end
