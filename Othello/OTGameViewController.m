//
//  ViewController.m
//  Othello
//
//  Created by Daniel Niemeyer on 7/27/15.
//  Copyright (c) 2015 Daniel Niemeyer. All rights reserved.
//

#import "OTGameViewController.h"
#import "OTBoardViewController.h"

@interface OTGameViewController ()

@end

@implementation OTGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateHUDWithUserInfo:(NSDictionary *)userInfo
{
    NSInteger player1Score = [userInfo[GAME_HUD_PLAYER1SCORE] integerValue];
    NSInteger player2Score = [userInfo[GAME_HUD_PLAYER2SCORE] integerValue];
    
    self.player1ScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)player1Score];
    self.player2ScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)player2Score];
}

@end
