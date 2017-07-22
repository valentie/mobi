//
//  GSSharedData.m
//  GSSplitViewControllerDemo
//
//  Created by Renee van der Kooi on 9/10/2558 BE.
//  Copyright (c) 2558 Mindzone Company Limited. All rights reserved.
//

#import "GSSharedData.h"
#import "Constants.h"
#import "URLConnection.h"
#import "GSApiResponseObjectItem.h"

@implementation GSSharedData

#pragma mark Singleton Methods

+ (id)sharedManager {
    static GSSharedData *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        
    }
    return self;
}


-(NSString*) suffixNumber:(NSNumber*)number
{
    if (!number)
        return @"";
    
    long long num = [number longLongValue];
    
    int s = ( (num < 0) ? -1 : (num > 0) ? 1 : 0 );
    NSString* sign = (s == -1 ? @"-" : @"" );
    
    num = llabs(num);
    
    if (num < 1000)
        return [NSString stringWithFormat:@"%@%lld",sign,num];
    
    int exp = (int) (log(num) / log(1000));
    
    NSArray* units = @[@"K",@"M",@"G",@"T",@"P",@"E"];
    
    return [NSString stringWithFormat:@"%@%.0f%@",sign, (num / pow(1000, exp)), [units objectAtIndex:(exp-1)]];
}



-(BOOL)userHasEducationAccess
{
    NSString *education_activated = [[NSUserDefaults standardUserDefaults] stringForKey:@"education_activated"];
    if (education_activated != NULL)
    {
        int activeICEducation = [education_activated intValue];
        if (activeICEducation == 1)
        {
            return YES;
        }
    }
    return NO;
}

-(void)touch
{

    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    NSString *APNTOKEN = [[NSUserDefaults standardUserDefaults] stringForKey:@"APNTOKEN"];
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@touch",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&token=%@&device_brand=%@&device_model=%@&device_os=%@&device_uuid=%@&device=IOS",user_id, APNTOKEN, SYSTEM_BRAND, SYSTEM_MODEL,SYSTEM_VERSION,[appDelegate deviceID]];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
        // NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

         
         GSApiResponseObjectItem *jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         if (jsonData.statusCode > 0)
         {
             // FAILED!
         } else {
             
             // Store the data
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             BOOL loggedin;
             if (jsonData.responseData[@"loggedin"])
             {
                  loggedin = [[jsonData.responseData valueForKey:@"loggedin"] boolValue];
             } else {
                  loggedin = NO;
             }
             [[NSUserDefaults standardUserDefaults] setBool:loggedin forKey:@"logged_in"];
            
             if (loggedin)
             {
                 [defaults setObject:[jsonData.responseData valueForKey:@"fb_id"] forKey:@"fb_id"];
                 [defaults setObject:[jsonData.responseData valueForKey:@"user_id"] forKey:@"user_id"];
                 [defaults setObject:[jsonData.responseData valueForKey:@"user_name"] forKey:@"user_name"];
                 [defaults setObject:[jsonData.responseData valueForKey:@"user_email"] forKey:@"user_email"];
                 [defaults setObject:[jsonData.responseData valueForKey:@"user_credits"] forKey:@"user_credits"];
                 [defaults setObject:[jsonData.responseData valueForKey:@"user_phone"] forKey:@"user_phone"];
             }
             
             [defaults setObject:[jsonData.responseData valueForKey:@"education_activated"] forKey:@"education_activated"];
             [defaults synchronize];
         }
         
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
}


-(void)submitCreditsPurchased:(int)credits
{
     NSLog(@"submitCreditsPurchased");
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@purchase_credits",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&credits=%i",user_id,credits];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         GSApiResponseObjectItem *jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         if (jsonData.statusCode > 0)
         {
             // FAILED!
             NSLog(@"failed to submit credits %@",jsonData.statusMessage);
         } else {
             NSLog(@"success to submit credits");
             // Store the data
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
             [defaults setObject:[jsonData.responseData valueForKey:@"fb_id"] forKey:@"fb_id"];
             [defaults setObject:[jsonData.responseData valueForKey:@"user_id"] forKey:@"user_id"];
             [defaults setObject:[jsonData.responseData valueForKey:@"user_name"] forKey:@"user_name"];
             [defaults setObject:[jsonData.responseData valueForKey:@"user_email"] forKey:@"user_email"];
             [defaults setObject:[jsonData.responseData valueForKey:@"user_credits"] forKey:@"user_credits"];
             [defaults setObject:[jsonData.responseData valueForKey:@"user_phone"] forKey:@"user_phone"];
             [defaults setObject:[jsonData.responseData valueForKey:@"education_activated"] forKey:@"education_activated"];
             [defaults synchronize];
         }

         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
}

