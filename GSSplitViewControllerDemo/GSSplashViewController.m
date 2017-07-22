//
//  GSSplashViewController.m
//  MOBITV
//
//  Created by Renee van der Kooi on 12/9/2558 BE.
//  Copyright © 2558 Mindzone Company Limited. All rights reserved.
//

#import "GSSplashViewController.h"
#import "GSAppDelegate.h"

@interface GSSplashViewController ()

@end

@implementation GSSplashViewController


- (id) init {
    
    if (self = [super init])
    {
        NSLog(@"INIT");
        self.view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:251.0/255.0 alpha:1];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        self.imageView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:248.0/255.0 blue:251.0/255.0 alpha:1];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.imageView];
        
        NSURL *url = [NSURL URLWithString:@"http://www.mobitelevision.tv/assets/content/splash.png"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [self.imageView setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           self.imageView.image = image;
                                           [self performSelector:@selector(moveToApp) withObject:nil afterDelay:5.0];
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           
                                           [self performSelector:@selector(moveToApp) withObject:nil afterDelay:1.0];
                                           
                                       }];
        
    }
    
    return self;
}

-(void)moveToApp
{
    
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate showApplication];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
