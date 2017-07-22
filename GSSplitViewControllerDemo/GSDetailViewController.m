//
//  GSDetailViewController.m
//  GSSplitViewControllerDemo
//
//  Created by Christian Gossain on 2014-05-10.
//  Copyright (c) 2014 Christian Gossain. All rights reserved.
//

#import "GSDetailViewController.h"
#import "Constants.h"
#import "GSAppDelegate.h"
#import "URLConnection.h"
#import "GSVideoUploadViewController.h"
#import "GSSharedData.h"
#import <ConnectSDK/AirPlayService.h>
#import <ConnectSDK/DIALService.h>
#import <ConnectSDK/WebOSTVService.h>
#import <ConnectSDK/CastService.h>
#import <ConnectSDK/DLNAService.h>

#import <ConnectSDK/CastDiscoveryProvider.h>
#import <ConnectSDK/SSDPDiscoveryProvider.h>


static NSString * kReceiverAppID;

@interface GSDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation GSDetailViewController

@synthesize segment, viewICTube,viewICEducation, liveTvCollectionView,liveTvScheduleCollectionView, commentsCollectionView;



-(void)onDemandPressed:(NSDictionary *)object
{
    if (_device)
    {
        [self playVideoOnRemoteDevice:object];
        return;
    }
    
    [self.mediaPlayer playOnDemandVideo:object];
    [self.btnSchedule setHidden:YES];
    [self.btnCommentsAndList setHidden:NO];
    [self.btnCommentsAndList setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
    
    int vid = [[object valueForKey:@"video_id"] intValue];
    
    channel_id = 0;
    video_id = vid;
}


-(void)liveStreamPressed:(NSDictionary *)object
{
    
    if (_device)
    {
        [self playStreamVideoOnRemoteDevice:object];
        return;
    }
    
    [self.mediaPlayer playLiveTv:object];
    channel_id  = 0;
    video_id    = 0;
    
    int cid = [[object valueForKey:@"id"] intValue];
    channel_id = cid;
    
    if (cid == 1 || cid == 2)
    {
        [self.btnSchedule setHidden:YES];
        [self.btnCommentsAndList setHidden:NO];
        [self.btnCommentsAndList setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
        // schow schedule
        [self.viewSchedule setHidden:NO];
        
        
        [self.liveTvScheduleCollectionView loadScheduleForChannel:cid];
        self.lblUpNext.text = NSLocalizedString(@"Schedule", @"Schedule");
    } else {
        [self.btnSchedule setHidden:YES];
        [self.btnCommentsAndList setHidden:NO];
        [self.btnCommentsAndList setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
    }
        
}

-(void)liveStreamByID:(int)cid
{
    [self.liveTvCollectionView launchChannelByID:cid];
}

-(void)setButtonsForCurrentItemWithTitle:(NSString *)title hasCommentButtonHidden:(BOOL)comment hasScheduleButtonHidden:(BOOL)schedule
{
    if (self.viewComments.hidden == YES && self.viewSchedule.hidden == YES)
    {
        self.lblUpNext.text = title;
        [self.btnCommentsAndList setHidden:comment];
        [self.btnSchedule setHidden:schedule];
    }
}



-(IBAction)btnCommentsAndListPressed:(id)sender
{
    [self.view endEditing:YES];
    [self.searchBarWithDelegate resignFirstResponder];

    if (self.viewComments.hidden == NO || self.viewSchedule.hidden == NO)
    {

        
        // BACK TO LIST
        [self.btnCommentsAndList setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
        [self.viewComments setHidden:YES];
        [self.viewSchedule setHidden:YES];
        [self.btnSchedule setHidden:NO];
        
        if (self.segment == 0) [self.viewLiveTv setHidden:NO];
        if (self.segment == 1) [self.viewOnDemand setHidden:NO];
        
        //TODO: set correct
        if (self.viewLiveTv.hidden == NO)
        {
            self.lblUpNext.text = NSLocalizedString(@"List of channels", @"List of channels");
        } else {
            self.lblUpNext.text = @"iC Tube Videos";
        }
        
        if (self.segment == 0)
        {
            [self.btnSchedule setHidden:NO];
        } else {
            [self.btnSchedule setHidden:YES];
        }
        
    } else
    {

        
        [self.btnCommentsAndList setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
        [self.viewComments setHidden:NO];
        [self.viewSchedule setHidden:YES];
        [self.btnSchedule setHidden:YES];
        self.lblUpNext.text = NSLocalizedString(@"Comments", @"Comments");
        
        if (channel_id > 0)
        {
            NSLog(@"loadCommentsForChannel: %i",channel_id);
            [self.commentsCollectionView loadCommentsForChannel:channel_id];
        }
        if (video_id > 0)
        {
            if (self.segment == 1)
            {
                [self.commentsCollectionView loadCommentsForVideo:video_id andSection:@""];
            } else {
                [self.commentsCollectionView loadCommentsForVideo:video_id andSection:@"education"];
            }
            
        }
        
    }
    
    
   
    
}

-(IBAction)btnSchedulePressed:(id)sender
{
    [self.view endEditing:YES];
    [self.searchBarWithDelegate resignFirstResponder];
    
    [self.btnCommentsAndList setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [self.viewComments setHidden:YES];
    [self.viewSchedule setHidden:NO];
    [self.btnSchedule setHidden:YES];
    self.lblUpNext.text = @"Schedule";
    
    if (channel_id > 0)
    {
        [self.liveTvScheduleCollectionView loadScheduleForChannel:channel_id];
    }
    
}


-(void)setSegmentIndex:(int)i
{
    self.segment = i;
    category_id = 0;

    if (self.segment == 0) self.title = @"iC Live";
    if (self.segment == 1) self.title = @"iC TUBE";
    if (self.segment == 2) self.title = @"iC Education";
    
    [self.viewComments setHidden:YES];
    [self.viewSchedule setHidden:YES];
    [self.viewLiveTv setHidden:YES];
    [self.viewOnDemand setHidden:YES];
    [self.viewOnDemandEducation setHidden:YES];
    
    if (self.segment == 0) [self.viewLiveTv setHidden:NO];
    if (self.segment == 1) [self.viewOnDemand setHidden:NO];
    if (self.segment == 1) [self.viewICTube showWithCategory:category_id andSearch:@""];
    if (self.segment == 2) [self.viewOnDemandEducation setHidden:NO];
    if (self.segment == 2) [self.viewICEducation showWithCategory:category_id andSearch:@""];
    self.segmentedControl.selectedSegmentIndex = self.segment;

    //TODO: set correct
    if (self.segment == 0)
    {
        [self.btnSchedule setHidden:NO];
    } else {
        [self.btnSchedule setHidden:YES];
    }
    [self.view endEditing:YES];
    [self.searchBarWithDelegate resignFirstResponder];
    [self resignCommentsFromPosting];
}

- (void)setSegmentWithIndex:(int)i andCategory:(int)cat_id
{
    NSLog(@"setSegmentWithIndex %i andCategory %i", i, cat_id);
    
    self.segment = i;
    category_id = cat_id;

    if (self.segment == 0) self.title = @"iC Live";
    if (self.segment == 1) self.title = @"iC TUBE";
    if (self.segment == 1) self.title = @"iC Education";
    
    [self.viewComments setHidden:YES];
    [self.viewSchedule setHidden:YES];
    [self.viewLiveTv setHidden:YES];
    [self.viewOnDemand setHidden:YES];
    [self.viewOnDemandEducation setHidden:YES];
    
    if (self.segment == 0) [self.viewLiveTv setHidden:NO];
    if (self.segment == 1) [self.viewOnDemand setHidden:NO];
    if (self.segment == 1) [self.viewICTube showWithCategory:category_id andSearch:@""];
    if (self.segment == 2) [self.viewOnDemandEducation setHidden:NO];
    if (self.segment == 2) [self.viewICEducation showWithCategory:category_id andSearch:@""];
    self.segmentedControl.selectedSegmentIndex = self.segment;

    //TODO: set correct
    if (self.segment == 0)
    {
        [self.btnSchedule setHidden:NO];
    } else {
        [self.btnSchedule setHidden:YES];
    }
    [self.view endEditing:YES];
    [self.searchBarWithDelegate resignFirstResponder];
    [self resignCommentsFromPosting];
}






- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
 
        
        _detailDescriptionLabel = [[UILabel alloc] init];
        _detailDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_detailDescriptionLabel];
        [self.view setNeedsUpdateConstraints];
        
        self.lblUpNext.font = [UIFont systemFontOfSize:FONTSIZE16];
        
        [self.btnSchedule setHidden:YES];
        [self.btnCommentsAndList setHidden:YES];
        
        self.searchBarWithDelegate = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, -1.0, (self.view.frame.size.width-20), 46.0)];
        self.searchBarWithDelegate.delegate = self;
        self.searchBarWithDelegate.tag = 99;
        self.searchBarWithDelegate.barTintColor = [UIColor colorWithRed:11/255.0 green:167/255.0 blue:157/255.0 alpha:1.0];
        self.searchBarWithDelegate.tintColor = [UIColor colorWithRed:11/255.0 green:167/255.0 blue:157/255.0 alpha:1.0];
        self.searchBarWithDelegate.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        
        UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, (self.view.frame.size.width-20), 44.0)];
        searchBarView.clipsToBounds = YES;
        searchBarView.backgroundColor = [UIColor colorWithRed:11/255.0 green:167/255.0 blue:157/255.0 alpha:1.0];
        searchBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [searchBarView addSubview:self.searchBarWithDelegate];
        self.navigationItem.titleView = searchBarView;
        
        
        UIButton *navBarButtonOpenMenu = [UIButton buttonWithType:UIButtonTypeCustom];
        navBarButtonOpenMenu.bounds = CGRectMake( 0, 0, 24, 24);
        [navBarButtonOpenMenu setImage:[UIImage imageNamed:@"open-menu-burger"] forState:UIControlStateNormal];
        UIBarButtonItem *navBarButtonOpenMenuItem = [[UIBarButtonItem alloc] initWithCustomView:navBarButtonOpenMenu];
        self.navigationItem.leftBarButtonItem = navBarButtonOpenMenuItem;
        [navBarButtonOpenMenu addTarget:self action:@selector(sideMenuOpenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        // END ADD BUTTONS
        
        self.segmentedControl.items = @[@"\uf26c iC Live", @"\uf03d iC TUBE", @"\uf19d iC Education"];
        //self.segmentedControl.items = @[@"\uf26c iC Live", @"\uf03d iC TUBE"];
        self.segmentedControl.showsCount = NO;
        self.segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
        self.segmentedControl.tintColor = [UIColor colorWithRed:11/255.0 green:167/255.0 blue:157/255.0 alpha:1.0];
        self.segmentedControl.delegate = self;
        
        self.title = @"iC Live";
        [self.viewComments setHidden:YES];
        [self.viewSchedule setHidden:YES];
        [self.viewOnDemand setHidden:YES];
        [self.viewOnDemandEducation setHidden:YES];
        [self.viewLiveTv setHidden:NO];
        
        self.viewComments.clipsToBounds = YES;
        self.viewSchedule.clipsToBounds = YES;
        self.viewOnDemand.clipsToBounds = YES;
        self.viewOnDemandEducation.clipsToBounds = YES;
        self.viewLiveTv.clipsToBounds = YES;
        
        
        // delegate for touch
        liveTvCollectionView.delegate = self;
        viewICTube.delegate = self;
        viewICEducation.delegate = self;
        commentsCollectionView.delegate = self;
        
        // start loading ads
        [self loadImageAd:nil];
        [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(loadImageAd:) userInfo:nil repeats:YES];
        
        if (self.mediaPlayer == nil)
        {
            // add the player
            self.mediaPlayer = [[[NSBundle mainBundle] loadNibNamed:@"GSMediaPlayerView" owner:self options:nil] lastObject];
            self.mediaPlayer.frame  =CGRectMake(0,0,self.mediaPlayerView.frame.size.width,self.mediaPlayerView.frame.size.height);
            self.mediaPlayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.mediaPlayerView addSubview:self.mediaPlayer];
            self.mediaPlayer.delegate = self;
           
        }
        
        // for iphone
        [self initializeMotionManager];

        // casting
        _discoveryManager = [DiscoveryManager sharedManager];
        [_discoveryManager stopDiscovery];
        [DiscoveryManager sharedManager].pairingLevel = DeviceServicePairingLevelOn;
        [[DiscoveryManager sharedManager] registerDefaultServices];
        //DIALService
        [_discoveryManager startDiscovery];
        
        

        
        
        UIImage *image = [[UIImage imageNamed:@"cast_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _connectToggleItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(hConnect:)];
        UIButton *navBarButtonSettings = [UIButton buttonWithType:UIButtonTypeCustom];
        navBarButtonSettings.bounds = CGRectMake( 0, 0, 24, 24);
        [navBarButtonSettings setImage:[UIImage imageNamed:@"settings-burger"] forState:UIControlStateNormal];
        UIBarButtonItem *navBarButtonSettingsItem = [[UIBarButtonItem alloc] initWithCustomView:navBarButtonSettings];
        [navBarButtonSettings addTarget:self action:@selector(btnFilterPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:navBarButtonSettingsItem, _connectToggleItem,nil];
        
        
        
    }
    return self;
    
}




-(void)dealloc
{
    NSLog(@"DEALLOC!!!!!!!!!");
}

-(void)loadImageAd:(id)sender
{
    NSLog(@"load image ad");
    
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *device_uuid = [appDelegate deviceID];
    
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@image_ad",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"device_uuid=%@",device_uuid];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response)
     {
         jsonDataImageAd = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         if (jsonDataImageAd.statusCode > 0)
         {
             // could not load ad
             self.imageViewAdvertisement1.image = [UIImage imageNamed:@"logo"];
             self.imageViewAdvertisement2.image = [UIImage imageNamed:@"logo"];
             self.imageViewAdvertisement3.image = [UIImage imageNamed:@"logo"];
         } else {
             // ---------------------------
             // no error - show image
             self.imageViewAdvertisement1.image = [UIImage imageNamed:@"logo"];
             self.imageViewAdvertisement2.image = [UIImage imageNamed:@"logo"];
             self.imageViewAdvertisement3.image = [UIImage imageNamed:@"logo"];
             int ad_image_id = [[jsonDataImageAd.responseData valueForKey:@"ad_image_id"] intValue];
             if (ad_image_id > 0)
             {
                 if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                 {
                     self.imageViewAdvertisement1.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ads/image/%i_xl.png",API_IMAGE_HOST,ad_image_id]];
                     self.imageViewAdvertisement2.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ads/image/%i_xl.png",API_IMAGE_HOST,ad_image_id]];
                     self.imageViewAdvertisement3.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ads/image/%i_xl.png",API_IMAGE_HOST,ad_image_id]];
                 } else {
                     self.imageViewAdvertisement1.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ads/image/%i.png",API_IMAGE_HOST,ad_image_id]];
                     self.imageViewAdvertisement2.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ads/image/%i.png",API_IMAGE_HOST,ad_image_id]];
                     self.imageViewAdvertisement3.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ads/image/%i.png",API_IMAGE_HOST,ad_image_id]];
                 }
                 
             } else {
                 self.imageViewAdvertisement1.image = [UIImage imageNamed:@"logo"];
                 self.imageViewAdvertisement2.image = [UIImage imageNamed:@"logo"];
                 self.imageViewAdvertisement3.image = [UIImage imageNamed:@"logo"];
             }
             // ---------------------------
         }
         
     } errorBlock:^(NSError *error) {
         // when error occurs
     } uploadProgressBlock:^(float progress) {
         // when upload progresses
         
     } downloadProgressBlock:^(float progress) {
         // when download progressses
         
     }];

    

    
}

-(void)btnAdPressed:(id)sender;
{
    int ad_image_id = [[jsonDataImageAd.responseData valueForKey:@"ad_image_id"] intValue];
    if (ad_image_id > 0)
    {
        NSString *ad_link = [jsonDataImageAd.responseData valueForKey:@"ad_link"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ad_link]];
    }
}


- (void)initializeMotionManager
{
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = .2;
    motionManager.gyroUpdateInterval = .2;
    
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                        withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                            if (!error) {
                                                [self outputAccelertionData:accelerometerData.acceleration];
                                            }
                                            else{
                                                NSLog(@"%@", error);
                                            }
                                        }];
}


