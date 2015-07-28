//
//  ViewController.h
//  Othello
//
//  Created by Daniel Niemeyer on 7/27/15.
//  Copyright (c) 2015 Daniel Niemeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTGameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *player1Label;
@property (weak, nonatomic) IBOutlet UILabel *player2Label;
@property (weak, nonatomic) IBOutlet UILabel *currentPlayerLabel;

@property (weak, nonatomic) IBOutlet UIView *gameBoard;

@end

