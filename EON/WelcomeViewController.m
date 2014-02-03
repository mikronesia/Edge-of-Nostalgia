//
//  WelcomeViewController.m
//  EON
//
//  Created by Michael McDermott on 7/30/13.
//  Copyright (c) 2013 Michael McDermott. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController
@synthesize imgHeadphones;
@synthesize butOK;
@synthesize intoTrext;
@synthesize aTimer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    NSArray *hpAnimation;
    hpAnimation=[[NSArray alloc] initWithObjects:
                 [UIImage imageNamed:@"hp_1.png"],
                 [UIImage imageNamed:@"hp_2.png"],
                 [UIImage imageNamed:@"hp_3.png"],
                 [UIImage imageNamed:@"hp_4.png"],
                 nil];
    self.imgHeadphones.animationImages=hpAnimation;
    self.imgHeadphones.animationDuration=5;
    [self.imgHeadphones startAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edge of Nostalgia"
                                                    message:@"Edge of Nostalgia uses your microphone to process the audio around you in real-time. The App never records anything your microphone picks up. The microphone will continue to stay on and process audio even when the App is running in the background. To exit the App remember to double click the home button and close the App."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    /*if (self.isHeadsetPluggedIn == NO)
    {
        [self.butOK setHidden:YES];
    }
    else
    {
        [self.butOK setHidden:NO];
    }
    
    AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback2,
                                     NULL
                                     );
    */
   /* aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
     target:self
     selector:@selector(timerFired:)
     userInfo:nil
     repeats:YES];*/
    // Do any additional setup after loading the view.
}

/*-(void)timerFired:(NSTimer *) theTimer
{
    if (self.isHeadsetPluggedIn == YES) {
        [self.butOK setHidden:NO];
    }
    else
        [self.butOK setHidden:YES];
}*/

void audioRouteChangeListenerCallback2 (
                                        void *inUserData,                                 // 1
                                        AudioSessionPropertyID inPropertyID,                                // 2
                                        UInt32                 inPropertyValueSize,                         // 3
                                        const void             *inPropertyValue                             // 4
                                        )
{
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return; // 5
    
    CFDictionaryRef routeChangeDictionary = inPropertyValue;        // 8
    CFNumberRef routeChangeReasonRef =
    CFDictionaryGetValue (
                          routeChangeDictionary,
                          CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                          );
    
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"You must connect headphones to listen to the audio, otherwise there will be a feedback sound through the microphone."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        //[self.hideButton];
    }
    if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable)
    {
        //[self.butOK setHidden:NO];
        /*WelcomeViewController *controller = [[WelcomeViewController alloc] init];
        //[controller showButton];
        controller.butOK.hidden=NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"YConnected."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];*/
    }
}

-(void)showButton
{
    [self.butOK setHidden:NO];
}

- (BOOL)isHeadsetPluggedIn {
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute,
                                              &routeSize,
                                              &route);
    
    /* Known values of route:
     * "Headset"
     * "Headphone"
     * "Speaker"
     * "SpeakerAndMicrophone"
     * "HeadphonesAndMicrophone"
     * "HeadsetInOut"
     * "ReceiverAndMicrophone"
     * "Lineout"
     */
    
    if (!error && (route != NULL)) {
        
        NSString* routeStr = (__bridge NSString*)route;
        
        NSRange headphoneRange = [routeStr rangeOfString : @"Head"];
        
        if (headphoneRange.location != NSNotFound) return YES;
        
    }
    
    return NO;
}




- (void)viewDidUnload
{
    [self setImgHeadphones:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)butOK:(id)sender {
    
}



@end
