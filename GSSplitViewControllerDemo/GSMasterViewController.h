//
//  GSMasterViewController.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 2015-08-10.
//  Copyright (c) 2014 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSLoginViewController.h"
#import "GSRegisterViewController.h"
#import "GSFavouritesViewController.h"
#import "GSVideosViewController.h"
#import "GSPurchasedViewController.h"
#import "GSProfileViewController.h"
#import "GSNewsViewController.h"
#import "GSHelpViewViewController.h"
#import "GSAboutViewController.h"
#import "GSMasterCellObjectItem.h"

#import "fileUploadEngine.h"
#import "GSApiResponseObjectItem.h"

@class GSDetailViewController;

@interface GSMasterViewController : UITableViewController <GSSplitViewControllerDelegate, GSFavouritesViewControllerDelegate, GSPurchasedViewControllerDelegate, GSVideosViewControllerDelegate>
{
    NSDictionary *cellItems;
    NSArray *SectionTitles;
    GSApiResponseObjectItem *jsonData;
    bool showSubMenu;
    bool showSubMenu_education;
}

@property (strong, nonatomic) UINavigationController *detailViewNavController;

@property (strong, nonatomic) fileUploadEngine *flUploadEngine;
@property (strong, nonatomic) MKNetworkOperation *flOperation;

@property (readwrite, retain) IBOutlet UIImageView *profileView;
@property (readwrite, retain) IBOutlet UILabel *profileNameLabel;
@property (readwrite, retain) IBOutlet UILabel *profileNameSubLabel;

-(void)scrollToTop;

@end
