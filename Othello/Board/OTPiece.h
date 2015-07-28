//
//  OTPiece.h
//  Othello
//
//  Created by Daniel Niemeyer on 7/27/15.
//  Copyright (c) 2015 Daniel Niemeyer. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

//
// Piece type is often associated with piece color
//
typedef NS_ENUM(NSUInteger ,OTPieceType)
{
    OTPieceTypeNone = 0,
    OTPieceTypeBlack,
    OTPieceTypeWhite,
    OTPieceTypeBoth,
};

//
// Coordinate struct
//
struct OTCoordinate {
    NSInteger x;
    NSInteger y;
};
typedef struct OTCoordinate OTCoordinate;

//
// Build Coordinate object
//
static inline OTCoordinate
OTCoordinateMake(NSInteger x, NSInteger y)
{
    OTCoordinate c; c.x = x; c.y = y; return c;
}

//
// Compare point objects
//
static inline bool
__OTCoordinateEqualToCoordinate(OTCoordinate coordinate1, OTCoordinate coordinate2)
{
    return coordinate1.x == coordinate2.x && coordinate1.y == coordinate2.y;
}
#define OTCoordinateEqualToCoordinate __OTCoordinateEqualToCoordinate

@interface OTPiece : CAShapeLayer

- (instancetype)initWithType:(OTPieceType)pieceType andCoordinate:(OTCoordinate)coordinate;

- (void)setPieceType:(OTPieceType)pieceType animated:(BOOL)animated;

- (OTCoordinate)coordinate;

@end