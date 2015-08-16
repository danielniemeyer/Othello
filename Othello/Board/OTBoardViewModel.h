//
//  OTBoardViewModel.h
//  Othello
//
//  Created by Daniel Niemeyer on 7/27/15.
//  Copyright (c) 2015 Daniel Niemeyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTPiece.h"

//
// Used to determine board size
//
#define BOARD_ROW_COUNT 8
#define BOARD_COLUMN_COUNT 8

@protocol OTBoardViewModelDelegate <NSObject>
@required
- (void)willSkipTurnForPlayer:(OTPieceType)player;
- (void)willFlipPieceAtCoordinate:(OTCoordinate)coordinate toType:(OTPieceType)type;
- (void)didEndGameWithWinner:(OTPieceType)player;

@end

@interface OTBoardViewModel : NSObject

@property (nonatomic, weak) id<OTBoardViewModelDelegate> delegate;

- (instancetype)initWithPlayer:(OTPieceType)player;

//
// Check if current player has any valid moves left.
//
- (BOOL)canMovePlayer:(OTPieceType)player;

//
// Given a player and a move, check if its valid.
//
- (BOOL)isValidMove:(OTCoordinate)move forPlayer:(OTPieceType)player;
//
// Place piece at a given coordinate
//
- (OTPieceType)dropPieceAtCoordiate:(OTCoordinate)coordiate;

//
// Return player score
//
- (NSInteger)scoreForPlayer:(OTPieceType)player;

//
// Getter for the internal board array
//
- (NSMutableArray *)boardArray;

//
// Getter for current player
//
- (OTPieceType)currentPlayer;

//
// Getter for other player
//
- (OTPieceType)otherPlayer;

@end
