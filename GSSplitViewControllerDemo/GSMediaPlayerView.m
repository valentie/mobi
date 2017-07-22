//
//  GSMediaPlayerView.m
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/17/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "GSMediaPlayerView.h"
#import "Constants.h"
#import "GSAppDelegate.h"
#import "URLConnection.h"
#import "GSSharedData.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation GSMediaPlayerView

@synthesize forceFullScreen;

- (void)initialize
{
    controlsHidden = NO;
    self.forceFullScreen = NO;
    
    
    // previewFrame
    self.previewImage = [[AsyncImageView alloc] init];
    [self.previewImage setFrame: self.bounds];
    self.previewImage.backgroundColor = [UIColor clearColor];
    self.previewImage.autoresizesSubviews = YES;
    self.previewImage.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview: self.previewImage];
    [self sendSubviewToBack:self.previewImage];
    self.previewImage.hidden = NO;
    
    if (self.player == nil)
    {
        self.player = [[MPMoviePlayerController alloc] init];
        self.player.view.backgroundColor = [UIColor blackColor];
        [self.player setControlStyle:MPMovieControlStyleNone];
        if ([self.player respondsToSelector:@selector(setAllowsAirPlay:)]) {
            [self.player setAllowsAirPlay:YES];
        }
        
        [self.player.view setFrame: self.bounds];               // player's frame must match parent's
        self.player.view.autoresizesSubviews = YES;
        self.player.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
        [self addSubview: self.player.view];
        [self sendSubviewToBack:self.player.view];
    }

    
    [self updateButtonsAfterRotation];
    
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.2
                                                      target: self
                                                    selector:@selector(updateButtonsAfterRotation)
                                                    userInfo: nil repeats:YES];
    
    // load the banner ad
    [self loadBannerAd];
    
    // hide first
    [self toggleButtons];
}