-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"destroy motion manager");
    
    [self.mediaPlayer.player stop];
    [self.mediaPlayer cleanup];
    self.mediaPlayer = nil;
    
    self.segmentedControl = nil;
    self.liveTvCollectionView = nil;
    self.viewICTube = nil;
    self.viewICEducation = nil;
    
    [self destroyMotionManager];
    [super viewDidDisappear:animated];
}

- (void)destroyMotionManager{
    [motionManager stopDeviceMotionUpdates];
    motionManager = nil;
}


-(void)didForceFullScreenToggle
{
    [self screenRotation];
}

-(void)screenRotation
{

    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        
        GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        
        if (orientationLast == UIInterfaceOrientationLandscapeLeft)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [appDelegate createPlayerView];
            [self.mediaPlayer removeFromSuperview];
            [appDelegate.playerView addSubview:self.mediaPlayer];
            self.mediaPlayer.transform = CGAffineTransformMakeRotation(-M_PI/2);
            self.mediaPlayer.frame = CGRectMake(0,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
            [self.mediaPlayer updateButtonsAfterRotation];
            
        }
        if (orientationLast == UIInterfaceOrientationLandscapeRight)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [appDelegate createPlayerView];
            [self.mediaPlayer removeFromSuperview];
            [appDelegate.playerView addSubview:self.mediaPlayer];
            self.mediaPlayer.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.mediaPlayer.frame = CGRectMake(0,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
            [self.mediaPlayer updateButtonsAfterRotation];
        }
        if (orientationLast == UIInterfaceOrientationPortrait || orientationLast == UIInterfaceOrientationPortraitUpsideDown)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [appDelegate removePlayerView];
            [self.mediaPlayer removeFromSuperview];
            [self.mediaPlayerView addSubview:self.mediaPlayer];
            self.mediaPlayer.transform = CGAffineTransformMakeRotation(0);
            self.mediaPlayer.frame = CGRectMake(0, 0, self.mediaPlayerView.frame.size.width, self.mediaPlayerView.frame.size.height);
            [self.mediaPlayer updateButtonsAfterRotation];
        }
        
    } else {
        
        [liveTvCollectionView didRotate:orientationLast];
        [liveTvScheduleCollectionView didRotate:orientationLast];
        [commentsCollectionView didRotate:orientationLast];
        [viewICTube didRotate:orientationLast];
        [viewICEducation didRotate:orientationLast];
        
        // DETECT IF FULL SCREEN IS WANTED
        GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
        if (self.mediaPlayer.forceFullScreen == YES)
        {
            NSLog(@"FULLSCREEN");
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [appDelegate createPlayerView];
            [self.mediaPlayer removeFromSuperview];
            [appDelegate.playerView addSubview:self.mediaPlayer];
            self.mediaPlayer.frame = CGRectMake(0,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
            [self.mediaPlayer updateButtonsAfterRotation];
        } else {
            NSLog(@"NO FULLSCREEN");
            
            [appDelegate removePlayerView];
            [self.mediaPlayer removeFromSuperview];
            [self.mediaPlayerView addSubview:self.mediaPlayer];
            self.mediaPlayer.frame = CGRectMake(0, 0, self.mediaPlayerView.frame.size.width, self.mediaPlayerView.frame.size.height);
            [self.mediaPlayer updateButtonsAfterRotation];
        }
        
        
    }
}

