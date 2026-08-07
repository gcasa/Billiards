//
//  BilliardsView.m
//  Billiards
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.
//

#import "BilliardsView.h"
#import "GameState.h"
#import "Table.h"
#import "PhysicsEngine.h"
#import "GameRules.h"
#import "Ball.h"
#import "Vec2.h"
#import "SoundEffects.h"

static const CGFloat BilliardsTableImageWidth  = 1438.0;
static const CGFloat BilliardsTableImageHeight = 889.0;
static const NSRect  BilliardsImagePlayRect    = {{95.0, 105.0}, {1249.0, 681.0}};

// ---------------------------------------------------------------------------
// Ball colour helpers
// ---------------------------------------------------------------------------

static NSColor *PoolBallColor(int number) {
  switch (number) {
    case  1: case  9: return [NSColor colorWithCalibratedRed:1.00 green:0.80 blue:0.00 alpha:1.0];
    case  2: case 10: return [NSColor colorWithCalibratedRed:0.05 green:0.20 blue:0.80 alpha:1.0];
    case  3: case 11: return [NSColor colorWithCalibratedRed:0.80 green:0.00 blue:0.00 alpha:1.0];
    case  4: case 12: return [NSColor colorWithCalibratedRed:0.50 green:0.00 blue:0.50 alpha:1.0];
    case  5: case 13: return [NSColor colorWithCalibratedRed:1.00 green:0.45 blue:0.00 alpha:1.0];
    case  6: case 14: return [NSColor colorWithCalibratedRed:0.00 green:0.48 blue:0.00 alpha:1.0];
    case  7: case 15: return [NSColor colorWithCalibratedRed:0.50 green:0.05 blue:0.05 alpha:1.0];
    case  8:          return [NSColor colorWithCalibratedRed:0.08 green:0.08 blue:0.08 alpha:1.0];
    default:          return [NSColor grayColor];
  }
}

static NSColor *SnookerBallColor(int number) {
  if (number >= 1 && number <= 15)
    return [NSColor colorWithCalibratedRed:0.85 green:0.02 blue:0.02 alpha:1.0];
  switch (number) {
    case 16: return [NSColor colorWithCalibratedRed:1.00 green:0.85 blue:0.00 alpha:1.0];
    case 17: return [NSColor colorWithCalibratedRed:0.00 green:0.52 blue:0.00 alpha:1.0];
    case 18: return [NSColor colorWithCalibratedRed:0.52 green:0.26 blue:0.08 alpha:1.0];
    case 19: return [NSColor colorWithCalibratedRed:0.05 green:0.20 blue:0.80 alpha:1.0];
    case 20: return [NSColor colorWithCalibratedRed:1.00 green:0.38 blue:0.68 alpha:1.0];
    case 21: return [NSColor colorWithCalibratedRed:0.07 green:0.07 blue:0.07 alpha:1.0];
    default: return [NSColor grayColor];
  }
}

static NSColor *BilliardsBallColor(int number) {
  switch (number) {
    case 1: return [NSColor colorWithCalibratedRed:0.80 green:0.00 blue:0.00 alpha:1.0];
    case 2: return [NSColor colorWithCalibratedRed:1.00 green:0.82 blue:0.00 alpha:1.0];
    default: return [NSColor grayColor];
  }
}

// ---------------------------------------------------------------------------

@implementation BilliardsView

+ (NSSize)preferredViewSize {
  NSImage *image = [NSImage imageNamed:@"billiard_table"];
  if (image) return [image size];
  return NSMakeSize(900, 520);
}

- (NSRect)playRectForBounds:(NSRect)bounds {
  CGFloat xScale = NSWidth(bounds)  / BilliardsTableImageWidth;
  CGFloat yScale = NSHeight(bounds) / BilliardsTableImageHeight;
  return NSMakeRect(NSMinX(bounds) + NSMinX(BilliardsImagePlayRect) * xScale,
                    NSMinY(bounds) + NSMinY(BilliardsImagePlayRect) * yScale,
                    NSWidth(BilliardsImagePlayRect)  * xScale,
                    NSHeight(BilliardsImagePlayRect) * yScale);
}

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _tableImage = [NSImage imageNamed:@"billiard_table"];

    NSRect play = [self playRectForBounds:[self bounds]];

    _state   = [[GameState alloc] init];
    _table   = [[Table alloc] initWithRect:play];
    _physics = [[PhysicsEngine alloc] init];
    _rules   = [[GameRules alloc] init];

    [_state setGameType:GameTypePool];
    [_rules beginNewRack:_state table:_table];

    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60.0
                                              target:self
                                            selector:@selector(tick:)
                                            userInfo:nil
                                             repeats:YES];
  }
  return self;
}

