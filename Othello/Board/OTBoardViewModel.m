//
//  OTBoardViewModel.m
//  Othello
//
//  Created by Daniel Niemeyer on 7/27/15.
//  Copyright (c) 2015 Daniel Niemeyer. All rights reserved.
//

#import "OTBoardViewModel.h"

@interface OTBoardViewModel()

@property (nonatomic, assign) OTPieceType        player;
@property (nonatomic, strong) NSMutableArray    *boardArray;

@end

@implementation OTBoardViewModel

- (instancetype)initWithPlayer:(OTPieceType)player;
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        self.player = player;
        self.boardArray = [self newGameBoard];        
    }
    
    return self;
}

#pragma mark --
#pragma mark Public Methods
#pragma mark --

- (BOOL)canMovePlayer:(OTPieceType)player;
{
    return [[self availableMovesForPlayer:player] count] > 0;
}

- (BOOL)isValidMove:(OTCoordinate)move forPlayer:(OTPieceType)player
{
    // Check if can make move
    if ([self.boardArray[move.x][move.y] integerValue] != OTPieceTypeNone)
    {
        return NO;
    }
    else
    {
        return [self isValidCoordinate:move forPlayer:player];
    }
}

- (OTPieceType)dropPieceAtCoordiate:(OTCoordinate)coordiate;
{
    // Make move and update current player
    self.boardArray[coordiate.x][coordiate.y] = @(self.player);
    
    // Flip pieces
    [self player:self.player flipPiecesForCoordinate:coordiate animated:YES];
    
    OTPieceType currentPlayer = self.player;
    
    // Update current player
    [self currentPlayerDidCompleteTurn];
    
    return currentPlayer;
}

- (NSInteger)scoreForPlayer:(OTPieceType)player
{
    // Return player score
    NSInteger score = 0;
    
    for (NSArray *row in self.boardArray)
    {
        for (id piece in row)
        {
            if ([piece integerValue] == player)
            {
                score++;
            }
        }
    }
    
    return score;
}

- (OTPieceType)currentPlayer
{
    return self.player;
}

- (OTPieceType)otherPlayer
{
    return self.player == OTPieceTypeBlack? OTPieceTypeWhite : OTPieceTypeBlack;
}

#pragma mark --
#pragma mark Private Methods
#pragma mark --

- (NSArray *)availableMovesForPlayer:(OTPieceType)player;
{
    // Return list of possible moves
    NSMutableArray *possibleMoves = [NSMutableArray array];
    
    // Look-up valid grid space
    for (NSInteger colIndex = 0; colIndex < BOARD_COLUMN_COUNT; colIndex++)
    {
        for (NSInteger rowIndex = 0; rowIndex < BOARD_ROW_COUNT; rowIndex++)
        {
            OTCoordinate coordinate = OTCoordinateMake(colIndex, rowIndex);
            if ([self isValidMove:coordinate forPlayer:player])
            {
                [possibleMoves addObject:@[@(colIndex), @(rowIndex)]];
            }
        }
    }
    
    return possibleMoves;
}

- (OTPieceType)winnerForCurrentGame
{
    // Checks for a winner or draw!
    NSInteger count = 0;
    for (NSArray *row in self.boardArray)
    {
        for (id piece in row)
        {
            if ([piece integerValue] == OTPieceTypeNone)
            {
                count++;
            }
        }
    }
    
    // Check if other player has any valid moves left
    OTPieceType otherPlayer = self.player == OTPieceTypeBlack? OTPieceTypeWhite : OTPieceTypeBlack;
    
    if (count == 0 || (![self canMovePlayer:otherPlayer] && ![self canMovePlayer:self.player]))
    {
        // Game over, return winner!
        NSInteger pScore = [self scoreForPlayer:self.player];
        NSInteger oScore = [self scoreForPlayer:otherPlayer];
        
        if (pScore > oScore)
        {
            return self.player;
        }
        else if (pScore < oScore)
        {
            return otherPlayer;
        }
        else
        {
            return OTPieceTypeBoth;
        }
    }
    
    return OTPieceTypeNone;
}

