//
//  GameRules.m
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.

#import "GameRules.h"
#import "GameState.h"
#import "Table.h"
#import "Ball.h"
#import "Vec2.h"

@implementation GameRules

// ---------------------------------------------------------------------------
// Rack setup
// ---------------------------------------------------------------------------

- (void)beginNewRack:(GameState *)state table:(Table *)table {
  [[state balls] removeAllObjects];

  // Reset 8-ball specific state
  [state setPlayer1Group:0];
  [state setPlayer2Group:0];
  [state setShotsRemaining:1];
  [state setBreakShot:([state gameType] == GameTypePool)];
  [state setWinner:0];
  [state beginShot];

  switch ([state gameType]) {
    case GameTypeBilliards: [self setupBilliards:state table:table]; break;
    case GameTypePool:      [self setupPool8Ball:state table:table]; break;
    case GameTypePool9Ball: [self setupPool9Ball:state table:table]; break;
    case GameTypeSnooker:   [self setupSnooker:state table:table];   break;
  }

  [state setCurrentPlayer:1];
}

- (void)setupBilliards:(GameState *)state table:(Table *)table {
  NSRect rect = [table playRect];
  CGFloat r   = 16.0;

  Ball *cue = [[Ball alloc] initWithNumber:0
                                  position:Vec2Make(NSMidX(rect) - 250, NSMidY(rect))
                                    radius:r];
  [cue setCueBall:YES];
  [[state balls] addObject:cue];

  [[state balls] addObject:[[Ball alloc] initWithNumber:1
                                               position:Vec2Make(NSMidX(rect) + 200, NSMidY(rect))
                                                 radius:r]];
  [[state balls] addObject:[[Ball alloc] initWithNumber:2
                                               position:Vec2Make(NSMidX(rect) + 100, NSMidY(rect) + 55)
                                                 radius:r]];
}

- (void)setupPool8Ball:(GameState *)state table:(Table *)table {
  NSRect rect = [table playRect];
  CGFloat r   = 16.0;

  Ball *cue = [[Ball alloc] initWithNumber:0
                                  position:Vec2Make(NSMidX(rect) - 220, NSMidY(rect))
                                    radius:r];
  [cue setCueBall:YES];
  [[state balls] addObject:cue];

  // Triangle: 1 at apex, 8 in centre (row=2, col=1), one solid + one stripe at back corners
  int ballNumbers[] = {1, 2, 9, 3, 8, 10, 4, 11, 5, 12, 6, 13, 14, 7, 15};
  CGFloat startX = NSMidX(rect) + 160;
  CGFloat startY = NSMidY(rect);
  int idx = 0;

  for (int row = 0; row < 5; row++) {
    for (int col = 0; col <= row; col++) {
      Vec2 p = Vec2Make(startX + row * r * 1.8,
                        startY + (col - row / 2.0) * r * 2.15);
      [[state balls] addObject:[[Ball alloc] initWithNumber:ballNumbers[idx++]
                                                   position:p
                                                     radius:r]];
    }
  }
}

- (void)setupPool9Ball:(GameState *)state table:(Table *)table {
  NSRect rect = [table playRect];
  CGFloat r   = 16.0;
  CGFloat s   = r * 2.2;

  Ball *cue = [[Ball alloc] initWithNumber:0
                                  position:Vec2Make(NSMidX(rect) - 220, NSMidY(rect))
                                    radius:r];
  [cue setCueBall:YES];
  [[state balls] addObject:cue];

  // Diamond: 1 at apex (cue side), 9 in centre
  int order[] = {1, 7, 2, 3, 9, 8, 6, 4, 5};
  CGFloat startX = NSMidX(rect) + 160;
  CGFloat startY = NSMidY(rect);

  Vec2 pos[9];
  pos[0] = Vec2Make(startX,         startY);
  pos[1] = Vec2Make(startX + s,     startY - s * 0.5);
  pos[2] = Vec2Make(startX + s,     startY + s * 0.5);
  pos[3] = Vec2Make(startX + s * 2, startY - s);
  pos[4] = Vec2Make(startX + s * 2, startY);
  pos[5] = Vec2Make(startX + s * 2, startY + s);
  pos[6] = Vec2Make(startX + s * 3, startY - s * 0.5);
  pos[7] = Vec2Make(startX + s * 3, startY + s * 0.5);
  pos[8] = Vec2Make(startX + s * 4, startY);

  for (int i = 0; i < 9; i++) {
    [[state balls] addObject:[[Ball alloc] initWithNumber:order[i]
                                                 position:pos[i]
                                                   radius:r]];
  }
}