- (void)outputAccelertionData:(CMAcceleration)acceleration
{
    UIInterfaceOrientation orientationNew;
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIInterfaceOrientationPortraitUpsideDown;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == orientationLast)
        return;
    
    orientationLast = orientationNew;
    [self screenRotation];
}


-(void)sideMenuOpenButtonPressed:(id)sender
{
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.splitViewController setMasterPaneShown:YES animated:YES];
}



#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil)
    {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.detailItem)
    {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(GSSplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem
{

}

- (void)splitViewController:(GSSplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}




/*
 Change by tab with button
 */
-(void)changeSegmentWithButtonDisabled:(unsigned long)segment
{
    
    
    
    [UIAlertView showWithTitle:NSLocalizedString(@"Confirm Purchase", @"Confirm Purchase")
                       message:[NSString stringWithFormat:NSLocalizedString(@"Would you like to purchase 30 days access to the education section?",@"Would you like to purchase 30 days access to the education section?")]
             cancelButtonTitle:NSLocalizedString(@"NO", @"NO")
             otherButtonTitles:@[NSLocalizedString(@"YES", @"YES")]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              
                              NSLog(@"Cancelled");
                              
                          } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"YES", @"YES")]) {
                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                              
                              
                              [[IAPManager sharedIAPManager] purchaseProductForId:@"60CREDITS" completion:^(SKPaymentTransaction *transaction) {
                                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                  if (transaction.transactionState == SKPaymentTransactionStatePurchased)
                                  {
                                      
                                      [[GSSharedData sharedManager] submitVideoPurchased:video_id andTransactionIdentifier:transaction.transactionIdentifier];
                                      
                                      
                                  } else {
                                      
                                      [self alertStatus:[NSString stringWithFormat:@"Failed with status code: %li",(long)transaction.transactionState] :@"Failed" :0];
                                      
                                  }
                                  
                                  
                                  
                              } error:^(NSError *err) {
                                  
                                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                  [self alertStatus:err.localizedDescription :@"Failed" :0];
                                  
                              }];
                              
                              
                              
                              
                          }
                      }];
}