- (void)currentPlayerDidCompleteTurn
{
    // Check for winner!
    OTPieceType winner = [self winnerForCurrentGame];
    if (winner != OTPieceTypeNone)
    {
        // Game over, alert delegate
        [self.delegate didEndGameWithWinner:winner];
        return;
    }
    
    // Check if other player has any valid moves left!
    OTPieceType otherPlayer = [self otherPlayer];
    
    if (![self canMovePlayer:otherPlayer])
    {
        // Jump user
        [self.delegate willSkipTurnForPlayer:otherPlayer];
        return;
    }
    
    // Flips the current player
    self.player = otherPlayer;
}

- (NSInteger)player:(OTPieceType)player flipPiecesForCoordinate:(OTCoordinate)coordinate animated:(BOOL)animated;
{
    // Flip pieces
    NSMutableArray *flippedPieces = [NSMutableArray array];
    
    // Loops pieces in all 8 directions
    [flippedPieces addObjectsFromArray:[self player:player flipCoordinate:coordinate InDirection:OTCoordinateMake(0, 1)]];
    [flippedPieces addObjectsFromArray:[self player:player flipCoordinate:coordinate InDirection:OTCoordinateMake(1, 1)]];
    [flippedPieces addObjectsFromArray:[self player:player flipCoordinate:coordinate InDirection:OTCoordinateMake(1, 0)]];
    [flippedPieces addObjectsFromArray:[self player:player flipCoordinate:coordinate InDirection:OTCoordinateMake(1, -1)]];
    [flippedPieces addObjectsFromArray:[self player:player flipCoordinate:coordinate InDirection:OTCoordinateMake(0, -1)]];
    [flippedPieces addObjectsFromArray:[self player:player flipCoordinate:coordinate InDirection:OTCoordinateMake(-1, 0)]];
    [flippedPieces addObjectsFromArray:[self player:player flipCoordinate:coordinate InDirection:OTCoordinateMake(-1, 1)]];
    [flippedPieces addObjectsFromArray:[self player:player flipCoordinate:coordinate InDirection:OTCoordinateMake(-1, -1)]];

    // Animate changes
    if (animated)
    {
        for (NSArray *data in flippedPieces)
        {
            // Change array object
            OTCoordinate coordinate = OTCoordinateMake([data[1] integerValue], [data[2] integerValue]);
            self.boardArray[coordinate.x][coordinate.y] = @(player);
            
            // Animate change
            [self.delegate willFlipPieceAtCoordinate:coordinate toType:player];
        }
        //NSLog(@"%@", flippedPieces);
    }
    
    return [flippedPieces count];
}

#pragma mark --
#pragma mark Helper Methods
#pragma mark --

- (BOOL)isValidCoordinate:(OTCoordinate)coordinate forPlayer:(OTPieceType)player
{
    // Check if coordinate contains a valid move
    NSArray *validGrid = [self validTouchableRange];
    
    if (coordinate.x >= [validGrid[0][0] integerValue]
        && coordinate.x <= [validGrid[0][1] integerValue]
        && coordinate.y >= [validGrid[1][0] integerValue]
        && coordinate.y <= [validGrid[1][1] integerValue])
    {
        // Coordinate is within the allowed grid space
        // Now check if user can make a move based
        // on the color or surrounding pieces
        return [self player:player flipPiecesForCoordinate:coordinate animated:NO] > 0;
    }
    
    return NO;
}

- (NSMutableArray *)newGameBoard;
{
    // Return a new game board instance
    NSMutableArray *gameBoard = [NSMutableArray array];
    
    for (NSInteger i = 0; i < BOARD_COLUMN_COUNT; i++)
    {
        NSMutableArray *rowArray = [NSMutableArray array];
        
        for (NSInteger j = 0; j < BOARD_ROW_COUNT; j++)
        {
            [rowArray addObject:@(OTPieceTypeNone)];
        }
        
        [gameBoard addObject:rowArray];
    }
    
    // Format stater pieces
    NSArray *pieces = @[@(OTPieceTypeWhite),
                        @(OTPieceTypeBlack),
                        @(OTPieceTypeBlack),
                        @(OTPieceTypeWhite)];
    
    NSUInteger boardX = (BOARD_COLUMN_COUNT/2)-1;
    NSUInteger boardY = (BOARD_ROW_COUNT/2)-1;
    
    
    // Position four starter pieces
    for (NSInteger i = 0, j = 0; i < [pieces count]; i++)
    {
        gameBoard[boardX + (i % 2)][boardY + j] = pieces[i];
        
        if (i == 1)
            j++;
    }
    
    return gameBoard;
}

