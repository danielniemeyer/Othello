//
//  OTPiece.m
//  Othello
//
//  Created by Daniel Niemeyer on 7/27/15.
//  Copyright (c) 2015 Daniel Niemeyer. All rights reserved.
//

#import "OTPiece.h"

@interface OTPiece()

@property (nonatomic, assign) OTPieceType   pieceType;
@property (nonatomic, assign) OTCoordinate  coordinate;

@end

@implementation OTPiece

- (instancetype)initWithType:(OTPieceType)pieceType andCoordinate:(OTCoordinate)coordinate
{
    self = [super init];
    if (self)
    {
        [self setPieceType:pieceType animated:NO];
        self.coordinate = coordinate;
    }
    
    return self;
}

#pragma mark --
#pragma mark Public Methods
#pragma mark --

- (void)setPieceType:(OTPieceType)pieceType animated:(BOOL)animated
{
    // Flip piece
    if (animated)
    {
        // Animate
    }
    
    // Set background color
    if (pieceType == OTPieceTypeBlack)
    {
        self.fillColor = [UIColor blackColor].CGColor;
    }
    else
    {
        self.fillColor = [UIColor whiteColor].CGColor;
    }
    
    [self setNeedsDisplay];
    
    self.pieceType = pieceType;
}

@end