-(void)didChangeSegmentWithButton:(unsigned long)s
{
    NSLog(@"didChangeSegmentWithButton: %lu", s);
    
    if (segment == s) return;
    segment = s;
    
    if (segment == 0) self.title = @"iC Live";
    if (segment == 1) self.title = @"IC TUBE";
    if (segment == 2) self.title = @"IC Education";
    
    if (segment == 0) [self.mediaPlayer setCurrentSection:@""];
    if (segment == 1) [self.mediaPlayer setCurrentSection:@""];
    if (segment == 2) [self.mediaPlayer setCurrentSection:@"education"];
    
    [self.viewComments setHidden:YES];
    [self.viewSchedule setHidden:YES];
    [self.viewLiveTv setHidden:YES];
    [self.viewOnDemand setHidden:YES];
    [self.viewOnDemandEducation setHidden:YES];
    
    if (self.segment == 0) [self.viewLiveTv setHidden:NO];
    if (self.segment == 1) {
        [self.viewOnDemand setHidden:NO];
        [self.viewICTube showWithCategory:category_id andSearch:@""];
    }
    if (self.segment == 2) {
        [self.viewOnDemandEducation setHidden:NO];
        [self.viewICEducation showWithCategory:category_id andSearch:@""];
    }
    
    [self.segmentedControl setSelectedSegmentIndex:s];
    
    [self.btnSchedule setHidden:YES];
    [self.view endEditing:YES];
    [self.searchBarWithDelegate resignFirstResponder];
}