- (void)setupSnooker:(GameState *)state table:(Table *)table {
  NSRect rect  = [table playRect];
  CGFloat r    = 14.0;
  CGFloat rectW = NSWidth(rect);
  CGFloat baulkX = NSMinX(rect) + rectW * 0.2;

  Ball *cue = [[Ball alloc] initWithNumber:0
                                  position:Vec2Make(baulkX - 60, NSMidY(rect))
                                    radius:r];
  [cue setCueBall:YES];
  [[state balls] addObject:cue];

  // Baulk-line colours
  [[state balls] addObject:[[Ball alloc] initWithNumber:16  // yellow
                                               position:Vec2Make(baulkX, NSMidY(rect) - 80) radius:r]];
  [[state balls] addObject:[[Ball alloc] initWithNumber:18  // brown (centre)
                                               position:Vec2Make(baulkX, NSMidY(rect)) radius:r]];
  [[state balls] addObject:[[Ball alloc] initWithNumber:17  // green
                                               position:Vec2Make(baulkX, NSMidY(rect) + 80) radius:r]];

  // Blue at centre
  [[state balls] addObject:[[Ball alloc] initWithNumber:19
                                               position:Vec2Make(NSMidX(rect), NSMidY(rect)) radius:r]];

  // Triangle of 15 reds
  CGFloat redStartX = NSMidX(rect) + rectW * 0.12;
  for (int row = 0, redNum = 1; row < 5; row++) {
    for (int col = 0; col <= row; col++) {
      Vec2 p = Vec2Make(redStartX + row * r * 1.8,
                        NSMidY(rect) + (col - row / 2.0) * r * 2.15);
      [[state balls] addObject:[[Ball alloc] initWithNumber:redNum++ position:p radius:r]];
    }
  }

  // Pink just in front of triangle
  [[state balls] addObject:[[Ball alloc] initWithNumber:20
                                               position:Vec2Make(redStartX - r * 2.5, NSMidY(rect)) radius:r]];
  // Black behind triangle
  [[state balls] addObject:[[Ball alloc] initWithNumber:21
                                               position:Vec2Make(redStartX + 5 * r * 1.8, NSMidY(rect)) radius:r]];
}

// ---------------------------------------------------------------------------
// Shot ended — dispatches to game-specific logic
// ---------------------------------------------------------------------------

- (void)shotEnded:(GameState *)state table:(Table *)table {
  if ([state gameType] == GameTypePool) {
    [self pool8BallShotEnded:state table:table];
  } else {
    // Simple alternating turns for other game types
    [state setCurrentPlayer:([state currentPlayer] == 1 ? 2 : 1)];
  }
}

// ---------------------------------------------------------------------------
// 8-Ball Pool rules
// ---------------------------------------------------------------------------

- (BOOL)ballIsInGroup:(NSInteger)ballNumber group:(NSInteger)group {
  if (group == 1) return (ballNumber >= 1 && ballNumber <= 7);
  if (group == 2) return (ballNumber >= 9 && ballNumber <= 15);
  return NO;
}

- (BOOL)playerHasBallsRemaining:(GameState *)state player:(NSInteger)player {
  NSInteger group = (player == 1) ? [state player1Group] : [state player2Group];
  if (group == 0) return YES; // Groups not yet assigned; assume balls remain
  for (Ball *b in [state balls]) {
    if ([b isCueBall] || [b isPocketed]) continue;
    if ([b number] == 8) continue;
    if ([self ballIsInGroup:[b number] group:group]) return YES;
  }
  return NO;
}