- (void)dealloc { [_timer invalidate]; }

- (BOOL)isFlipped { return NO; }

- (void)newGameWithType:(GameType)type {
  [_state setGameType:type];
  [_rules beginNewRack:_state table:_table];
  [self setNeedsDisplay:YES];
}

- (void)tick:(NSTimer *)timer {
  if ([_state winner] != 0) return; // Game over — stop simulating

  [_physics step:1.0 / 60.0 state:_state table:_table];

  if (_wasMoving && ![_state ballsInMotion]) {
    [_rules shotEnded:_state table:_table];
  }

  _wasMoving = [_state ballsInMotion];
  [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event {
  if ([_state ballsInMotion]) return;
  if ([_state winner] != 0)   return;

  NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
  [_state setAiming:YES];
  [_state setAimStart:Vec2Make(p.x, p.y)];
  [_state setAimCurrent:Vec2Make(p.x, p.y)];
}

- (void)mouseDragged:(NSEvent *)event {
  if (![_state isAiming]) return;
  NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
  [_state setAimCurrent:Vec2Make(p.x, p.y)];
  [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
  if (![_state isAiming]) return;
  [_state setAiming:NO];

  Ball *cue = [_state cueBall];
  if (!cue) return;

  Vec2    start     = [_state aimStart];
  Vec2    end       = [_state aimCurrent];
  Vec2    drag      = Vec2Sub(start, end);
  CGFloat power     = MIN(Vec2Len(drag), 180.0);
  Vec2    direction = Vec2Normalize(drag);

  // Reset per-shot tracking BEFORE setting velocity so physics picks it up cleanly
  [_state beginShot];
  [cue setVelocity:Vec2Mul(direction, power * 8.0)];
  if (power > 0.5) [[SoundEffects sharedEffects] playCueHitWithPower:power];
}

// ---------------------------------------------------------------------------
// Drawing
// ---------------------------------------------------------------------------

- (void)drawRect:(NSRect)dirtyRect {
  [[NSColor colorWithCalibratedWhite:0.12 alpha:1.0] set];
  NSRectFill([self bounds]);

  [self drawTable];
  [self drawBalls];

  if ([_state isAiming]) [self drawAimLine];

  [self drawHUD];
}

- (void)drawTable {
  NSRect outer = [self bounds];
  if (_tableImage) {
    [_tableImage drawInRect:outer
                   fromRect:NSZeroRect
                  operation:NSCompositeSourceOver
                   fraction:1.0
             respectFlipped:YES
                      hints:nil];
  } else {
    NSRect play = [_table playRect];
    [[NSColor colorWithCalibratedRed:0.22 green:0.12 blue:0.05 alpha:1.0] set];
    [[NSBezierPath bezierPathWithRoundedRect:outer xRadius:18 yRadius:18] fill];
    [[NSColor colorWithCalibratedRed:0.02 green:0.28 blue:0.10 alpha:1.0] set];
    [[NSBezierPath bezierPathWithRoundedRect:play xRadius:8 yRadius:8] fill];
    [[NSColor blackColor] set];
    for (NSValue *value in [_table pockets]) {
      NSPoint  pt = [value pointValue];
      CGFloat  pr = [_table pocketRadius];
      [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(pt.x - pr, pt.y - pr, pr * 2, pr * 2)] fill];
    }
  }
}

- (NSColor *)colorForBall:(Ball *)b {
  if ([b isCueBall]) return [NSColor whiteColor];
  int num = [b number];
  switch ([_state gameType]) {
    case GameTypePool:
    case GameTypePool9Ball: return PoolBallColor(num);
    case GameTypeSnooker:   return SnookerBallColor(num);
    case GameTypeBilliards: return BilliardsBallColor(num);
  }
  return [NSColor grayColor];
}

- (void)drawInnerCircle:(Vec2)p radius:(CGFloat)r color:(NSColor *)color {
  CGFloat nr    = r * 0.52;
  NSRect  inner = NSMakeRect(p.x - nr, p.y - nr, nr * 2, nr * 2);
  [color set];
  [[NSBezierPath bezierPathWithOvalInRect:inner] fill];
}

- (void)drawNumber:(int)number atPosition:(Vec2)p radius:(CGFloat)r textColor:(NSColor *)textColor {
  NSString *numStr = [NSString stringWithFormat:@"%d", number];

  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setAlignment:NSTextAlignmentCenter];

  CGFloat fontSize = r * 0.78;
#ifdef GNUSTEP
  fontSize = r * 0.68;
#endif

  NSDictionary *attrs = @{
    NSFontAttributeName:            [NSFont boldSystemFontOfSize:fontSize],
    NSForegroundColorAttributeName: textColor,
    NSParagraphStyleAttributeName:  ps
  };

  NSSize  textSize = [numStr sizeWithAttributes:attrs];
  CGFloat halfW    = r * 0.52;
  NSRect  textRect = NSMakeRect(p.x - halfW,
                                p.y - textSize.height / 2.0,
                                halfW * 2,
                                textSize.height);
  [numStr drawInRect:textRect withAttributes:attrs];
}

- (void)drawPoolDecorationsForBall:(Ball *)b atPosition:(Vec2)p radius:(CGFloat)r {
  int num = [b number];
  if (num == 8) {
    // White number directly on the black ball — no inner circle
    [self drawNumber:num atPosition:p radius:r textColor:[NSColor whiteColor]];
  } else if (num >= 1 && num <= 7) {
    // Solid: inner circle matches ball colour → looks solid; black number
    [self drawInnerCircle:p radius:r color:PoolBallColor(num)];
    [self drawNumber:num atPosition:p radius:r textColor:[NSColor blackColor]];
  } else {
    // Stripe (9-15): white inner circle, black number
    [self drawInnerCircle:p radius:r color:[NSColor whiteColor]];
    [self drawNumber:num atPosition:p radius:r textColor:[NSColor blackColor]];
  }
}

- (void)drawBalls {
  GameType gt = [_state gameType];

  for (Ball *b in [_state balls]) {
    if ([b isPocketed]) continue;

    Vec2    p        = [b position];
    CGFloat r        = [b radius];
    NSRect  ballRect = NSMakeRect(p.x - r, p.y - r, r * 2, r * 2);

    [[self colorForBall:b] set];
    [[NSBezierPath bezierPathWithOvalInRect:ballRect] fill];

    if (![b isCueBall] && (gt == GameTypePool || gt == GameTypePool9Ball)) {
      [self drawPoolDecorationsForBall:b atPosition:p radius:r];
    }

    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.5] set];
    NSBezierPath *outline = [NSBezierPath bezierPathWithOvalInRect:ballRect];
    [outline setLineWidth:1.0];
    [outline stroke];
  }
}