- (IBAction)didChangeSegment:(id)sender
{
    if ([self.mediaPlayer.player isPreparedToPlay]) [self.mediaPlayer.player stop];
    self.btnCommentsAndList.hidden = YES;
    self.btnSchedule.hidden = YES;
    [self.view endEditing:YES];
    [self.searchBarWithDelegate resignFirstResponder];
}




-(void)btnFilterPressed:(id)sender
{
    [self.view endEditing:YES];
    [self.searchBarWithDelegate resignFirstResponder];
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
            UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"Clear Search",
                                nil];
            popup.tag = 1;
            [popup showInView:self.view];

    } else if (self.segmentedControl.selectedSegmentIndex == 2)
    {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"Clear Search",
                                @"เรียงลำดับ",
                                nil];
        popup.tag = 4;
        [popup showInView:self.view];
        
    } else {
        
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"Clear Search",
                                @"อัปโหลดวิดีโอ",
                                @"เรียงลำดับ",
                                //@"Options",
                                nil];
        popup.tag = 2;
        [popup showInView:self.view];
        
    }
}

-(void)showSortSheet
{
    // do something
    UIActionSheet *popupSheet = [[UIActionSheet alloc] initWithTitle:@"Select option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                  @"ความเกี่ยวข้อง",
                  @"รายการมาใหม่",
                  @"รายการยอดนิยม",
                  @"รายการฮิตติดอันดับ",
                  nil];
    
    
    popupSheet.tag = 3;
    [popupSheet showInView:self.view];
}
-(void)showSortSheetEducation
{
    // do something
    UIActionSheet *popupSheet = [[UIActionSheet alloc] initWithTitle:@"Select option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                 @"ความเกี่ยวข้อง",
                                 @"รายการมาใหม่",
                                 @"รายการยอดนิยม",
                                 @"รายการฮิตติดอันดับ",
                                 nil];
    
    popupSheet.tag = 5;
    [popupSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    // do something
                    channel_id = 0;
                    video_id = 0;
                    [self.liveTvCollectionView showWithText:@""];
                    break;
                case 1:
                    // do something
                    
                    break;
                default:
                    break;
            }
            break;
        }
        case 2: {
            switch (buttonIndex) {
                case 0:
                    // do something
                    channel_id = 0;
                    video_id = 0;
                    self.viewICTube.category_id = 0;
                    [self.viewICTube showWithText:@""];
                    self.viewICEducation.category_id = 0;
                    [self.viewICEducation showWithText:@""];
                    break;
                case 1:
                    // do something
                    [self showVideoUploadController];
                    break;
                case 2:
                    [self performSelector:@selector(showSortSheet) withObject:nil afterDelay:0.2];

                    break;
                case 12:
                    // do something
                    if (self.filterView == nil)
                    {
                        self.filterView = [[GSFilterView alloc] initWithFrame:CGRectMake(20,20,280,280)];
                        self.filterView.backgroundColor = [UIColor redColor];
                        [self.view addSubview:self.filterView];
                        
                    }
                    [self.view bringSubviewToFront:self.filterView];
                    self.filterView.center = self.view.center;
                    self.filterView.hidden = NO;
                    
                    break;
                    
                default:
                    break;
            }
            break;
        }
            
        case 4: {
            switch (buttonIndex) {
                case 0:
                    // do something
                    channel_id = 0;
                    video_id = 0;
                    self.viewICTube.category_id = 0;
                    [self.viewICTube showWithText:@""];
                    self.viewICEducation.category_id = 0;
                    [self.viewICEducation showWithText:@""];
                    break;
                case 1:
                    [self performSelector:@selector(showSortSheetEducation) withObject:nil afterDelay:0.2];
                    
                    break;
                case 12:
                    // do something
                    if (self.filterView == nil)
                    {
                        self.filterView = [[GSFilterView alloc] initWithFrame:CGRectMake(20,20,280,280)];
                        self.filterView.backgroundColor = [UIColor redColor];
                        [self.view addSubview:self.filterView];
                        
                    }
                    [self.view bringSubviewToFront:self.filterView];
                    self.filterView.center = self.view.center;
                    self.filterView.hidden = NO;
                    
                    break;
                    
                default:
                    break;
            }
            break;
        }
        case 3: {
            switch (buttonIndex) {
                case 0:
                    // video_order
                    self.viewICTube.sortBy = @"video_order";
                    [self.viewICTube showWithSort];
                    break;
                case 1:
                    // video_created
                    self.viewICTube.sortBy = @"video_created";
                    [self.viewICTube showWithSort];
                    break;
                case 2:
                    // video_views
                    self.viewICTube.sortBy = @"video_views";
                    [self.viewICTube showWithSort];
                    break;
                case 3:
                    // video_likes
                    self.viewICTube.sortBy = @"video_likes";
                    [self.viewICTube showWithSort];
                    break;
                default:
                    break;
            }
            break;
        }
        case 5: {
            switch (buttonIndex) {
                case 0:
                    // video_order
                    self.viewICEducation.sortBy = @"video_order";
                    [self.viewICEducation showWithSort];
                    break;
                case 1:
                    // video_created
                    self.viewICEducation.sortBy = @"video_created";
                    [self.viewICEducation showWithSort];
                    break;
                case 2:
                    // video_views
                    self.viewICEducation.sortBy = @"video_views";
                    [self.viewICEducation showWithSort];
                    break;
                case 3:
                    // video_likes
                    self.viewICEducation.sortBy = @"video_likes";
                    [self.viewICEducation showWithSort];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

-(void)showVideoUploadController
{
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"logged_in"]) {
        // not logged in!
        [self alertStatus:NSLocalizedString(@"You must be logged in to upload videos." , @"You must be logged in to upload videos." ):NSLocalizedString(@"Log in" , @"Log in" ):0 ];
    } else {
        GSVideoUploadViewController *addVideoController = [[GSVideoUploadViewController alloc] initWithNibName:@"GSVideoUploadViewController" bundle:nil];
        [self presentViewController:addVideoController animated:YES completion:nil];
    }
}