-(void)updateButtonsAfterRotation
{

    [self updateLabelsForCurrentVideo];
    
    if (self.imageLogo == nil)
    {
        self.imageLogo = [[UIImageView alloc] init];
        self.imageLogo.image = [UIImage imageNamed:@"logo"];
        self.imageLogo.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageLogo];
        
    }
    
    if (self.btnClose == nil)
    {
        self.btnClose = [[UIButton alloc] init];
        self.btnClose.backgroundColor = [UIColor clearColor];
        self.btnClose.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.btnClose.layer.cornerRadius = 5.0;
        [self.btnClose setTitle:@"" forState:UIControlStateNormal];
        [self addSubview:self.btnClose];
        [self.btnClose  setImage:[UIImage imageNamed:@"icon_fullscreen"] forState:UIControlStateNormal];
        [self.btnClose addTarget:self action:@selector(btnClosePressed:) forControlEvents:UIControlEventTouchUpInside];
    }
        
    if (self.btnShare == nil)
    {
        self.btnShare = [[UIButton alloc] init];
        [self addSubview:self.btnShare];
        [self.btnShare setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
        [self.btnShare addTarget:self action:@selector(btnSharePressed:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if (self.btnLike == nil)
    {
        self.btnLike = [[UIButton alloc] init];
        [self addSubview:self.btnLike];
        [self.btnLike setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
        [self.btnLike addTarget:self action:@selector(btnLikePressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    if (self.lblStatus == nil)
    {
        self.lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,20)];
        [self addSubview:self.lblStatus];
        self.lblStatus.text = @"Loading...";
        self.lblStatus.textColor = [UIColor whiteColor];
        [self.lblStatus setFont:[UIFont systemFontOfSize:10.0]];
        self.lblStatus.shadowColor = [UIColor blackColor];
        self.lblStatus.shadowOffset = CGSizeMake(1,1);
        self.lblStatus.textAlignment = NSTextAlignmentCenter;
        self.lblStatus.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    if (self.lblTimePlayed == nil)
    {
        self.lblTimePlayed = [[UILabel alloc] init];
        [self addSubview:self.lblTimePlayed];
        self.lblTimePlayed.text = @"00:00";
        self.lblTimePlayed.textColor = [UIColor whiteColor];
        [self.lblTimePlayed setFont:[UIFont systemFontOfSize:10.0]];
        self.lblTimePlayed.shadowColor = [UIColor blackColor];
        self.lblTimePlayed.shadowOffset = CGSizeMake(1,1);
    }
    
    if (self.lblTimeLeft == nil)
    {
        self.lblTimeLeft = [[UILabel alloc] init];
        [self addSubview:self.lblTimeLeft];
        self.lblTimeLeft.text = @"00:00";
        self.lblTimeLeft.textColor = [UIColor whiteColor];
        [self.lblTimeLeft setFont:[UIFont systemFontOfSize:10.0]];
        self.lblTimeLeft.shadowColor = [UIColor blackColor];
        self.lblTimeLeft.shadowOffset = CGSizeMake(1,1);
    }
    
    if (self.volumeView == nil)
    {
        self.volumeView = [[MPVolumeView alloc] init];
        [self.volumeView setShowsVolumeSlider:NO];
        [self.volumeView sizeToFit];
        [self addSubview:self.volumeView];
    }
    
    if (self.slider == nil)
    {
        self.slider = [[UISlider alloc] init];
        [self addSubview:self.slider];
        [self.slider setBackgroundColor:[UIColor clearColor]];
        self.slider.minimumValue = 0.0;
        self.slider.maximumValue = 100.0;
        self.slider.continuous = YES;
        self.slider.value = 0.0;
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
    }
    if (self.btnStartStop == nil)
    {
        self.btnStartStop = [[UIButton alloc] init];
        [self addSubview:self.btnStartStop];
        [self.btnStartStop setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateNormal];
        self.btnStartStop.frame = CGRectMake(self.frame.size.width/2-24, self.frame.size.height/2-24, 48, 48);
        [self.btnStartStop addTarget:self action:@selector(btnStartStopPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        if (self.forceFullScreen == YES)
        {
            [self.btnClose setTitle:@"Exit" forState:UIControlStateNormal];
            
            self.superview.frame = [[UIScreen mainScreen] bounds];
            self.frame = CGRectMake(0,0,self.superview.frame.size.width,self.superview.frame.size.height);
            
            self.imageLogo.frame = CGRectMake(10, 10, 50, 50);
            self.btnClose.frame = CGRectMake(self.frame.size.width-42, 10, 32, 32);
            self.btnLike.frame = CGRectMake(10, self.frame.size.height-32, 24, 24);
            self.btnShare.frame = CGRectMake(44, self.frame.size.height-32, 24, 24);
            self.lblTimePlayed.frame = CGRectMake(78, self.frame.size.height-32, 60, 24);
            self.volumeView.frame = CGRectMake(self.frame.size.height-self.volumeView.frame.size.width,
                                               self.frame.size.width-self.volumeView.frame.size.height,
                                               self.volumeView.frame.size.width,
                                               self.volumeView.frame.size.height);
            
            self.lblTimeLeft.frame = CGRectMake(self.volumeView.frame.origin.x-10,
                                                self.volumeView.frame.origin.y+3,
                                                60,
                                                24);
            
            self.slider.frame = CGRectMake(110, self.lblTimePlayed.frame.origin.y, self.frame.size.height-110-self.volumeView.frame.size.width - 20, 24);
            
            
            self.btnStartStop.frame = CGRectMake(self.frame.size.width/2-24, self.frame.size.height/2-24, 48, 48);

            self.lblStatus.frame = CGRectMake(self.frame.size.width/2-50, 10, 100, 20);
            
            GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.splitViewController setStatusBarHidden:YES];
            
        } else {
            
            [self.btnClose setTitle:@"Expand" forState:UIControlStateNormal];
            
            self.imageLogo.frame = CGRectMake(10, 10, 50, 50);
            self.btnClose.frame = CGRectMake(self.frame.size.width-42, 10, 32, 32);
            self.btnLike.frame = CGRectMake(10, self.frame.size.height-32, 24, 24);
            self.btnShare.frame = CGRectMake(44, self.frame.size.height-32, 24, 24);
            self.lblTimePlayed.frame = CGRectMake(78, self.frame.size.height-32, 60, 24);
            self.volumeView.frame = CGRectMake(self.frame.size.width-self.volumeView.frame.size.width, self.frame.size.height-self.volumeView.frame.size.height, self.volumeView.frame.size.width, self.volumeView.frame.size.height);
            self.lblTimeLeft.frame = CGRectMake(self.volumeView.frame.origin.x-10, self.volumeView.frame.origin.y+3, 60, 24);
            
            self.slider.frame = CGRectMake(110, self.lblTimePlayed.frame.origin.y, self.frame.size.width-110-self.volumeView.frame.size.width - 20, 24);
            
            
            self.btnStartStop.frame = CGRectMake(self.frame.size.width/2-24, self.frame.size.height/2-24, 48, 48);
            
            self.lblStatus.frame = CGRectMake(self.frame.size.width/2-50, 10, 100, 20);

            
            GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.splitViewController setStatusBarHidden:NO];
            
        }
        
        
    } else {
        
        if (self.frame.size.height > self.frame.size.width)
        {
            // LANDSCAPE
            self.imageLogo.frame = CGRectMake(10, 10, 50, 50);
            self.btnClose.frame = CGRectMake(self.frame.size.height-35, 10, 24, 24);
            self.btnLike.frame = CGRectMake(10, self.frame.size.width-32, 24, 24);
            self.btnShare.frame = CGRectMake(44, self.frame.size.width-32, 24, 24);
            self.lblTimePlayed.frame = CGRectMake(78, self.frame.size.width-32, 60, 24);
            
            self.volumeView.frame = CGRectMake(self.frame.size.height-self.volumeView.frame.size.width,
                                               self.frame.size.width-self.volumeView.frame.size.height,
                                               self.volumeView.frame.size.width,
                                               self.volumeView.frame.size.height);
            
            self.lblTimeLeft.frame = CGRectMake(self.volumeView.frame.origin.x-10,
                                                self.volumeView.frame.origin.y+3,
                                                60,
                                                24);
            
            self.slider.frame = CGRectMake(110, self.lblTimePlayed.frame.origin.y, self.frame.size.height-110-self.volumeView.frame.size.width - 20, 24);
            
            self.btnStartStop.frame = CGRectMake(self.frame.size.height/2-24, self.frame.size.width/2-24, 48, 48);
            self.lblStatus.frame = CGRectMake(self.frame.size.height/2-50, 10, 100, 20);

            GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.splitViewController setStatusBarHidden:YES];
            
            
        } else {
            
            // PORTRAIT
            self.imageLogo.frame = CGRectMake(10, 10, 50, 50);
            self.btnClose.frame = CGRectMake(self.frame.size.width-35, 10, 24, 24);
            self.btnLike.frame = CGRectMake(10, self.frame.size.height-32, 24, 24);
            self.btnShare.frame = CGRectMake(44, self.frame.size.height-32, 24, 24);
            self.lblTimePlayed.frame = CGRectMake(78, self.frame.size.height-32, 60, 24);
            self.volumeView.frame = CGRectMake(self.frame.size.width-self.volumeView.frame.size.width, self.frame.size.height-self.volumeView.frame.size.height, self.volumeView.frame.size.width, self.volumeView.frame.size.height);
            self.lblTimeLeft.frame = CGRectMake(self.volumeView.frame.origin.x-10, self.volumeView.frame.origin.y+3, 60, 24);
            
            self.slider.frame = CGRectMake(110, self.lblTimePlayed.frame.origin.y, self.frame.size.width-110-self.volumeView.frame.size.width - 20, 24);
            
            self.btnStartStop.frame = CGRectMake(self.frame.size.width/2-24, self.frame.size.height/2-24, 48, 48);
            self.lblStatus.frame = CGRectMake(self.frame.size.width/2-50, 10, 100, 20);
            
            GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.splitViewController setStatusBarHidden:NO];
            
            
        }
        
    }

}


-(void)movieLoadStateChanged:(NSString *)state
{

    self.lblStatus.text = @"";
    if (self.player.loadState == MPMovieLoadStateUnknown)
    {
        self.lblStatus.text = @"";
    }
    if (self.player.loadState == MPMovieLoadStatePlayable)
    {
        self.lblStatus.text = @"";
    }
    if (self.player.loadState == MPMovieLoadStatePlaythroughOK)
    {
        self.lblStatus.text = @"";
    }
    if (self.player.loadState == MPMovieLoadStateStalled)
    {
        self.lblStatus.text = @"Buffering...";
    }

}



- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours > 0)
    {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}



-(void)updateLabelsForCurrentVideo
{
    
    if (quickAdDict != nil)
    {
        [self.delegate setButtonsForCurrentItemWithTitle:@"Advertisement" hasCommentButtonHidden:YES hasScheduleButtonHidden:YES];
    } else if (onDemandDict != nil)
    {
        NSString *video_title = [onDemandDict valueForKey:@"title"];
        if (video_title != nil)
        {
            [self.delegate setButtonsForCurrentItemWithTitle:[NSString stringWithFormat:@"You're watching %@",video_title] hasCommentButtonHidden:NO hasScheduleButtonHidden:YES];
        } else {
            [self.delegate setButtonsForCurrentItemWithTitle:@"You're watching On Demand" hasCommentButtonHidden:NO hasScheduleButtonHidden:YES];
        }
    } else if (liveTvDict != nil)
    {

        NSString *video_title = [liveTvDict valueForKey:@"title"];
        int channel_id = [[liveTvDict valueForKey:@"channel_id"] intValue];
        if (video_title != nil)
        {
            if (channel_id == 1 || channel_id == 2)
            {
                [self.delegate setButtonsForCurrentItemWithTitle:[NSString stringWithFormat:@"You're watching %@",video_title] hasCommentButtonHidden:NO hasScheduleButtonHidden:NO];
            } else {
                [self.delegate setButtonsForCurrentItemWithTitle:[NSString stringWithFormat:@"You're watching %@",video_title] hasCommentButtonHidden:NO hasScheduleButtonHidden:YES];
            }
        } else {
            if (channel_id == 1 || channel_id == 2)
            {
                [self.delegate setButtonsForCurrentItemWithTitle:@"You're watching Live Tv" hasCommentButtonHidden:NO hasScheduleButtonHidden:NO];
            } else {
                [self.delegate setButtonsForCurrentItemWithTitle:@"You're watching Live Tv" hasCommentButtonHidden:NO hasScheduleButtonHidden:YES];
            }
        }
    } else if (bannerAdDict != nil)
    {
        [self.delegate setButtonsForCurrentItemWithTitle:@"Advertisement" hasCommentButtonHidden:YES hasScheduleButtonHidden:YES];
    } else {
        [self.delegate setButtonsForCurrentItemWithTitle:@"Please select..." hasCommentButtonHidden:YES hasScheduleButtonHidden:YES];
    }
    
    
    
    
    if (controlsHidden)
    {
        self.btnLike.hidden = YES;
        self.btnShare.hidden = YES;
        self.lblTimeLeft.hidden = YES;
        self.lblTimePlayed.hidden = YES;
        self.slider.hidden = YES;
        self.btnStartStop.hidden = YES;
        self.btnClose.hidden = YES;
        self.volumeView.hidden = YES;
        self.btnClose.hidden = YES;
    } else {
        self.btnLike.hidden = NO;
        self.btnShare.hidden = NO;
        self.lblTimeLeft.hidden = NO;
        self.lblTimePlayed.hidden = NO;
        self.slider.hidden = NO;
        self.btnStartStop.hidden = NO;
        self.btnClose.hidden = NO;
        self.volumeView.hidden = NO;
        self.btnClose.hidden = NO;
        
        if (quickAdDict != nil)
        {
            self.btnLike.hidden=YES;
            self.btnShare.hidden=YES;
            self.slider.hidden = YES;
            self.lblTimeLeft.hidden = YES;
            self.lblTimePlayed.hidden = YES;
            self.volumeView.hidden = YES;

        } else if (onDemandDict != nil)
        {
            self.lblTimeLeft.hidden = NO;
            self.lblTimePlayed.hidden = NO;
            self.slider.hidden = NO;
            [self.slider setMaximumValue:self.player.duration];
            [self.slider setValue:self.player.currentPlaybackTime animated:YES];
            
            self.lblTimeLeft.text = [self timeFormatted:(int)(self.player.duration-self.player.currentPlaybackTime)];
            self.lblTimePlayed.text = [self timeFormatted:(int)self.player.currentPlaybackTime];
        } else if (liveTvDict != nil)
        {
            self.lblTimePlayed.hidden = YES;
            self.slider.hidden = YES;
            self.lblTimeLeft.text = @"Live";
            self.lblTimeLeft.hidden = NO;
            self.lblTimePlayed.hidden = YES;
        } else if (bannerAdDict != nil)
        {
            self.btnLike.hidden=YES;
            self.btnShare.hidden=YES;
            self.slider.hidden = YES;
            self.lblTimeLeft.hidden = YES;
            self.lblTimePlayed.hidden = YES;
            self.volumeView.hidden = YES;
        }
        
        if (self.player.playbackState == MPMoviePlaybackStatePlaying)
        {
            self.previewImage.hidden = YES;
            
            // set image coz we are playing
            UIImage *btnImage = [UIImage imageNamed:@"icon_pause"];
            [self.btnStartStop setImage:btnImage forState:UIControlStateNormal];
            
        } else {
            // set image coz we are playing
            UIImage *btnImage = [UIImage imageNamed:@"icon_play"];
            [self.btnStartStop setImage:btnImage forState:UIControlStateNormal];
        }
        
        
        
    }


    if(self.player.playbackState == MPMoviePlaybackStateInterrupted)
    {
        self.lblTimeLeft.hidden = NO;
        int percentage = self.player.playableDuration / self.player.duration;
        if(self.player.duration == self.player.playableDuration){
            // all done
            self.lblTimeLeft.text = @"Buffering...";
        } else {
            self.lblTimeLeft.text = [NSString stringWithFormat:@"Buffering... (%d%%)", percentage];
        }
        
    }
    
    
    
    if(self.player.playbackState == MPMoviePlaybackStateStopped)
    {

        if (isnan(self.player.currentPlaybackTime) && lastVideoID > 0)
        {
            playerStoppedCounter++;
            if (playerStoppedCounter < 20)
            {
                [self.delegate setButtonsForCurrentItemWithTitle:[NSString stringWithFormat:@"Next video starts in %is",(25-playerStoppedCounter)/5] hasCommentButtonHidden:YES hasScheduleButtonHidden:YES];
            } else {
                [self loadNextVideo:lastVideoSection andVideoID:lastVideoID];
            }
        }
        
    }
}

-(void)MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification:(NSString*)str
{

}


- (IBAction)sliderValueChanged:(UISlider *)sender
{
    self.player.currentPlaybackTime = sender.value;
}

-(void)moviePlayBackDidFinish:(id)sender
{
    NSLog(@"moviePlayBackDidFinish");
    playerStoppedCounter = 0;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification object:self.player];

    if (quickAdDict != nil)
    {
        quickAdDict = nil;
        [self playCurrentItem];
        
    } else if (onDemandDict != nil)
    {

        onDemandDict = nil;
        [self.player stop];
        self.player.initialPlaybackTime = -1.0;
        
    } else if (liveTvDict != nil)
    {
        liveTvDict = nil;
        
    } else if (bannerAdDict != nil)
    {
        bannerAdDict = nil;
        [self playCurrentItem];
    }
}


- (id)initWithCoder:(NSCoder *)aCoder
{
    if(self = [super initWithCoder:aCoder]){
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)rect{
    if(self = [super initWithFrame:rect]){
        [self initialize];
    }
    return self;
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

-(IBAction)btnSharePressed:(id)sender
{

    if (onDemandDict != nil)
    {
        NSString *section = [liveTvDict valueForKey:@"section"];
        int video_id = [[onDemandDict valueForKey:@"video_id"] intValue];
        NSString *video_title = [liveTvDict valueForKey:@"title"];
        NSString *video_description = [liveTvDict valueForKey:@"description"];
        
        if ([section isEqualToString:@"education"])
        {
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ondemand_education/%i",API_SHAREURL,video_id]];
//            content.contentTitle = video_title;
//            content.contentDescription = video_description;
//            content.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ondemand_education/screenshots/%i.png",API_IMAGE_HOST,video_id]];
            
            FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
            dialog.fromViewController = self;
            dialog.shareContent = content;
            dialog.mode = FBSDKShareDialogModeNative; // if you don't set this before canShow call, canShow would always return YES
            if (![dialog canShow]) {
                // fallback presentation when there is no FB app
                dialog.mode = FBSDKShareDialogModeFeedBrowser;
            }
            [dialog show];
        } else {
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ondemand/%i",API_SHAREURL,video_id]];
//            content.contentTitle = video_title;
//            content.contentDescription = video_description;
//            content.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@ondemand/screenshots/%i.png",API_IMAGE_HOST,video_id]];
            
            FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
            dialog.fromViewController = self;
            dialog.shareContent = content;
            dialog.mode = FBSDKShareDialogModeNative; // if you don't set this before canShow call, canShow would always return YES
            if (![dialog canShow]) {
                // fallback presentation when there is no FB app
                dialog.mode = FBSDKShareDialogModeFeedBrowser;
            }
            [dialog show];
        }
        
        
        
        
        
    } else  if (liveTvDict != nil)
    {
        
        
        int channel_id = [[liveTvDict valueForKey:@"id"] intValue];
        NSString *channel_title = [liveTvDict valueForKey:@"title"];
        
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@livetv/%i",API_SHAREURL,channel_id]];
//        content.contentTitle = channel_title;
//        content.contentDescription = @"Watch Live Tv From Mobile";
//        content.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@channels/icons/%i.png",API_IMAGE_HOST,channel_id]];
        
        
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.fromViewController = self;
        dialog.shareContent = content;
        dialog.mode = FBSDKShareDialogModeNative; // if you don't set this before canShow call, canShow would always return YES
        if (![dialog canShow]) {
            // fallback presentation when there is no FB app
            dialog.mode = FBSDKShareDialogModeFeedBrowser;
        }
        [dialog show];
        
    }
    
}


-(IBAction)btnLikePressed:(id)sender
{

    if (onDemandDict != nil)
    {
        
        NSString *section = [liveTvDict valueForKey:@"section"];
        int video_id = [[onDemandDict valueForKey:@"video_id"] intValue];
        if ([section isEqualToString:@"education"])
        {
            [[GSSharedData sharedManager] submitLikePressedForOnDemandEducationVideo:video_id];
        } else {
            [[GSSharedData sharedManager] submitLikePressedForOnDemandVideo:video_id];
        }
        
        
        
        [self alertStatus:@"Liked!" :@"You have liked this video." :0];
    } else  if (liveTvDict != nil)
    {
        int channel_id = [[onDemandDict valueForKey:@"channel_id"] intValue];
        [[GSSharedData sharedManager] submitLikePressedForLiveTvChannel:channel_id];
        [self alertStatus:@"Liked!" :@"You have liked this channel." :0];
    }

}

-(IBAction)btnClosePressed:(id)sender
{
    if (self.forceFullScreen == NO)
    {
        self.forceFullScreen = YES;
    } else {
        self.forceFullScreen = NO;
    }
   
    [[NSUserDefaults standardUserDefaults] setBool:self.forceFullScreen forKey:@"forceFullScreen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.delegate didForceFullScreenToggle];
}

-(IBAction)btnStartStopPressed:(id)sender
{
    self.previewImage.hidden = YES;
    if(self.player.playbackState == MPMoviePlaybackStatePlaying)
    {
        [self.player pause];
        UIImage *btnImage = [UIImage imageNamed:@"icon_play"];
        [self.btnStartStop setImage:btnImage forState:UIControlStateNormal];
    } else
    {
        [self.player play];
        UIImage *btnImage = [UIImage imageNamed:@"icon_pause"];
        [self.btnStartStop setImage:btnImage forState:UIControlStateNormal];
    }
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self toggleButtons];
}

-(void)toggleButtons
{
    if (controlsHidden)
    {
        controlsHidden = NO;
    } else {
        controlsHidden = YES;
    }
    
    [self updateLabelsForCurrentVideo];

    
}



-(void)cleanup
{
    [self.player stop];
    onDemandDict = nil;
    bannerAdDict = nil;
    quickAdDict = nil;
    liveTvDict = nil;
    self.player = nil;
    [timer invalidate];
    timer = nil;
}

-(void)playLiveTv:(NSDictionary*)dataobject
{
    [self.player stop];
    
    onDemandDict = nil;
    bannerAdDict = nil;
    quickAdDict = nil;
    lastVideoID = 0;
    
    liveTvDict = dataobject;
    [self playCurrentItem];
}

-(void)playOnDemandVideo:(NSDictionary*)dataobject
{
    [self.player stop];
    
    liveTvDict = nil;
    bannerAdDict = nil;
    quickAdDict = nil;
    lastVideoID = 0;
    
    onDemandDict = dataobject;
    [self loadQuickAd];
}

-(void)setObservers
{
    
    // Register to receive a notification when the movie has finished playing.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:self.player];
    
    
}

-(void)setCurrentSection:(NSString *)section
{
    lastVideoSection = section;
    lastVideoID = 0;
}

-(void)playCurrentItem
{
    lastVideoID = 0;

    self.lblStatus.text = @"Loading...";
    if (quickAdDict != nil)
    {
        NSLog(@"play quickAdDict");
        
        // play video with url
        int ad_videos_id                = [[quickAdDict.responseData valueForKey:@"ad_videos_id"] intValue];
        //NSString *ad_videos_name        = [quickAdDict.responseData valueForKey:@"ad_videos_name"];
        //NSString *ad_video_link         = [quickAdDict.responseData valueForKey:@"ad_video_link"];
        
        NSString *url = [NSString stringWithFormat:@"%@ads/video/%i.mp4",API_IMAGE_HOST,ad_videos_id];
        [self.player stop];
        self.player.movieSourceType = MPMovieSourceTypeUnknown;
        
        [self.player setContentURL:[NSURL URLWithString:url]];
        [self.player prepareToPlay];
        self.player.initialPlaybackTime = -1.0;
        [self.player play];
        self.previewImage.hidden = YES;
        [self setObservers];
        
    } else if (onDemandDict != nil)
    {
        
        NSLog(@"play ON DEMAND item");
        
        // play video with url
        [self.player stop];
        int video_id = [[onDemandDict valueForKey:@"video_id"] intValue];
        lastVideoID = video_id;
        NSString *url = [onDemandDict valueForKey:@"video_url"];
        self.player.movieSourceType = MPMovieSourceTypeUnknown;
        
        
        
        [self.player setContentURL:[NSURL URLWithString:url]];
        [self.player prepareToPlay];
        self.player.initialPlaybackTime = -1.0;
        [self.player play];
        self.previewImage.hidden = YES;
        
         [self setObservers];
        
        // submit view count to singleton
        NSString *section = [onDemandDict valueForKey:@"section"];
        if ([section isEqualToString:@"education"])
        {
            [[GSSharedData sharedManager] submitViewPressedForOnDemandEducationVideo:video_id];

        } else {
            [[GSSharedData sharedManager] submitViewPressedForOnDemandVideo:video_id];
        }
        
    } else if (liveTvDict != nil)
    {
         NSLog(@"play LIVE TV item");
        
        
        // play video with url
        [self.player stop];
        self.player.movieSourceType = MPMovieSourceTypeUnknown;
        int channel_id = [[liveTvDict valueForKey:@"channel_id"] intValue];
        NSString *channel_url = [liveTvDict valueForKey:@"url"];
        
        [self.player setContentURL:[NSURL URLWithString:channel_url]];
        [self.player prepareToPlay];
        self.player.initialPlaybackTime = -1.0;
        [self.player play];
        self.previewImage.hidden = YES;
        
        [self setObservers];
        
        // submit view count to singleton
        [[GSSharedData sharedManager] submitViewPressedForLiveTvChannel:channel_id];
        
    } else if (bannerAdDict != nil)
    {
        NSLog(@"play BANNER AD item");
        
        // play video with url
        int ad_banner_id = [[bannerAdDict.responseData valueForKey:@"ad_banner_id"] intValue];
        //NSString *ad_banner_name = [bannerAdDict.responseData valueForKey:@"ad_banner_name"];
        //NSString *ad_banner_link = [bannerAdDict.responseData valueForKey:@"ad_banner_link"];
        
        NSString *url = [NSString stringWithFormat:@"%@ads/banners/%i.mp4",API_IMAGE_HOST,ad_banner_id];
        NSString *imageurl = [NSString stringWithFormat:@"%@ads/banners/%i.png",API_IMAGE_HOST,ad_banner_id];
        [self.player stop];
        self.player.movieSourceType = MPMovieSourceTypeUnknown;
        [self.player setContentURL:[NSURL URLWithString:url]];
        [self.player prepareToPlay];
        self.player.initialPlaybackTime = -1.0;
        [self.player pause];
        self.previewImage.hidden = NO;
        self.previewImage.imageURL =[NSURL URLWithString:imageurl];
        
        [self setObservers];
        
    }
}

-(void)loadNextVideo:(NSString *)section andVideoID:(int)video_id
{
    NSLog(@"load next video for %@ and id %i",section, video_id);
    
    //GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@next_video",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"section=%@&video_id=%i",section, video_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    

    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         quickAdDict = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         NSDictionary *video = [quickAdDict.responseData valueForKey:@"video"];

         [self playOnDemandVideo:video];
         
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     } uploadProgressBlock:^(float progress) {
         // when upload progresses
         
     } downloadProgressBlock:^(float progress) {
         // when download progressses
         
     }];
}


-(void)loadQuickAd
{

    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *device_uuid = [appDelegate deviceID];
    
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@video_ad",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"device_uuid=%@",device_uuid];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         quickAdDict = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         if (quickAdDict.statusCode > 0)
         {
             quickAdDict = nil;
             [self playCurrentItem];
         } else {
             // no error
             [self playCurrentItem];
         }
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         [self playCurrentItem];
         
     } uploadProgressBlock:^(float progress) {
         // when upload progresses
         
     } downloadProgressBlock:^(float progress) {
         // when download progressses
         
     }];
}


-(void)loadBannerAd
{
    NSLog(@"18");
    
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *device_uuid = [appDelegate deviceID];

    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@banner_ad",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"device_uuid=%@",device_uuid];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
     completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         bannerAdDict = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         if (bannerAdDict.statusCode > 0)
         {
             // an error occurred
             bannerAdDict = nil;
             [self playCurrentItem];
             
         } else {
             
             // no error
             [self playCurrentItem];
             
         }
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         [self playCurrentItem];
     } uploadProgressBlock:^(float progress) {
         // when upload progresses
         
     } downloadProgressBlock:^(float progress) {
         // when download progressses
         
     }];

}

@end
