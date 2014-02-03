//
//  PlayerViewController.m
//  EON
//
//  Created by Michael McDermott on 7/31/13.
//  Copyright (c) 2013 Michael McDermott. All rights reserved.
//

#import "PlayerViewController.h"
#import "AppDelegate.h"
#import <Social/Social.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayerViewController ()

@end

@implementation PlayerViewController
@synthesize bgImage;
@synthesize interruptedOnPlayback;
@synthesize nowPlaying;
@synthesize aTimer;
@synthesize backgroundColorTimer;
@synthesize sendVolume;
@synthesize panel=panel_;
@synthesize togglePlay;
@synthesize nowPlayingName;
@synthesize nowPlayingIndex;
@synthesize isPaused;
@synthesize mp3Player;
@synthesize albumTracks;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [self setNeedsStatusBarAppearanceUpdate];
    //Load Patch
    [self startRecording];
    _audioController = [[PdAudioController alloc] init];
    nowPlayingName = @"";
    nowPlayingIndex = 0;
    isPaused = 0;
    if ([self.audioController configurePlaybackWithSampleRate:44100
                                               numberChannels:2 inputEnabled:YES mixingEnabled:NO] != PdAudioOK)
    {
        NSLog(@"failed to initialize audio components");
    }
    
    albumTracks = [[NSArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",nil];
    
    
    //self.panel.frame = CGRectMake(0, 0, 300, 54);
    
    dispatcher = [[PdDispatcher alloc] init];
    [PdBase setDelegate:dispatcher];
    patch = [PdBase openFile:@"edge_of.pd" path:[[NSBundle mainBundle] resourcePath]];
    [PdBase sendBangToReceiver:@"trigger"];
    [PdBase sendFloat:sendVolume.value toReceiver:@"20.0"];
    [self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:YES mixingEnabled:NO];
    
    if (!patch)
    {
        NSLog(@"Failed to open patch!");
        // Gracefully handle failure...
    }
    
    [self loadTrack];
    
    // Add swipeGestures
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(oneFingerSwipeLeft:)];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:oneFingerSwipeLeft];
    
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeRight:)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:oneFingerSwipeRight];
    
    /*AudioSessionAddPropertyListener (
     kAudioSessionProperty_AudioRouteChange,
     audioRouteChangeListenerCallback,
     NULL
     );
     */
    aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(timerFired:)
                                            userInfo:nil
                                             repeats:YES];
    
    backgroundColorTimer = [NSTimer scheduledTimerWithTimeInterval: 3.5
                                                            target: self
                                                          selector: @selector (updateBackgroundColor)
                                                          userInfo: nil
                                                           repeats: YES];
    
    
    [super viewDidLoad];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	
    if ([self canBecomeFirstResponder]) {
		[self becomeFirstResponder];
	}
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
         
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.panel.frame=CGRectMake(0.0, (screenBounds.size.height-340), 360, 368);
    //self.panel.frame=CGRectMake(0.0, 400, 360, 368);
    self.panel.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    
    mpVolumeViewParentView.backgroundColor = [UIColor clearColor];
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame: mpVolumeViewParentView.bounds];
    [mpVolumeViewParentView addSubview: myVolumeView];

    self.audioController.active = YES;
    [self startRecording];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    self.audioController.active = YES;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    self.audioController.active = YES;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.audioController.active = YES;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    self.audioController.active = NO;
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void) startRecording
{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    NSMutableDictionary *recordSetting;
    recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    err = nil;
    AVAudioRecorder *recorder;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!recorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //prepare to record
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    
    // start recording
    [recorder record];//recordForDuration:(NSTimeInterval) 40];
    
}

/*-(void) defineImagesForCustomMPVolumeView
{
    [volumeView setVolumeThumbImage: [UIImage imageNamed: @"thumb.png"] forState: UIControlStateNormal];
    [volumeView setMinimumVolumeSliderImage: [UIImage imageNamed: @"green_tint.png"] forState: UIControlStateNormal];
    [volumeView setMaximumVolumeSliderImage: [UIImage imageNamed: @"rightslide.png"] forState: UIControlStateNormal];
}*/

// Invoked by the backgroundColorTimer.
- (void) updateBackgroundColor {
    
    if (self.isPaused == 0)
    {
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationDuration: 3.0];
        
        CGFloat redLevel	= rand() / (float) RAND_MAX;
        CGFloat greenLevel	= rand() / (float) RAND_MAX;
        CGFloat blueLevel	= rand() / (float) RAND_MAX;
        
        self.view.backgroundColor = [UIColor colorWithRed: redLevel
                                                    green: greenLevel
                                                     blue: blueLevel
                                                    alpha: 1.0];
        [UIView commitAnimations];
    }
}

- (void)loadTrack
{
    [self.mp3Player stop];
    NSString *mPlaying = @"";
    mPlaying = [self.albumTracks objectAtIndex:nowPlayingIndex];
    NSString *mPlayingTitle = @"";
    
    if ([mPlaying isEqualToString:@"1"])
        mPlayingTitle = @"Move Closer";
    else if ([mPlaying isEqualToString:@"2"])
        mPlayingTitle = @"Trail";
    else if ([mPlaying isEqualToString:@"3"])
        mPlayingTitle = @"Golden Pond";
    else if ([mPlaying isEqualToString:@"4"])
        mPlayingTitle = @"Look Up";
    else if ([mPlaying isEqualToString:@"5"])
        mPlayingTitle = @"Harmony Whole";
    else if ([mPlaying isEqualToString:@"6"])
        mPlayingTitle = @"Sudden Mist";
    else if ([mPlaying isEqualToString:@"7"])
        mPlayingTitle = @"Silver Swans";
    
    nowPlaying.Text = mPlayingTitle;
    UIImage *image = [UIImage imageNamed:  [NSString stringWithFormat:@"%@%@",mPlaying,@".png"]];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:mPlaying
                                         ofType:@"mp3"]];
    
    self.mp3Player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    self.mp3Player.numberOfLoops = 0;
    
    [self.mp3Player play];
    self.mp3Player.delegate = self;
    //Set Image
    [bgImage setImage:image];
    
}

