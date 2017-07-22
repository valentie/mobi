//
//  GSProfileViewController.h
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/24/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "GSAppDelegate.h"
#import "fileUploadEngine.h"
#import "GSApiResponseObjectItem.h"
#import "MBProgressHUD.h"
#import "Constants.h"

@interface GSProfileViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, MBProgressHUDDelegate>
{
    
    MBProgressHUD *HUD;
    GSApiResponseObjectItem *jsonData;
}

@property (strong, nonatomic) fileUploadEngine *flUploadEngine;
@property (strong, nonatomic) MKNetworkOperation *flOperation;


@property (readwrite, retain) IBOutlet UIScrollView *scrollView;
@property (readwrite, retain) IBOutlet UIView *profileView;
@property (readwrite, retain) IBOutlet AsyncImageView *imageView;
@property (readwrite, retain) IBOutlet UITextField *txtName;
@property (readwrite, retain) IBOutlet UITextField *txtEmail;
@property (readwrite, retain) IBOutlet UITextField *txtPhone;

@property (readwrite, retain) IBOutlet UITextField *txtPassword;

@property (readwrite, retain) IBOutlet UILabel *lblPasswordWarning;

@property (readwrite, retain) IBOutlet UIButton *btnSave;

-(IBAction)btnSavePressed:(id)sender;

@end