-(void)btnMenuOpenPressed:(id)sender
{
    NSLog(@"%s",__FUNCTION__);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



-(void)setUpNextTitleText:(NSString*)text
{
    self.lblUpNext.text = text;
}

#pragma mark - Constraints

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSLayoutConstraint *centerLabelX = [NSLayoutConstraint constraintWithItem:self.detailDescriptionLabel
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0f
                                                                     constant:0.0f];
    
    [self.view addConstraint:centerLabelX];
    
    NSLayoutConstraint *centerLabelY = [NSLayoutConstraint constraintWithItem:self.detailDescriptionLabel
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0f
                                                                     constant:0.0f];
    
    [self.view addConstraint:centerLabelY];
    
}

// sets change in category
-(void)collectionCellDidPressCategory:(int)cat_id
{
    [self setSegmentWithIndex:1 andCategory:cat_id];
}

// sets change in category
-(void)collectionCellDidPressCategoryForEducation:(int)cat_id
{
    [self setSegmentWithIndex:2 andCategory:cat_id];
}

-(void)prepareCommentForPosting
{
    
    if (IS_IPHONE_4_OR_LESS)
    {
        self.ratioConstraint.constant = 1000;
    } else if (IS_IPHONE_5)
    {
        self.ratioConstraint.constant = 60;
    } else {
        self.ratioConstraint.constant = 0;
    }
    self.ratioConstraint.constant = 1000;
    [self.mediaPlayerView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.0 animations:^{
        
        [self.mediaPlayerView layoutIfNeeded];
        
    } completion:^(BOOL isFinished){
        
    }];
    
}

