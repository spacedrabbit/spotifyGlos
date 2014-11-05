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
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface JSLSonosViewController ()

- (IBAction)showDeviceInfo:(id)sender;
- (IBAction)showCurrentDeviceInfo:(id)sender;
- (IBAction)currentVolume:(id)sender;
- (IBAction)getAlbumArt:(id)sender;
- (IBAction)playTrack:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *albumArt;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;


@property (strong, nonatomic) SonosManager *sonosManager;
@property (strong, nonatomic) __block SonosController *currentDevice;
@property (strong, nonatomic) __block NSMutableDictionary *currentSong;
@property (strong, nonatomic) __block UIImage *albumImage;
@property (nonatomic) __block NSInteger currentVolume;


@property (strong, nonatomic) NSArray *devices;
@property (strong, nonatomic) __block NSMutableDictionary *songInfo;

@property (strong, nonatomic) AFURLSessionManager *sessionManager;
@property (strong, nonatomic) AFNetworkReachabilityManager * reachabilityManager;

@end

@implementation JSLSonosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"www.google.com"] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    
    [self.reachabilityManager startMonitoring];
    
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [NSThread sleepForTimeInterval:2.0];
        if ( [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi ) {
            NSLog(@"You're on wifi");
        }
        
    }];
    
    
    self.songInfo = [[NSMutableDictionary alloc] init];
    self.sonosManager = [SonosManager sharedInstance];
    self.currentDevice = self.sonosManager.currentDevice;
    
    [self setUpConstraints];
    
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
    
    NSLayoutConstraint *songLabelXConstraints = [NSLayoutConstraint constraintWithItem:self.songNameLabel
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0];
    
    NSLayoutConstraint *songLabelYConstraints = [NSLayoutConstraint constraintWithItem:self.songNameLabel
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.artistNameLabel
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0
                                                                          constant:10];
    NSLayoutConstraint *songLabelWidthConstraints = [NSLayoutConstraint constraintWithItem:self.songNameLabel
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.albumArt
                                                                             attribute:NSLayoutAttributeWidth
                                                                            multiplier:.75
                                                                              constant:0];
    NSLayoutConstraint *songLabelHeightConstraints = [NSLayoutConstraint constraintWithItem:self.songNameLabel
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:nil
                                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                                             multiplier:1.0
                                                                               constant:40];
    
    [self.view addConstraint:songLabelXConstraints];
    [self.view addConstraint:songLabelYConstraints];
    [self.view addConstraint:songLabelWidthConstraints];
    [self.view addConstraint:songLabelHeightConstraints];
    [self.songNameLabel setBackgroundColor:[UIColor yellowColor]];
    
    NSLayoutConstraint *buttonContainerXConstraints = [NSLayoutConstraint constraintWithItem:self.buttonContainer
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1.0
                                                                              constant:0];
    
    NSLayoutConstraint *buttonContainerYConstraints = [NSLayoutConstraint constraintWithItem:self.buttonContainer
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.songNameLabel
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1.0
                                                                              constant:10];
    NSLayoutConstraint *buttonContainerWidthConstraints = [NSLayoutConstraint constraintWithItem:self.buttonContainer
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.albumArt
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                multiplier:.75
                                                                                  constant:0];
    NSLayoutConstraint *buttonContainerHeightConstraints = [NSLayoutConstraint constraintWithItem:self.buttonContainer
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.view
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0
                                                                                   constant:-10];
    
    [self.view addConstraint:buttonContainerXConstraints];
    [self.view addConstraint:buttonContainerYConstraints];
    [self.view addConstraint:buttonContainerWidthConstraints];
    [self.view addConstraint:buttonContainerHeightConstraints];
    [self.buttonContainer setBackgroundColor:[UIColor purpleColor]];

    
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

- (IBAction)showDeviceInfo:(id)sender {
   // NSLog(@"%@", self.sonosManager.allDevices);
    //NSDictionary *currentDeviceInfo = [NSDictionary dictionaryWithDictionary:self.sonosManager.allDevices[0]];
    //NSLog(@"%@", currentDeviceInfo);
    //self.currentDevice = [[SonosController alloc] initWithIP:currentDeviceInfo[@"ip"]];
    
    // can use the commented out stuff above to get the info; i just pulled out the specific IP
    // for "Soundwall" because the controller randomly assigns the 2 devices it finds in an array
    self.currentDevice = [[SonosController alloc] initWithIP:@"192.168.2.160" port:1400];
    NSLog(@"%@", [self.currentDevice class]);
}
    
//used to get the current song and set it to self.currentsong
- (IBAction)showCurrentDeviceInfo:(id)sender {
    
    /**********************************************************************************
     *
     *  Had to add a new conditional in SonosController.m to account for Pandora radio
     *  which is what I had been using to test. The conditional adds dictionary data
     *  so that I can pull album art.
     *
     ***********************************************************************************/
    
    __block NSDictionary *blockDictionary = [[NSDictionary alloc] init];
    
    [self.currentDevice trackInfo:^(NSDictionary * returnData, NSError *error){
        if (!error) {
            blockDictionary = [NSDictionary dictionaryWithDictionary:returnData];
            self.currentSong = [NSMutableDictionary dictionaryWithDictionary:blockDictionary];
            self.songNameLabel.text = self.currentSong[@"MetaDataAlbum"];
            self.artistNameLabel.text = self.currentSong[@"MetaDataCreator"];
        }
        else{
            NSLog(@"There was an error getting the current track\n\nThe errors: %@", error);
            
        }
    }];
}

- (IBAction)currentVolume:(id)sender {
    
    [self.currentDevice getVolume:^(NSInteger volume, NSError *error){
        if (!error) {
            NSLog(@"The volume: %li", volume);
            self.currentVolume = volume;
        }
        else{
            NSLog(@"The volume: %li , error", volume);
        }
    }];
}

- (IBAction)getAlbumArt:(id)sender {
    
    //simple method from the AFNetworking UIImageView category
    NSLog(@"%@" ,self.currentSong[@"MetaDataAlbumArtURI"]);
    [self.albumArt setImageWithURL:[NSURL URLWithString:self.currentSong[@"MetaDataAlbumArtURI"]] placeholderImage:[UIImage imageNamed:@"ele-earth-icon"]];

}

- (IBAction)playTrack:(id)sender {
    //not entirely sure how/if this works.
    
//    {
//        MetaDataAlbum = "";
//        MetaDataAlbumArtURI = "/getaa?s=1&u=x-sonos-http%3atrack%253a173058369.mp3%3fsid%3d160%26flags%3d32";
//        MetaDataCreator = "MUTO.";
//        MetaDataTitle = "Justin Timberlake - What Goes Around...Comes Around (MUTO Remix)";
//        RelTime = "0:00:56";
//        Track = 5;
//        TrackDuration = "0:03:44";
//        TrackURI = "x-sonos-http:track%3a173058369.mp3?sid=160&flags=32";
//    }
    NSError *err = nil;
    
    NSString *songTitle = self.currentSong[@"MetaDataTitle"];
    NSURL *songURL = [NSURL URLWithString:self.currentSong[@"TrackURI"]];
    NSString *songStringFromURL = [NSString stringWithContentsOfURL:songURL encoding:NSUTF8StringEncoding error:&err];
    NSLog(@"the song: %@ and URI: %@ and SongString: %@", songTitle, songURL ,songStringFromURL);
    
    [self.currentDevice play:self.currentSong[@"TrackURI"] completion:nil];
}
@end
