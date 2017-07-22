//
//  GSNewsArticleViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/19/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import "GSNewsArticleViewController.h"

@interface GSNewsArticleViewController ()

@end

@implementation GSNewsArticleViewController

@synthesize jsonData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"ARTICLE";
    
    // END ADD BUTTONS
    UIButton *navBarButtonOpenMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    navBarButtonOpenMenu.bounds = CGRectMake( 0, 0, 24, 24);
    [navBarButtonOpenMenu setImage:[UIImage imageNamed:@"open-menu-burger"] forState:UIControlStateNormal];
    UIBarButtonItem *navBarButtonOpenMenuItem = [[UIBarButtonItem alloc] initWithCustomView:navBarButtonOpenMenu];
    self.navigationItem.leftBarButtonItem = navBarButtonOpenMenuItem;
    [navBarButtonOpenMenu addTarget:self action:@selector(sideMenuOpenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    // END ADD BUTTONS
    
    NSLog(@"jsonData: %@",jsonData.responseData);
    
    self.lblHeader.text = [jsonData.responseData objectForKey:@"title"];    
    self.txtContent.text =[jsonData.responseData valueForKey:@"content"];
    self.imageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@news/%i.png",API_IMAGE_HOST,[[jsonData.responseData valueForKey:@"id"] intValue]]];
    
    
    [self.lblHeader setFont:[UIFont systemFontOfSize:FONTSIZE21]];
    [self.txtContent setFont:[UIFont systemFontOfSize:FONTSIZE16]];
    
}


-(void)sideMenuOpenButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