-(void)resignCommentsFromPosting
{
    [self.view endEditing:YES];
    [self.searchBarWithDelegate resignFirstResponder];
 
    self.ratioConstraint.constant = 0;
    [self.mediaPlayerView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.0 animations:^{
        
        [self.mediaPlayerView layoutIfNeeded];
        
    } completion:^(BOOL isFinished){
        
    }];
     
}

#pragma UISearhBar Delegates

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"TOUCH");
    [self.view endEditing:YES];
    [self.searchBarWithDelegate resignFirstResponder];
}

-(void)handleTap
{
    NSLog(@"TAPPPPPP");
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
     NSLog(@"searchBarTextDidBeginEditing");
 
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Cancel");
    [self.view endEditing:YES];
    [self.searchBarWithDelegate resignFirstResponder];
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"do search: %@ for index %li", searchBar.text, self.segmentedControl.selectedSegmentIndex);
    
    if (self.segmentedControl.selectedSegmentIndex == 1)
    {
        [self.viewICTube showWithText:searchBar.text];
    } else if (self.segmentedControl.selectedSegmentIndex == 2)
    {
        [self.viewICEducation showWithText:searchBar.text];
    } else {
        [self.liveTvCollectionView showWithText:searchBar.text];
    }
    [self.searchBarWithDelegate resignFirstResponder];
    [self.view endEditing:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidEndEditing");
}

-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarResultsListButtonClicked");
}




#pragma mark - UITabBarDelegate methods

-(void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{

}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{

}

#pragma mark - Actions

- (void) hConnect:(id)sender
{
    if (_device)
        [_device disconnect];
    else
        [self findDevice:sender];
}

#pragma mark - Device Discovery

-(void)findDevice:(id)sender
{
    [_discoveryManager startDiscovery];
    
    if (_devicePicker == nil)
    {
        _devicePicker = [_discoveryManager devicePicker];
        _devicePicker.delegate = self;
    }
    
    _devicePicker.currentDevice = _device;
    _devicePicker.shouldAutoRotate = YES;
    
    if (IS_IPAD)
    {
        
        [_devicePicker showPicker:sender];
    } else {
        
        [_devicePicker showPicker:sender];
    }
    
    
    
}

#pragma mark - DevicePickerDelegate methods

- (void)devicePicker:(DevicePicker *)picker didSelectDevice:(ConnectableDevice *)device
{
    NSLog(@"didSelectDevice");
    _device = device;
    _device.delegate = self;
    
    [_device setPairingType:DeviceServicePairingTypeFirstScreen];
    [_device connect];
    

    // TODO: this should be unnecessary
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       UIImage *image = [[UIImage imageNamed:@"cast_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                       _connectToggleItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(hConnect:)];
                       UIButton *navBarButtonSettings = [UIButton buttonWithType:UIButtonTypeCustom];
                       navBarButtonSettings.bounds = CGRectMake( 0, 0, 24, 24);
                       [navBarButtonSettings setImage:[UIImage imageNamed:@"settings-burger"] forState:UIControlStateNormal];
                       UIBarButtonItem *navBarButtonSettingsItem = [[UIBarButtonItem alloc] initWithCustomView:navBarButtonSettings];
                       [navBarButtonSettings addTarget:self action:@selector(btnFilterPressed:) forControlEvents:UIControlEventTouchUpInside];
                       self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:navBarButtonSettingsItem, _connectToggleItem,nil];
                   });
}

#pragma mark - ConnectableDeviceDelegate

- (void) connectableDeviceReady:(ConnectableDevice *)device
{
    NSLog(@"connectableDeviceReady");
}

- (void) connectableDevice:(ConnectableDevice *)device service:(DeviceService *)service pairingRequiredOfType:(int)pairingType withData:(id)pairingData
{
    if (pairingType == DeviceServicePairingTypeAirPlayMirroring)
        [(UIAlertView *) pairingData show];
}