-(void)timerFired:(NSTimer *) theTimer
{
    if (self.mp3Player.playing==0 && self.isPaused == 0)
    {
        if (self.nowPlayingIndex==6)
            self.nowPlayingIndex = 0;
        else
            self.nowPlayingIndex++;
        
        [self loadTrack];
    }}

-(void)nextTrack
{
    if (self.nowPlayingIndex==6)
        self.nowPlayingIndex = 0;
    else
        self.nowPlayingIndex++;
    
    [self loadTrack];
}

-(void)prevTrack
{
    if (self.nowPlayingIndex==0)
        self.nowPlayingIndex = 0;
    else
        self.nowPlayingIndex--;
    
    [self loadTrack];
}

- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {
    [self nextTrack];
}

- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer {
    [self prevTrack];
}

- (void) audioPlayerBeginInterruption: player {
    
    NSLog (@"Interrupted. The system has paused audio playback.");
    
    if (self.mp3Player.playing == 0 )
    {
        interruptedOnPlayback = YES;
    }
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent
{
	if (theEvent.type == UIEventTypeRemoteControl) {
        switch(theEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                //Insert code
                [self pressPausPlay];
            case UIEventSubtypeRemoteControlPlay:
				//Insert code
                //[self pressPausPlay];
				break;
            case UIEventSubtypeRemoteControlPause:
                //[self pressPausPlay];
				// Insert code
                break;
            case UIEventSubtypeRemoteControlStop:
                //[self pressPausPlay];
				//Insert code.
                break;
            default:
                return;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	if ([self canBecomeFirstResponder]) {
		[self becomeFirstResponder];
	}
    
}

- (void)viewDidUnload
{
    [self setBgImage:nil];
    [self setNowPlaying:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)goPrev:(id)sender {
    [self prevTrack];
}

- (IBAction)goNext:(id)sender {
    [self nextTrack];
}

- (void)pressPausPlay
{
    if ([self.mp3Player isPlaying])
    {
        [self.mp3Player pause];
        [PdBase sendBangToReceiver:@"trigger"];
        [self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:NO mixingEnabled:NO];
        self.isPaused = 1;
    }
    else
    {
        [self.mp3Player play];
        [PdBase sendBangToReceiver:@"trigger"];
        self.isPaused = 0;
        [self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:YES  mixingEnabled:YES];
    }
}

- (IBAction)togglePlay:(id)sender {
    UIButton *button = (UIButton*)sender;
    
    if ([self.mp3Player isPlaying])
    {
        [self.mp3Player pause];
        [button setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [PdBase sendBangToReceiver:@"trigger"];
        [self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:NO mixingEnabled:NO];
        self.isPaused = 1;
    }
    else
    {
        [self.mp3Player play];
        [button setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [PdBase sendBangToReceiver:@"trigger"];
        self.isPaused = 0;
        [self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:YES  mixingEnabled:YES];
    }
}

- (IBAction)showSettings:(id)sender {
    CGPoint wpos = self.panel.frame.origin ;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if(wpos.x == 0 && wpos.y ==screenBounds.size.height-340){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.panel.frame=CGRectMake(0.0,(screenBounds.size.height-100), 360, 368);
        self.panel.transform = CGAffineTransformIdentity;
        [UIView commitAnimations];
        UIImage * imgOpenPanelBtn = [UIImage imageNamed:@"up-arrow.png"];
        [self.togglePlay setImage:imgOpenPanelBtn forState:UIControlStateNormal];
        
    }else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.panel.frame=CGRectMake(0.0, (screenBounds.size.height-340), 360, 368);
        self.panel.transform = CGAffineTransformIdentity;
        [UIView commitAnimations];
        UIImage * imgOpenPanelBtn = [UIImage imageNamed:@"down-arrow.png"];
        [self.togglePlay setImage:imgOpenPanelBtn forState:UIControlStateNormal];
    }
}

- (IBAction)sendVolume:(id)sender {
    //[PdBase sendBangToReceiver:@"trigger"];
    [PdBase sendFloat:sendVolume.value toReceiver:@"volume"];
}

- (IBAction)shareSheet:(id)sender {
    //NSString* someText = @"Listening to #EON (Edge of Nostalgia) by Mikronesia";
    NSArray* dataToShare = [[NSArray alloc] initWithObjects:@"Listening to #EON (Edge of Nostalgia) by Mikronesia",nil];
    
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{}];
    
}

- (IBAction)showInfo:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edge of Nostalgia"
                                                    message:@"EON is an interactive musical experience by composer and musician Mikronesia. While wearing headphones the App will process the sounds around you through your microphone and blend the sounds into the seven track album. To prevent a feedback loop the audio will only play while headphones are plugged in. Use the red volume slider to lower and raise the microphone volume."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    
}



- (BOOL)canBecomeFirstResponder
{
	return YES;
}
@end
