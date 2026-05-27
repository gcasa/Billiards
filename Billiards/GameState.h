//
//  GameState.h
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.

#import <Foundation/Foundation.h>
#import "Vec2.h"
#import "GameType.h"
@class Ball;

@interface GameState : NSObject {
  NSMutableArray *_balls;
  NSInteger _currentPlayer;
  BOOL _ballsInMotion;
  BOOL _aiming;
  Vec2 _aimStart;
  Vec2 _aimCurrent;
  GameType _gameType;

  // Pool 8-ball: group assignments and turn management
  NSInteger _player1Group;    // 0=unassigned, 1=solids(1-7), 2=stripes(9-15)
  NSInteger _player2Group;
  NSInteger _shotsRemaining;  // shots current player still has this turn (≥1)
  BOOL _isBreakShot;

  // Per-shot tracking (reset via -beginShot before each cue strike)
  NSInteger _firstContactBallNumber; // -1 until cue ball first touches a ball
  NSMutableArray *_ballsPocketedThisShot;
  BOOL _cueBallPocketedThisShot;

  // Game result
  NSInteger _winner;          // 0=none, 1=player1, 2=player2
}

- (NSMutableArray *)balls;
- (Ball *)cueBall;

- (NSInteger)currentPlayer;
- (void)setCurrentPlayer:(NSInteger)p;

- (BOOL)ballsInMotion;
- (void)setBallsInMotion:(BOOL)m;

- (BOOL)isAiming;
- (void)setAiming:(BOOL)a;

- (Vec2)aimStart;
- (void)setAimStart:(Vec2)v;

- (Vec2)aimCurrent;
- (void)setAimCurrent:(Vec2)v;

- (GameType)gameType;
- (void)setGameType:(GameType)t;

// Pool 8-ball state
- (NSInteger)player1Group;
- (void)setPlayer1Group:(NSInteger)g;
- (NSInteger)player2Group;
- (void)setPlayer2Group:(NSInteger)g;
- (NSInteger)shotsRemaining;
- (void)setShotsRemaining:(NSInteger)n;
- (BOOL)isBreakShot;
- (void)setBreakShot:(BOOL)b;

// Per-shot tracking
- (void)beginShot;
- (NSInteger)firstContactBallNumber;
- (void)setFirstContactBallNumber:(NSInteger)n;
- (NSMutableArray *)ballsPocketedThisShot;
- (BOOL)cueBallPocketedThisShot;
- (void)setCueBallPocketedThisShot:(BOOL)b;

// Result
- (NSInteger)winner;
- (void)setWinner:(NSInteger)w;

@end