- (void) connectableDeviceDisconnected:(ConnectableDevice *)device withError:(NSError *)error
{
    _device.delegate = nil;
    _device = nil;
    
    if (error)
        NSLog(@"====> connectableDeviceDisconnected %@", error.localizedDescription);
    else
        NSLog(@"====> connectableDeviceDisconnected");
    
    
    UIImage *image = [[UIImage imageNamed:@"cast_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _connectToggleItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(hConnect:)];
    UIButton *navBarButtonSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    navBarButtonSettings.bounds = CGRectMake( 0, 0, 24, 24);
    [navBarButtonSettings setImage:[UIImage imageNamed:@"settings-burger"] forState:UIControlStateNormal];
    UIBarButtonItem *navBarButtonSettingsItem = [[UIBarButtonItem alloc] initWithCustomView:navBarButtonSettings];
    [navBarButtonSettings addTarget:self action:@selector(btnFilterPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:navBarButtonSettingsItem, _connectToggleItem,nil];
}

-(void)discoveryManager:(DiscoveryManager *)manager didFindDevice:(ConnectableDevice *)device
{
     NSLog(@"====> didFindDevice");
}
-(void)discoveryManager:(DiscoveryManager *)manager didUpdateDevice:(ConnectableDevice *)device
{
    
}

-(void)discoveryManager:(DiscoveryManager *)manager didLoseDevice:(ConnectableDevice *)device
{
    
}
-(void)discoveryManager:(DiscoveryManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"====> didFailWithError");
}


-(void)rewindWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    
}
-(void)pauseWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    
}
-(void)stopWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    
}
-(void)fastForwardWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    
}
-(void)playWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    
}




-(void)playVideoOnRemoteDevice:(NSDictionary *)object
{
    NSString *url = [object valueForKey:@"video_url"];

    NSString *title = [object valueForKey:@"title"];
    NSString *description = [object valueForKey:@"description"];

    NSURL *mediaURL = [NSURL URLWithString:url];
    NSURL *iconURL  = [NSURL URLWithString:@"http://www.mobitelevision.tv/assets/backend/images/logo.png"];
 
    
    NSString *mimeType = @"video/mp4";
    if ([[url pathExtension] isEqualToString:@"m3u8"])
    {
        mimeType = @"video/hls";
    }
    
    
    
    MediaInfo *mediaInfo = [[MediaInfo alloc] initWithURL:mediaURL mimeType:mimeType];
    mediaInfo.title = title;
    mediaInfo.description = description;
    ImageInfo *imageInfo = [[ImageInfo alloc] initWithURL:iconURL type:ImageTypeThumb];
    [mediaInfo addImage:imageInfo];
    
    __block MediaLaunchObject *launchObject;
    
    
    [_device.mediaPlayer playMediaWithMediaInfo:mediaInfo
                                     shouldLoop:NO
                                        success:
     ^(MediaLaunchObject *mediaLaunchObject) {
         NSLog(@"play video success");
         
         // save the object reference to control media playback
         launchObject = mediaLaunchObject;
         
         // enable your media control UI elements here
     }
                                        failure:
     ^(NSError *error) {
         NSLog(@"play video failure: %@", error.localizedDescription);
         NSLog(@"play video failure: %@", error);
         
         [[GSSharedData sharedManager] submitError:error.localizedDescription];
         
         [self alertStatus:@"This stream could not be cast to the device due to network issues." :@"Failed" :0 ];
     }];
}


-(void)playStreamVideoOnRemoteDevice:(NSDictionary *)object
{
    
    NSString *url = [object valueForKey:@"url"];
    NSString *title = [object valueForKey:@"title"];
    
    NSURL *mediaURL = [NSURL URLWithString:url];
    NSURL *iconURL = [NSURL URLWithString:@"http://www.mobitelevision.tv/assets/backend/images/logo.png"];   // credit: sintel-durian.deviantart.com
    NSString *mimeType = @"video/hls"; // audio/* for audio files
    
    MediaInfo *mediaInfo = [[MediaInfo alloc] initWithURL:mediaURL mimeType:mimeType];
    mediaInfo.title = title;
    mediaInfo.description = @"";
    ImageInfo *imageInfo = [[ImageInfo alloc] initWithURL:iconURL type:ImageTypeThumb];
    [mediaInfo addImage:imageInfo];
    
    __block MediaLaunchObject *launchObject;
    
    
    [_device.mediaPlayer playMediaWithMediaInfo:mediaInfo
                                         shouldLoop:NO
                                            success:
     ^(MediaLaunchObject *mediaLaunchObject) {
         NSLog(@"play video success");
         
         // save the object reference to control media playback
         launchObject = mediaLaunchObject;
         
     }
                                            failure:
     ^(NSError *error) {
         NSLog(@"play video failure: %@", error.localizedDescription);
         NSLog(@"play video failure: %@", error);
         
         [[GSSharedData sharedManager] submitError:error.localizedDescription];
         
         [self alertStatus:@"This stream could not be cast to the device due to network issues." :@"Failed" :0 ];
         
     }];
}




@end
