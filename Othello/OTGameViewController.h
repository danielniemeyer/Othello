//
//  ViewController.h
//  Othello
//
//  Created by Daniel Niemeyer on 7/27/15.
//  Copyright (c) 2015 Daniel Niemeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

// Used for retrieving player scores
#define GAME_HUD_PLAYER1SCORE @"player1Score"
#define GAME_HUD_PLAYER2SCORE @"player2Score"

@interface OTGameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *player1ScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *player2ScoreLabel;

@property (weak, nonatomic) IBOutlet UIView *gameBoard;

- (void)updateHUDWithUserInfo:(NSDictionary *)userInfo;

@end

