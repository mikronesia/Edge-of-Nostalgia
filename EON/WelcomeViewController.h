//
//  WelcomeViewController.h
//  EON
//
//  Created by Michael McDermott on 7/30/13.
//  Copyright (c) 2013 Michael McDermott. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdDispatcher.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface WelcomeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imgHeadphones;
@property (strong, nonatomic) IBOutlet UIButton *butOK;
@property (strong, nonatomic) IBOutlet UITextView *intoTrext;
- (IBAction)butOK:(UIButton *)sender;

@property NSTimer *aTimer;
@end