- (NSArray *)validTouchableRange;
{
    // Return a list of available grids
    NSMutableArray *nonEmptyColumns = [NSMutableArray array];
    NSMutableArray *nonEmptyRows = [NSMutableArray array];
    
    // Limit column range
    [self.boardArray enumerateObjectsUsingBlock:^(NSArray *rowArray, NSUInteger idx, BOOL *stop) {
        if ([self isNonEmptyArray:rowArray])
        {
            [nonEmptyColumns addObject:@(idx)];
        }
    }];
    
    NSMutableArray *colRange = [NSMutableArray arrayWithObjects:[nonEmptyColumns firstObject], [nonEmptyColumns lastObject], nil];
    
    // Check range scope
    if ([colRange[0] integerValue] > 0)
    {
        colRange[0] = @([colRange[0] integerValue] - 1);
    }
    if ([colRange[1] integerValue] < BOARD_COLUMN_COUNT)
    {
        colRange[1] = @([colRange[1] integerValue] + 1);
    }
    
    // Limit row range
    [self.boardArray enumerateObjectsUsingBlock:^(NSArray *rowArray, NSUInteger idx, BOOL *stop) {
        [rowArray enumerateObjectsUsingBlock:^(id piece, NSUInteger idy, BOOL *stop) {
            if ([piece integerValue] != OTPieceTypeNone)
            {
                [nonEmptyRows addObject:@(idy)];
            }
        }];
    }];
    
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [nonEmptyRows sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    NSMutableArray *rowRange = [NSMutableArray arrayWithObjects:[nonEmptyRows firstObject], [nonEmptyRows lastObject], nil];
    
    // Check range scope
    if ([rowRange[0] integerValue] > 0)
    {
        rowRange[0] = @([rowRange[0] integerValue] - 1);
    }
    if ([rowRange[1] integerValue] < BOARD_ROW_COUNT)
    {
        rowRange[1] = @([rowRange[1] integerValue] + 1);
    }
    
    NSArray *availableMoves = @[colRange, rowRange];
    return availableMoves;
}

- (BOOL)isNonEmptyArray:(NSArray *)array;
{
    // Check if array contains a valid piece
    for (id piece in array)
    {
        if ([piece integerValue] != OTPieceTypeNone)
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSArray *)player:(OTPieceType)player flipCoordinate:(OTCoordinate)coordinate InDirection:(OTCoordinate)direction
{
    // Return flipped array
    NSMutableArray *pieces = [NSMutableArray array];
    
    NSInteger index = 1, count = 0;

    // Find pieces in a given direction up until a piece of the same color is found!
    while ([self isValidColumn:coordinate.x + direction.x * index]
           && [self isValidRow:coordinate.y + direction.y * index])
    {
        id aPiece = self.boardArray[coordinate.x + direction.x * index][coordinate.y + direction.y * index];
        if ([aPiece integerValue] != OTPieceTypeNone)
        {
            // Add piece to change
            [pieces addObject:@[aPiece, @(coordinate.x + direction.x * index), @(coordinate.y + direction.y * index)]];
            
            // Count the amount of player's piece
            if ([aPiece integerValue] == player)
            {
                count++;
                break;
            }
        }
        else
        {
            break;
        }
        index++;
    }
    
    // Algorithm back-tracking
    NSInteger aCount = 0;
    NSMutableArray *picesToFlip = [NSMutableArray array];
    
    for (NSArray *data in pieces)
    {
        if ([data[0] integerValue] == player)
        {
            if (count == ++aCount)
            {
                return picesToFlip;
            }
        }
        [picesToFlip addObject:data];
    }
    
    return nil;
}

- (BOOL)isValidColumn:(NSInteger)column
{
    return column >= 0 && column < BOARD_COLUMN_COUNT;
}

- (BOOL)isValidRow:(NSInteger)row
{
    return row >= 0 && row < BOARD_ROW_COUNT;
}

@end
