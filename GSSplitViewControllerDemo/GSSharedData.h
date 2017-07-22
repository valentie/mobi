//
//  GSSharedData.h
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 9/10/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSAppDelegate.h"

@interface GSSharedData : NSObject


+ (id)sharedManager;

-(BOOL)userHasEducationAccess;
-(NSString*) suffixNumber:(NSNumber*)number;
-(void)touch;
-(void)submitCreditsPurchased:(int)credits;
-(void)submitVideoPurchased:(int)video_id andTransactionIdentifier:(NSString *)transactionIdentifier;
-(void)submitAPNDeviceToken:(NSString *)token;
-(void)addVideoToFavourite:(int)video_id;
-(void)removeVideoFromFavourite:(int)video_id;
-(void)submitLikePressedForOnDemandVideo:(int)video_id;
-(void)submitLikePressedForLiveTvChannel:(int)channel_id;
-(void)submitViewPressedForOnDemandVideo:(int)video_id;
-(void)submitViewPressedForLiveTvChannel:(int)channel_id;
-(void)submitLikePressedForOnDemandEducationVideo:(int)video_id;
-(void)submitViewPressedForOnDemandEducationVideo:(int)video_id;



-(void)submitError:(NSString *)message;

@end
