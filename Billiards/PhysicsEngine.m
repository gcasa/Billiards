//
//  PhysicsEngine.m
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.

#import "PhysicsEngine.h"
#import "GameState.h"
#import "Table.h"
#import "Ball.h"
#import "Vec2.h"

@implementation PhysicsEngine

- (id)init {
  self = [super init];
  if (self) {
    _friction      = 0.985;
    _restitution   = 0.96;
    _stopThreshold = 4.0;
  }
  return self;
}

- (void)step:(CGFloat)dt state:(GameState *)state table:(Table *)table {
  [state setBallsInMotion:NO];

  for (Ball *b in [state balls]) {
    if ([b isPocketed]) continue;

    Vec2 pos = [b position];
    Vec2 vel = [b velocity];

    pos = Vec2Add(pos, Vec2Mul(vel, dt));
    vel = Vec2Mul(vel, pow(_friction, dt * 60.0));

    if (Vec2Len(vel) < _stopThreshold) {
      vel = Vec2Make(0, 0);
    } else {
      [state setBallsInMotion:YES];
    }

    [b setPosition:pos];
    [b setVelocity:vel];

    [self handleWallCollision:b table:table];
    [self handlePocket:b table:table state:state];
  }

  [self handleBallCollisions:[state balls] state:state];
}

- (void)handleWallCollision:(Ball *)b table:(Table *)table {
  NSRect r    = [table playRect];
  Vec2 p      = [b position];
  Vec2 v      = [b velocity];
  CGFloat radius = [b radius];

  if (p.x - radius < NSMinX(r)) { p.x = NSMinX(r) + radius; v.x = -v.x * _restitution; }
  if (p.x + radius > NSMaxX(r)) { p.x = NSMaxX(r) - radius; v.x = -v.x * _restitution; }
  if (p.y - radius < NSMinY(r)) { p.y = NSMinY(r) + radius; v.y = -v.y * _restitution; }
  if (p.y + radius > NSMaxY(r)) { p.y = NSMaxY(r) - radius; v.y = -v.y * _restitution; }

  [b setPosition:p];
  [b setVelocity:v];
}

- (void)handleBallCollisions:(NSArray *)balls state:(GameState *)state {
  NSUInteger count = [balls count];

  for (NSUInteger i = 0; i < count; i++) {
    Ball *a = [balls objectAtIndex:i];
    if ([a isPocketed]) continue;

    for (NSUInteger j = i + 1; j < count; j++) {
      Ball *b = [balls objectAtIndex:j];
      if ([b isPocketed]) continue;

      Vec2    delta   = Vec2Sub([b position], [a position]);
      CGFloat dist    = Vec2Len(delta);
      CGFloat minDist = [a radius] + [b radius];

      if (dist <= 0.0001 || dist >= minDist) continue;

      // Record first contact with cue ball (for foul detection)
      if ([state firstContactBallNumber] == -1) {
        if ([a isCueBall]) {
          [state setFirstContactBallNumber:[b number]];
        } else if ([b isCueBall]) {
          [state setFirstContactBallNumber:[a number]];
        }
      }

      Vec2 normal  = Vec2Mul(delta, 1.0 / dist);
      CGFloat overlap = minDist - dist;

      [a setPosition:Vec2Sub([a position], Vec2Mul(normal, overlap * 0.5))];
      [b setPosition:Vec2Add([b position], Vec2Mul(normal, overlap * 0.5))];

      Vec2    relVel        = Vec2Sub([b velocity], [a velocity]);
      CGFloat velAlongNormal = Vec2Dot(relVel, normal);

      if (velAlongNormal > 0) continue;

      CGFloat impulse    = -(1.0 + _restitution) * velAlongNormal / 2.0;
      Vec2    impulseVec = Vec2Mul(normal, impulse);

      [a setVelocity:Vec2Sub([a velocity], impulseVec)];
      [b setVelocity:Vec2Add([b velocity], impulseVec)];
    }
  }
}

- (void)handlePocket:(Ball *)b table:(Table *)table state:(GameState *)state {
  for (NSValue *value in [table pockets]) {
    NSPoint point  = [value pointValue];
    Vec2    pocket = Vec2Make(point.x, point.y);

    if (Vec2Len(Vec2Sub([b position], pocket)) < [table pocketRadius]) {
      if ([b isCueBall]) {
        // Record scratch; reposition to head area for opponent's ball-in-hand
        [state setCueBallPocketedThisShot:YES];
        NSRect r = [table playRect];
        [b setPosition:Vec2Make(NSMinX(r) + NSWidth(r) * 0.25, NSMidY(r))];
        [b setVelocity:Vec2Make(0, 0)];
      } else {
        // Record which ball was pocketed this shot (avoid duplicates)
        NSMutableArray *pocketed = [state ballsPocketedThisShot];
        if (![pocketed containsObject:b]) {
          [pocketed addObject:b];
        }
        [b setPocketed:YES];
        [b setVelocity:Vec2Make(0, 0)];
      }
      return;
    }
  }
}

@end
