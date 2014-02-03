//
//  PlayerViewController.h
//  EON
//
//  Created by Michael McDermott on 7/31/13.
//  Copyright (c) 2013 Michael McDermott. All rights reserved.
//

#define PLAYER_TYPE_PREF_KEY @"player_type_preference"
#define AUDIO_TYPE_PREF_KEY @"audio_technology_preference"

#import <UIKit/UIKit.h>
#import "PdDispatcher.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accounts/Accounts.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PdAudioController.h"

@interface PlayerViewController : UIViewController <AVAudioPlayerDelegate>{
    PdDispatcher *dispatcher;
    void *patch;
    IBOutlet UIView *mpVolumeViewParentView;
}
@property (strong, nonatomic, readonly) PdAudioController *audioController;

@property (nonatomic,retain) IBOutlet UIView *panel;
@property (strong, nonatomic) IBOutlet UIImageView *bgImage;
@property (strong, nonatomic) IBOutlet UILabel *nowPlaying;
@property (strong, nonatomic) IBOutlet UISlider *sendVolume;
- (IBAction)goNext:(id)sender;


@property (readwrite) BOOL interruptedOnPlayback;
- (IBAction)goPrev:(id)sender;
@property (nonatomic,retain) IBOutlet UIButton * togglePlay;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

- (IBAction)showSettings:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)sendVolume:(id)sender;
- (IBAction)sendPlayerVolume:(id)sender;
- (IBAction)shareSheet:(id)sender;

@property NSTimer *aTimer;
@property NSTimer	*backgroundColorTimer;

@property (nonatomic) AVAudioPlayer *mp3Player;
@property (strong,nonatomic) NSArray *albumTracks;
@property (strong, nonatomic) NSString *nowPlayingName;
@property (nonatomic) int isPaused;
@property (nonatomic) int nowPlayingIndex;
@end
