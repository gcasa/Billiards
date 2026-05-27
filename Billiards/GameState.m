//
//  GameState.m
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.

#import "GameState.h"
#import "Ball.h"

@implementation GameState

- (id)init {
  self = [super init];
  if (self) {
    _balls                    = [[NSMutableArray alloc] init];
    _ballsPocketedThisShot    = [[NSMutableArray alloc] init];
    _currentPlayer            = 1;
    _ballsInMotion            = NO;
    _aiming                   = NO;
    _player1Group             = 0;
    _player2Group             = 0;
    _shotsRemaining           = 1;
    _isBreakShot              = NO;
    _firstContactBallNumber   = -1;
    _cueBallPocketedThisShot  = NO;
    _winner                   = 0;
  }
  return self;
}

- (NSMutableArray *)balls  { return _balls; }

- (Ball *)cueBall {
  for (Ball *b in _balls) {
    if ([b isCueBall]) return b;
  }
  return nil;
}

- (NSInteger)currentPlayer            { return _currentPlayer; }
- (void)setCurrentPlayer:(NSInteger)p { _currentPlayer = p; }

- (BOOL)ballsInMotion            { return _ballsInMotion; }
- (void)setBallsInMotion:(BOOL)m { _ballsInMotion = m; }

- (BOOL)isAiming           { return _aiming; }
- (void)setAiming:(BOOL)a  { _aiming = a; }

- (Vec2)aimStart             { return _aimStart; }
- (void)setAimStart:(Vec2)v  { _aimStart = v; }

- (Vec2)aimCurrent             { return _aimCurrent; }
- (void)setAimCurrent:(Vec2)v  { _aimCurrent = v; }

- (GameType)gameType          { return _gameType; }
- (void)setGameType:(GameType)t { _gameType = t; }

- (NSInteger)player1Group            { return _player1Group; }
- (void)setPlayer1Group:(NSInteger)g { _player1Group = g; }

- (NSInteger)player2Group            { return _player2Group; }
- (void)setPlayer2Group:(NSInteger)g { _player2Group = g; }

- (NSInteger)shotsRemaining           { return _shotsRemaining; }
- (void)setShotsRemaining:(NSInteger)n { _shotsRemaining = n; }

- (BOOL)isBreakShot         { return _isBreakShot; }
- (void)setBreakShot:(BOOL)b { _isBreakShot = b; }

- (void)beginShot {
  _firstContactBallNumber  = -1;
  [_ballsPocketedThisShot removeAllObjects];
  _cueBallPocketedThisShot = NO;
}

- (NSInteger)firstContactBallNumber           { return _firstContactBallNumber; }
- (void)setFirstContactBallNumber:(NSInteger)n { _firstContactBallNumber = n; }

- (NSMutableArray *)ballsPocketedThisShot { return _ballsPocketedThisShot; }

- (BOOL)cueBallPocketedThisShot          { return _cueBallPocketedThisShot; }
- (void)setCueBallPocketedThisShot:(BOOL)b { _cueBallPocketedThisShot = b; }

- (NSInteger)winner           { return _winner; }
- (void)setWinner:(NSInteger)w { _winner = w; }

@end
