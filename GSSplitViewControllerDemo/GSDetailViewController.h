//
//  GSDetailViewController.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 2015-08-10.
//  Copyright (c) 2014 Mindzone Company Limited. All rights reserved.
//

#import "GSMediaPlayerView.h"
#import <UIKit/UIKit.h>
#import "GSSplitViewController.h"
#import "DZNSegmentedControl.h"
#import "UIScrollView+DZNSegmentedControl.h"
#import "Constants.h"

#import "GSLiveTvCollectionView.h"
#import "GSOnDemandCollectionView.h"
#import "GSOnDemandEducationCollectionView.h"
#import "GSLiveTvScheduleCollectionView.h"
#import "GSCommentsCollectionView.h"
#import "CoreMotion/CoreMotion.h"
#import "GSApiResponseObjectItem.h"
#import "fileUploadEngine.h"
#import "GSFilterView.h"
#import <ConnectSDK/ConnectSDK.h>
#import "UIAlertView+Blocks.h"
#import "SIAlertView.h"
#import "IAPManager.h"
#import "GSSharedData.h"

@interface GSDetailViewController : UIViewController <UISearchBarDelegate,GSCommentsCollectionViewDelegate,GSSplitViewControllerDelegate,DZNSegmentedControlDelegate, GSLiveTvCollectionViewDelegate, GSMediaPlayerViewDelegate, UIActionSheetDelegate, GSOnDemandCollectionViewDelegate,GSOnDemandEducationCollectionViewDelegate,ConnectableDeviceDelegate, DiscoveryManagerDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, DevicePickerDelegate, MediaControl>
{
    UIInterfaceOrientation orientationLast, orientationAfterProcess;
    CMMotionManager *motionManager;
    GSApiResponseObjectItem *jsonDataImageAd;
    int category_id;
    NSString *searchText;
    
    int channel_id;
    int video_id;
    
    
    // casting
    DiscoveryManager *_discoveryManager;
    DevicePicker *_devicePicker;
    ConnectableDevice *_device;
    
    UIBarButtonItem *_connectToggleItem;
    UILabel *_disabledMessage;
    
    BOOL showSplashMessage;
}


@property (strong, nonatomic) fileUploadEngine *flUploadEngine;
@property (strong, nonatomic) MKNetworkOperation *flOperation;

@property (nonatomic, strong) UISearchBar *searchBarWithDelegate;

@property (nonatomic, strong) GSFilterView *filterView;

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) UILabel *detailDescriptionLabel;

@property (readwrite) int segment;
@property (nonatomic, weak) IBOutlet DZNSegmentedControl *segmentedControl;

@property (nonatomic, weak) IBOutlet UIView *mediaPlayerView;
@property (nonatomic, retain) GSMediaPlayerView *mediaPlayer;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ratioConstraint;


@property (nonatomic, weak) IBOutlet UIView *viewComments;
@property (nonatomic, weak) IBOutlet UIView *viewSchedule;
@property (nonatomic, weak) IBOutlet UIView *viewLiveTv;
@property (nonatomic, weak) IBOutlet UIView *viewOnDemand;
@property (nonatomic, weak) IBOutlet UIView *viewOnDemandEducation;

@property (nonatomic, weak) IBOutlet UIView *collectionViewForSubviews;

@property (nonatomic, weak) IBOutlet GSCommentsCollectionView *commentsCollectionView;
@property (nonatomic, weak) IBOutlet GSLiveTvScheduleCollectionView *liveTvScheduleCollectionView;
@property (nonatomic, weak) IBOutlet GSLiveTvCollectionView *liveTvCollectionView;
@property (nonatomic, weak) IBOutlet GSOnDemandCollectionView *viewICTube;
@property (nonatomic, weak) IBOutlet GSOnDemandEducationCollectionView *viewICEducation;


@property (nonatomic, retain) IBOutlet UILabel *lblUpNext;
@property (nonatomic, retain) IBOutlet UIButton *btnSchedule;
@property (nonatomic, retain) IBOutlet UIButton *btnCommentsAndList;
@property (nonatomic, retain) IBOutlet AsyncImageView *imageViewAdvertisement1;
@property (nonatomic, retain) IBOutlet UIButton *imageViewAdvertisementButton1;
@property (nonatomic, retain) IBOutlet AsyncImageView *imageViewAdvertisement2;
@property (nonatomic, retain) IBOutlet UIButton *imageViewAdvertisementButton2;
@property (nonatomic, retain) IBOutlet AsyncImageView *imageViewAdvertisement3;
@property (nonatomic, retain) IBOutlet UIButton *imageViewAdvertisementButton3;


-(IBAction)btnAdPressed:(id)sender;

-(IBAction)btnCommentsAndListPressed:(id)sender;
-(IBAction)btnSchedulePressed:(id)sender;

- (void)didChangeSegmentWithButton:(unsigned long)s;
- (IBAction)didChangeSegment:(id)sender;
- (void)setSegmentIndex:(int)i;
- (void)setSegmentWithIndex:(int)i andCategory:(int)category_id;
-(void)liveStreamByID:(int)channel_id;




// CASTING!
/*
@property GCKMediaControlChannel *mediaControlChannel;
@property GCKApplicationMetadata *applicationMetadata;
@property GCKDevice *selectedDevice;
@property(nonatomic, strong) UIBarButtonItem *googleCastButton;
@property(nonatomic, strong) GCKDeviceScanner *deviceScanner;
@property(nonatomic, strong) GCKDeviceManager *deviceManager;
@property(nonatomic, strong) GCKMediaInformation *mediaInformation;
@property(nonatomic, strong) UIImage *btnImage;
@property(nonatomic, strong) UIImage *btnImageSelected;
*/

@end
