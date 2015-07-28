//
//  OTBoardViewController.m
//  Othello
//
//  Created by Daniel Niemeyer on 7/27/15.
//  Copyright (c) 2015 Daniel Niemeyer. All rights reserved.
//

#import "OTBoardViewController.h"
#import "OTBoardViewModel.h"
#import "OTPiece.h"

@interface OTBoardViewController () <OTBoardViewModelDelegate>

@property (nonatomic, strong) OTBoardViewModel  *gameModel;
@property (nonatomic, strong) NSMutableArray    *gamePieces;

@end

@implementation OTBoardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.gamePieces = [NSMutableArray array];
    
    // Instantiate a new game instante
    self.gameModel = [[OTBoardViewModel alloc] initWithPlayer:1];
    self.gameModel.delegate = self;
    
    // Setup gesture recognizers
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchGesture:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [self drawBoard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --
#pragma mark OTBoardViewModel Delegate
#pragma mark --

- (void)willFlipPieceAtCoordinate:(OTCoordinate)coordinate toType:(OTPieceType)type
{
    // Animate piece transition
    OTPiece *piece = [self pieceAtCoordinate:coordinate];
    [piece setPieceType:type animated:YES];
}

- (void)willSkipTurnForPlayer:(OTPieceType)player;
{
    NSString *title = @"Turn Skipped!";
    NSString *message = [NSString stringWithFormat:@"Player %lu goes again, since there are no available moves!", player];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)didEndGameWithWinner:(OTPieceType)player;
{
    NSString *title = [NSString stringWithFormat:@"Player %lu Wins!", player];
    NSString *message = @"Great Job!";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark --
#pragma mark Private Methods
#pragma mark --

- (void)drawBoard
{
    // Draw game board
    CGFloat boardWidth = CGRectGetWidth(self.view.bounds);
    CGFloat boardHeight = CGRectGetHeight(self.view.bounds);
    
    for (NSInteger i = 1; i < BOARD_ROW_COUNT; i++)
    {
        CGFloat rowHeight = (boardHeight/BOARD_ROW_COUNT) * i;
        
        CAShapeLayer *line = [self lineWithStartPoint:CGPointMake(0, rowHeight) endPoint:CGPointMake(boardWidth, rowHeight)];
        [self.view.layer addSublayer:line];
    }
    
    for (NSInteger i = 1; i < BOARD_COLUMN_COUNT; i++)
    {
        CGFloat colunmWidth = (boardHeight/BOARD_COLUMN_COUNT) * i;
        
        CAShapeLayer *line = [self lineWithStartPoint:CGPointMake(colunmWidth, 0) endPoint:CGPointMake(colunmWidth, boardHeight)];
        [self.view.layer addSublayer:line];
    }
    
    // Set-up initial pieces
    [self.gameModel.boardArray enumerateObjectsUsingBlock:^(NSArray *rows, NSUInteger idx, BOOL *stop) {
        [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger idy, BOOL *stop) {
            if ([obj integerValue] != OTPieceTypeNone)
            {
                // Create piece object
                [self placePiece:[obj integerValue] atCoordinate:OTCoordinateMake(idx, idy)];
            }
        }];
    }];    
}

- (void)drawPiece:(OTPiece *)piece
{
    // Customize view
    CGFloat boardWidth = CGRectGetWidth(self.view.bounds);
    CGFloat boardHeight = CGRectGetHeight(self.view.bounds);
    
    // Calculate fractional coordinate
    CGFloat fracX = boardWidth/BOARD_COLUMN_COUNT;
    CGFloat fracY = boardHeight/BOARD_ROW_COUNT;
    
    CGRect drawRect = CGRectMake((piece.coordinate.x * fracX)+2.5, (piece.coordinate.y * fracY)+2.5, fracX-5, fracY-5);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:drawRect];
    piece.path = [path CGPath];
    
}

- (void)touchGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    // Covert touch to grid coordinate
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
    
    CGFloat boardWidth = CGRectGetWidth(self.view.bounds);
    CGFloat boardHeight = CGRectGetHeight(self.view.bounds);
    
    // Calculate fractional coordinate
    CGFloat fracX = boardWidth/BOARD_COLUMN_COUNT;
    CGFloat fracY = boardHeight/BOARD_ROW_COUNT;
    
    NSUInteger boardColunm = (touchPoint.x / fracX);
    NSUInteger boardRow = (touchPoint.y / fracY);
    
    // Check row/colunm boundaries
    NSParameterAssert(boardColunm < BOARD_COLUMN_COUNT || boardRow < BOARD_ROW_COUNT);
    
    // Check if valid move
    OTCoordinate coordinate = OTCoordinateMake(boardColunm, boardRow);
    OTPieceType currentPlayer = [self.gameModel currentPlayer];
    
    if ([self.gameModel isValidMove:coordinate forPlayer:currentPlayer])
    {
        [self placePiece:[self.gameModel dropPieceAtCoordiate:coordinate] atCoordinate:coordinate];
    }
}

#pragma mark --
#pragma mark Helper Methods
#pragma mark --

- (void)placePiece:(OTPieceType)pieceType atCoordinate:(OTCoordinate)coordinate
{
    OTPiece *piece = [[OTPiece alloc] initWithType:pieceType andCoordinate:coordinate];
    [self drawPiece:piece];
    [self.view.layer addSublayer:piece];
    [self.gamePieces addObject:piece];
}

- (OTPiece *)pieceAtCoordinate:(OTCoordinate)coordinate
{
    for (OTPiece *piece in self.gamePieces)
    {
        if (OTCoordinateEqualToCoordinate(coordinate, piece.coordinate))
        {
            return piece;
        }
    }
    
    return nil;
}

- (CAShapeLayer *)lineWithStartPoint:(CGPoint)start endPoint:(CGPoint)end
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addLineToPoint:end];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.lineWidth = 1.0f;
    shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
    
    return shapeLayer;
}

@end
