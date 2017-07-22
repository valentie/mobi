//
//  AirplayDemoViewController.m
//  AirplayDemo
//
//  Created by Dan Zinngrabe on 1/22/12.
//  Copyright 2012 quellish.org. All rights reserved.
//

#import "AirplayDemoViewController.h"



@implementation AirplayDemoViewController

@synthesize player;

- (void)viewDidAppear:(BOOL)animated {
    CALayer         *layer      = nil;
    UIWindow        *_window    = nil;
    
    layer = [[self view] layer];
    _window = [[self view] window];
    
    
    self.view.backgroundColor = [UIColor blackColor];
    
    if (self.player == nil)
    {
        self.player = [[MPMoviePlayerController alloc] init];
        self.player.view.backgroundColor = [UIColor blackColor];
        [self.player setControlStyle:MPMovieControlStyleNone];
        if ([self.player respondsToSelector:@selector(setAllowsAirPlay:)]) {
            [self.player setAllowsAirPlay:YES];
        }
        
        [self.player.view setFrame: [[self view] bounds]];
        self.player.view.autoresizesSubviews = YES;
        self.player.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [_window addSubview:self.player.view];
        self.player.view.backgroundColor = [UIColor redColor];
        
        self.player.movieSourceType = MPMovieSourceTypeStreaming;
        [self.player setContentURL:[NSURL URLWithString:@"http://edge9.psitv.tv:1935/liveedge/307947436081_600/playlist.m3u8"]];
        [self.player prepareToPlay];
        [self.player play];
        
    }
    CGFloat scale = [[_window screen] scale];
    [layer setRasterizationScale:scale];
    [layer setShouldRasterize:YES];
     
}

- (void) dealloc {
    textLayer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