- (void)drawAimLine {
  Vec2 a = [_state aimStart];
  Vec2 b = [_state aimCurrent];
  [[NSColor colorWithCalibratedWhite:1.0 alpha:0.55] set];
  NSBezierPath *line = [NSBezierPath bezierPath];
  [line moveToPoint:NSMakePoint(a.x, a.y)];
  [line lineToPoint:NSMakePoint(b.x, b.y)];
  [line setLineWidth:2.0];
  [line stroke];
}

// ---------------------------------------------------------------------------
// HUD
// ---------------------------------------------------------------------------

static NSString *GroupName(NSInteger group) {
  if (group == 1) return @"Smalls";
  if (group == 2) return @"Larges";
  return @"?";
}

- (void)drawHUDString:(NSString *)text
               inRect:(NSRect)rect
                 font:(NSFont *)font
                color:(NSColor *)color
            alignment:(NSTextAlignment)align {
  NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
  [ps setAlignment:align];
  NSDictionary *attrs = @{
    NSFontAttributeName:            font,
    NSForegroundColorAttributeName: color,
    NSParagraphStyleAttributeName:  ps
  };
  [text drawInRect:rect withAttributes:attrs];
}

- (void)drawHUD {
  NSRect    bounds  = [self bounds];
  GameType  gt      = [_state gameType];
  NSInteger winner  = [_state winner];

  NSFont *boldFont  = [NSFont boldSystemFontOfSize:14.0];
  NSFont *smallFont = [NSFont systemFontOfSize:12.0];

  // ---- Game over banner ----
  if (winner != 0) {
    NSString *msg = [NSString stringWithFormat:@"Player %ld Wins!  New Game: ⌘N",
                     (long)winner];

    NSDictionary *attrs = @{
      NSFontAttributeName:            [NSFont boldSystemFontOfSize:20.0],
      NSForegroundColorAttributeName: [NSColor yellowColor]
    };
    NSSize  sz   = [msg sizeWithAttributes:attrs];
    CGFloat pad  = 16.0;
    NSRect  bgRect = NSMakeRect(NSMidX(bounds) - sz.width / 2.0 - pad,
                                NSMidY(bounds) - sz.height / 2.0 - pad,
                                sz.width  + pad * 2,
                                sz.height + pad * 2);

    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.80] set];
    [[NSBezierPath bezierPathWithRoundedRect:bgRect xRadius:8 yRadius:8] fill];

    NSRect textRect = NSMakeRect(bgRect.origin.x + pad,
                                 bgRect.origin.y + pad,
                                 sz.width, sz.height);
    [msg drawInRect:textRect withAttributes:attrs];
    return;
  }

  // ---- Turn / game-type line ----
  NSString *gameNames[] = {@"Billiards", @"8-Ball Pool", @"9-Ball Pool", @"Snooker"};
  NSString *gameName    = gameNames[gt];
  NSInteger shots       = [_state shotsRemaining];
  NSString *shotTag     = (shots > 1) ? @" (2 shots!)" : @"";
  NSString *turnStr     = [NSString stringWithFormat:@"Player %ld's Turn%@",
                           (long)[_state currentPlayer], shotTag];
  NSString *line1       = [NSString stringWithFormat:@"%@  |  %@", gameName, turnStr];

  NSDictionary *line1Attrs = @{
    NSFontAttributeName:            boldFont,
    NSForegroundColorAttributeName: [NSColor whiteColor]
  };
  NSSize   l1Size = [line1 sizeWithAttributes:line1Attrs];

  // ---- Group assignment line (8-ball only) ----
  NSString *line2 = nil;
  NSSize    l2Size = NSZeroSize;
  if (gt == GameTypePool) {
    line2 = [NSString stringWithFormat:@"Player 1: %@    Player 2: %@",
             GroupName([_state player1Group]),
             GroupName([_state player2Group])];
    NSDictionary *l2a = @{NSFontAttributeName: smallFont,
                          NSForegroundColorAttributeName: [NSColor whiteColor]};
    l2Size = [line2 sizeWithAttributes:l2a];
  }

  CGFloat hudW   = MAX(l1Size.width, l2Size.width) + 20.0;
  CGFloat hudH   = l1Size.height + (line2 ? l2Size.height + 4.0 : 0.0) + 14.0;
  NSRect  hudRect = NSMakeRect(NSMidX(bounds) - hudW / 2.0,
                               NSMaxY(bounds) - hudH - 8.0,
                               hudW, hudH);

  [[NSColor colorWithCalibratedWhite:0.0 alpha:0.65] set];
  [[NSBezierPath bezierPathWithRoundedRect:hudRect xRadius:5 yRadius:5] fill];

  CGFloat curY = hudRect.origin.y + hudH - l1Size.height - 8.0;

  // Line 1
  [self drawHUDString:line1
               inRect:NSMakeRect(hudRect.origin.x + 10, curY, hudW - 20, l1Size.height)
                 font:boldFont
                color:[NSColor whiteColor]
            alignment:NSTextAlignmentCenter];

  // Line 2 (8-ball groups)
  if (line2) {
    curY -= l2Size.height + 4.0;
    NSColor *infoColor = [NSColor colorWithCalibratedWhite:0.85 alpha:1.0];
    [self drawHUDString:line2
                 inRect:NSMakeRect(hudRect.origin.x + 10, curY, hudW - 20, l2Size.height)
                   font:smallFont
                  color:infoColor
              alignment:NSTextAlignmentCenter];
  }
}

@end
