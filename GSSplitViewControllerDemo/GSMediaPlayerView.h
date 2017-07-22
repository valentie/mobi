//
//  GSMediaPlayerView.h
//  GSSplitViewControllerDemo
//
//  Created by Rene van der Kooi on 8/17/15.
//  Copyright (c) 2015 Mindzone Company Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSApiResponseObjectItem.h"
#import "AsyncImageView.h"


@protocol GSMediaPlayerViewDelegate <NSObject>
-(void)mediaPlayerButtonLikePressed;
-(void)mediaPlayerButtonSharePressed;
-(void)didForceFullScreenToggle;

-(void)setUpNextTitleText:(NSString*)text;

-(void)setButtonsForCurrentItemWithTitle:(NSString *)title hasCommentButtonHidden:(BOOL)comment hasScheduleButtonHidden:(BOOL)schedule;

@end


@import MediaPlayer;

@interface GSMediaPlayerView : UIView
{
    bool controlsHidden;
    bool isLiveStream;

    GSApiResponseObjectItem *quickAdDict;
    NSDictionary *liveTvDict;
    NSDictionary *onDemandDict;
    NSDictionary *onDemandEducationDict;
    GSApiResponseObjectItem *bannerAdDict;
    bool canCallFinish;
    NSTimer *timer;
    int playerStoppedCounter;
    NSString *lastVideoSection;
    int lastVideoID;
}

@property (nonatomic, weak) id<GSMediaPlayerViewDelegate> delegate;
@property (nonatomic,strong) MPMoviePlayerController *player;
@property (nonatomic,strong) AsyncImageView *previewImage;


@property (nonatomic, retain) UILabel *lblStatus;
@property (nonatomic,readwrite) bool forceFullScreen;
@property (nonatomic, retain) UIImageView *imageLogo;
@property (nonatomic, retain) UIButton *btnLike;
@property (nonatomic, retain) UIButton *btnShare;
@property (nonatomic, retain) UIButton *btnClose;
@property (nonatomic, retain) UILabel *lblTimePlayed;
@property (nonatomic, retain) UILabel *lblTimeLeft;
@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UIButton *btnStartStop;
@property (nonatomic, retain) MPVolumeView *volumeView;

-(void)cleanup;
-(void)updateButtonsAfterRotation;


-(void)playLiveTv:(NSDictionary*)dataobject;
-(void)playOnDemandVideo:(NSDictionary*)dataobject;
-(void)playOnDemandEducationVideo:(NSDictionary*)dataobject;

-(void)setCurrentSection:(NSString *)section;

@end
