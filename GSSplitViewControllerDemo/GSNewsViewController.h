//
//  GSNewsViewController.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/18/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "GSAppDelegate.h"
#import "GSNewsArticleViewController.h"
#import "GSNewsTableViewCell.h"
#import "UIColor+MLPFlatColors.h"
#import "MBProgressHUD.h"
#import "fileUploadEngine.h"
#import "GSApiResponseObjectItem.h"


@interface GSNewsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    NSArray *dataArray;
    GSApiResponseObjectItem *jsonData;
}

@property (strong, nonatomic) fileUploadEngine *flUploadEngine;
@property (strong, nonatomic) MKNetworkOperation *flOperation;

@property (readwrite, retain) IBOutlet UITableView *tableView;
@property (readwrite, retain) UIRefreshControl *refreshControl;

@end
