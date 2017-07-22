//
//  GSFavouritesViewController.h
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 8/24/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSAppDelegate.h"
#import "fileUploadEngine.h"
#import "MBProgressHUD.h"

@interface GSVideoUploadViewController : UIViewController <UIAlertViewDelegate,UITextFieldDelegate,UITextViewDelegate,MBProgressHUDDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    MBProgressHUD *HUD;
    NSURL *videoUrl;
    bool hasLoaded;
    GSAppDelegate *appDelegate;
    
}

@property (strong, nonatomic) fileUploadEngine *flUploadEngine;
@property (strong, nonatomic) MKNetworkOperation *flOperation;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *blockView;

@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIButton *btnAddTag;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIButton *btnUpload;

@property (strong, nonatomic) IBOutlet UITextField *txtTitle;
@property (strong, nonatomic) IBOutlet UITextField *txtTags;
@property (strong, nonatomic) IBOutlet UILabel *txtCategory;
@property (strong, nonatomic) IBOutlet UITextView *txtDescription;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;


-(IBAction)btnBackPressed:(id)sender;
-(IBAction)btnUploadPressed:(id)sender;
-(IBAction)btnAddTagPressed:(id)sender;
@end
