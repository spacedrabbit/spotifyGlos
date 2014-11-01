//
//  JSLSonosViewController.m
//  spotifyGlos
//
//  Created by Louis Tur on 10/31/14.
//  Copyright (c) 2014 com.Spotify. All rights reserved.
//

#import "JSLSonosViewController.h"
#import <sonos-objc/SonosManager.h>
#import "UIView+FrameGetters.h"

@interface JSLSonosViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *albumArt;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;

@property (strong, nonatomic) SonosManager *sonosManager;
@property (strong, nonatomic) SonosController *currentDevice;

@property (strong, nonatomic) NSArray *devices;
@property (strong, nonatomic) __block NSMutableDictionary *songInfo;
@property (strong, nonatomic) __block NSError *error;

@end

@implementation JSLSonosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sonosManager = [SonosManager sharedInstance];
    self.devices = [NSArray arrayWithArray:self.sonosManager.allDevices];
    self.currentDevice = [[SonosManager sharedInstance] currentDevice];
    
    self.songInfo = [[NSMutableDictionary alloc] init];
    self.error = [NSError errorWithDomain:@"Song Retrival Error" code:4 userInfo:nil];
    
    [self setUpConstraints];
    [self addInfoToUIElements];
}

-(void) addInfoToUIElements{
    
    [self.currentDevice trackInfo:^(NSDictionary * songInfo, NSError *error){
        if (!error) {
            self.songInfo = [NSMutableDictionary dictionaryWithDictionary: songInfo];
            NSLog(@"%@", songInfo);
        }
        else{
            NSLog(@"Thisis a block");
        }
    
    }];
}

-(void) setUpConstraints{
    
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *elementsDictionary = NSDictionaryOfVariableBindings(_albumArt, _songNameLabel, _artistNameLabel);
    NSNumber *centerY = [NSNumber numberWithDouble:CGRectGetMidY(self.view.frame)];
    NSDictionary *metrics = @{ @"frameCenterY" : centerY };
    
    NSArray *coverArtConstraints = @[ [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_albumArt]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:elementsDictionary],
                                      [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_albumArt]"
                                                                              options:0 metrics:nil
                                                                                views:elementsDictionary],
                                      
                                      [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_albumArt(==frameCenterY)]"
                                                                              options:0
                                                                              metrics:metrics
                                                                                views:elementsDictionary]
                                     ];
    
 
    
    [self addConstraints:coverArtConstraints toView:self.view andClearConstraints:NO];
    [self.albumArt setBackgroundColor:[UIColor redColor]];
    
    NSLayoutConstraint *labelXConstraints = [NSLayoutConstraint constraintWithItem:self.artistNameLabel
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0];
    NSLayoutConstraint *labelYConstraints = [NSLayoutConstraint constraintWithItem:self.artistNameLabel
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.albumArt
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:10];
    NSLayoutConstraint *labelWidthConstraints = [NSLayoutConstraint constraintWithItem:self.artistNameLabel
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.albumArt
                                                                        attribute:NSLayoutAttributeWidth
                                                                        multiplier:.75
                                                                         constant:0];
    NSLayoutConstraint *labelHeightConstraints = [NSLayoutConstraint constraintWithItem:self.artistNameLabel
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:nil
                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                            multiplier:1.0
                                                                              constant:40];
    [self.view addConstraint:labelXConstraints];
    [self.view addConstraint:labelYConstraints];
    [self.view addConstraint:labelWidthConstraints];
    [self.view addConstraint:labelHeightConstraints];
    [self.artistNameLabel setBackgroundColor:[UIColor blueColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)addConstraints:(NSArray *)constraints toView:(UIView *) view andClearConstraints:(BOOL) clear{
    
    //--- clear constraints if you need ---//
    if (clear) {
        [view removeConstraints:view.constraints];
    }
    
    //--- adds each array of layout constraints --//
    for (NSArray *loCst in constraints) {
        [view addConstraints:loCst];
    }
}
-(void)addNonFormattedConstraints:(NSArray*)constraints toView:(UIView* )view{
    for (NSLayoutConstraint *constraint in constraints) {
        [view addConstraint:constraint];
    }
}



@end
