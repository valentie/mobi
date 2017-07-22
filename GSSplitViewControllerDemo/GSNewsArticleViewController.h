//
//  GSNewsArticleViewController.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/19/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSAppDelegate.h"
#import "GSApiResponseObjectItem.h"
#import "AsyncImageView.h"

@interface GSNewsArticleViewController : UIViewController


@property (retain, nonatomic) GSApiResponseObjectItem *jsonData;


@property (retain, nonatomic) IBOutlet AsyncImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *lblHeader;
@property (retain, nonatomic) IBOutlet UITextView *txtContent;

@end
