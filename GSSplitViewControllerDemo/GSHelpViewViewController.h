//
//  GSHelpViewViewController.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/18/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "GSAppDelegate.h"
#import "MBProgressHUD.h"
#import "fileUploadEngine.h"
#import "GSApiResponseObjectItem.h"

@interface GSHelpViewViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    GSApiResponseObjectItem *jsonData;
}

@property (strong, nonatomic) fileUploadEngine *flUploadEngine;
@property (strong, nonatomic) MKNetworkOperation *flOperation;


@property (readwrite, retain) IBOutlet UIScrollView *scrollView;
@property (readwrite, retain) IBOutlet UIView *helpView;
@property (readwrite, retain) IBOutlet UITextField *txtName;
@property (readwrite, retain) IBOutlet UITextField *txtEmail;
@property (readwrite, retain) IBOutlet UITextView *txtMessage;

@property (readwrite, retain) IBOutlet UIButton *btnSend;

-(IBAction)btnSendPressed:(id)sender;

@end
