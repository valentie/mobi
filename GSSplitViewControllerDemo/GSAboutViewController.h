//
//  GSAboutViewController.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/18/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "GSAppDelegate.h"
@interface GSAboutViewController : UIViewController

@property (nonatomic, readwrite) IBOutlet UITextView *tvDetails;
@property (nonatomic, readwrite) IBOutlet UILabel *lblHeader;
@end