-(void)submitVideoPurchased:(int)video_id andTransactionIdentifier:(NSString *)transactionIdentifier
{
    GSAppDelegate *appDelegate = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@purchase_video_ios",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&video_id=%i&transactionIdentifier=%@&device_uuid=%@",user_id,video_id, transactionIdentifier,[appDelegate deviceID]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         GSApiResponseObjectItem *jsonData = [[GSApiResponseObjectItem alloc] initWithNSData:data];
         
         if (jsonData.statusCode > 0)
         {
             
             // FAILED!
             NSLog(@"failed to submit video purchase %@",jsonData.statusMessage);
             
         } else {
             // Store the data
             /*
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
             [defaults setObject:[jsonData.responseData valueForKey:@"fb_id"] forKey:@"fb_id"];
             [defaults setObject:[jsonData.responseData valueForKey:@"user_id"] forKey:@"user_id"];
             [defaults setObject:[jsonData.responseData valueForKey:@"user_name"] forKey:@"user_name"];
             [defaults setObject:[jsonData.responseData valueForKey:@"user_email"] forKey:@"user_email"];
             [defaults setObject:[jsonData.responseData valueForKey:@"user_credits"] forKey:@"user_credits"];
             [defaults setObject:[jsonData.responseData valueForKey:@"user_phone"] forKey:@"user_phone"];
             [defaults setObject:[jsonData.responseData valueForKey:@"education_activated"] forKey:@"education_activated"];
             [defaults synchronize];
              */
         }

     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
}




-(void)submitAPNDeviceToken:(NSString *)token
{
    
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"APNTOKEN"];
    [defaults synchronize];
    
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@save_push_token",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&device=IOS&token=%@",user_id,token];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
    
}


-(void)addVideoToFavourite:(int)video_id
{
    
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@favourites_add",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&video_id=%i",user_id,video_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
}
-(void)removeVideoFromFavourite:(int)video_id
{
    
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@favourites_remove",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&video_id=%i",user_id,video_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
}

-(void)submitLikePressedForOnDemandVideo:(int)video_id
{

    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@ondemand_like",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&video_id=%i",user_id,video_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
}
-(void)submitLikePressedForOnDemandEducationVideo:(int)video_id
{
    
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@ondemand_education_like",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"section=education&user_id=%@&video_id=%i",user_id,video_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
}

-(void)submitLikePressedForLiveTvChannel:(int)channel_id
{

    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@livetv_like",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&channel_id=%i",user_id,channel_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
}

-(void)submitViewPressedForOnDemandVideo:(int)video_id
{

    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@ondemand_education_view",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"section=education&user_id=%@&video_id=%i",user_id,video_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
    
}

-(void)submitViewPressedForOnDemandEducationVideo:(int)video_id
{
    
    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@ondemand_view",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&video_id=%i",user_id,video_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
                              completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
    
    
}

-(void)submitViewPressedForLiveTvChannel:(int)channel_id
{

    NSString *user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@livetv_view",API_HOST,API_END_POINT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
   
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"user_id=%@&channel_id=%i",user_id,channel_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [URLConnection asyncConnectionWithRequest:request
    completionBlock:^(NSData *data, NSURLResponse *response)
    {
        
         
     } errorBlock:^(NSError *error) {
         // when error occurs
         
     }];
}



-(void)submitError:(NSString *)stacktrace
{
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * versionBuildString = [NSString stringWithFormat:@"Version: %@ (%@)", appVersionString, appBuildString];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *phoneModel = [[UIDevice currentDevice] model];
    
    NSURL *aUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mobitelevision.tv/app/crashreports"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"phone_model=%@&package_name=%@&package_version=%@&stacktrace=%@&android_version=%@",phoneModel,bundleIdentifier,versionBuildString,stacktrace, [[UIDevice currentDevice] systemVersion]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    
    [URLConnection asyncConnectionWithRequest:request completionBlock:^(NSData *data, NSURLResponse *response)
     {
         
         NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         NSLog(@"===================> %@",myString);
         
     } errorBlock:^(NSError *error) {
         
         // when error occurs
         NSLog(@"===================>  error: %@",error.localizedDescription);
         
     }];
}


@end