- (void)pool8BallShotEnded:(GameState *)state table:(Table *)table {
  NSInteger currentPlayer  = [state currentPlayer];
  BOOL      isBreak        = [state isBreakShot];
  NSArray  *pocketedThisShot = [[state ballsPocketedThisShot] copy];
  BOOL      cuePocketed    = [state cueBallPocketedThisShot];
  NSInteger firstContact   = [state firstContactBallNumber];

  // Clear break flag — it has fired
  [state setBreakShot:NO];

  // ---- Determine if 8-ball was pocketed this shot ----
  BOOL eightBallPocketed = NO;
  for (Ball *b in pocketedThisShot) {
    if ([b number] == 8) { eightBallPocketed = YES; break; }
  }

  // ================================================================
  // BREAK SHOT
  // ================================================================
  if (isBreak) {
    if (eightBallPocketed) {
      // 8-ball on break → do-over, same player re-breaks
      [self beginNewRack:state table:table];
      // beginNewRack sets currentPlayer = 1; restore the breaking player
      [state setCurrentPlayer:currentPlayer];
      [state setBreakShot:YES];
      return;
    }
    if (cuePocketed) {
      // Scratch on break → foul, opponent gets 2 shots
      NSInteger opponent = (currentPlayer == 1) ? 2 : 1;
      [state setCurrentPlayer:opponent];
      [state setShotsRemaining:2];
    }
    // Groups are NOT assigned on the break regardless of balls pocketed
    return;
  }

  // ================================================================
  // REGULAR SHOT
  // ================================================================
  NSInteger myGroup        = (currentPlayer == 1) ? [state player1Group] : [state player2Group];
  BOOL      groupsAssigned = ([state player1Group] != 0);
  BOOL      myBallsRemain  = [self playerHasBallsRemaining:state player:currentPlayer];

  // ---- Foul detection ----
  BOOL foul = NO;

  // Scratch (cue ball in pocket)
  if (cuePocketed) foul = YES;

  // Wrong first contact
  if (!foul && firstContact != -1) {
    if (firstContact == 8) {
      // Hitting 8-ball first is a foul unless the player has cleared their group
      if (myBallsRemain) foul = YES;
    } else if (groupsAssigned) {
      if (!myBallsRemain) {
        // Player is on the black; must hit 8-ball first, not any other ball
        foul = YES;
      } else if (![self ballIsInGroup:firstContact group:myGroup]) {
        // Hit opponent's ball first
        foul = YES;
      }
    }
    // If groups not yet assigned, any non-8 first contact is acceptable
  }

  // ---- 8-ball pocketed ----
  if (eightBallPocketed) {
    if (cuePocketed) {
      // White follows black → opponent wins regardless of anything else
      [state setWinner:(currentPlayer == 1) ? 2 : 1];
      return;
    }
    if (foul) {
      // Foul while potting the 8-ball → opponent wins
      [state setWinner:(currentPlayer == 1) ? 2 : 1];
      return;
    }
    if (!myBallsRemain) {
      // Legally potted the 8-ball after clearing group → current player wins
      [state setWinner:currentPlayer];
      return;
    }
    // Potted 8-ball before clearing group → opponent wins
    [state setWinner:(currentPlayer == 1) ? 2 : 1];
    return;
  }

  // ---- Assign groups on first legal non-8 pot ----
  if (!groupsAssigned && !foul) {
    for (Ball *b in pocketedThisShot) {
      NSInteger num = [b number];
      if (num == 8) continue;
      BOOL isSolid = (num >= 1 && num <= 7);
      if (currentPlayer == 1) {
        [state setPlayer1Group:isSolid ? 1 : 2];
        [state setPlayer2Group:isSolid ? 2 : 1];
      } else {
        [state setPlayer2Group:isSolid ? 1 : 2];
        [state setPlayer1Group:isSolid ? 2 : 1];
      }
      break; // First pot determines both groups
    }
  }

  // ---- Apply foul ----
  if (foul) {
    NSInteger opponent = (currentPlayer == 1) ? 2 : 1;
    [state setCurrentPlayer:opponent];
    [state setShotsRemaining:2];
    return;
  }

  // ---- Did the player pot one of their own group balls? ----
  BOOL pottedOwn = NO;
  myGroup = (currentPlayer == 1) ? [state player1Group] : [state player2Group];
  for (Ball *b in pocketedThisShot) {
    if ([self ballIsInGroup:[b number] group:myGroup]) { pottedOwn = YES; break; }
  }

  // ---- Manage shots remaining ----
  NSInteger shots = [state shotsRemaining];
  shots--;                              // Use one shot

  if (pottedOwn) {
    // Pot own ball: ensure at least one more shot (normal pot-and-continue)
    if (shots < 1) shots = 1;
  } else {
    // Missed (no own pot); use up bonus shots if any, else switch player
    if (shots <= 0) {
      NSInteger opponent = (currentPlayer == 1) ? 2 : 1;
      [state setCurrentPlayer:opponent];
      shots = 1;
    }
  }

  [state setShotsRemaining:shots];
}

// ---------------------------------------------------------------------------

- (BOOL)isGameOver:(GameState *)state {
  if ([state winner] != 0) return YES;
  for (Ball *b in [state balls]) {
    if (![b isCueBall] && ![b isPocketed]) return NO;
  }
  return YES;
}

@end
