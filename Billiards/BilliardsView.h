//
//  BilliardsView.h
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.

#import <AppKit/AppKit.h>
#import "GameType.h"

@class GameState;
@class Table;
@class PhysicsEngine;
@class GameRules;

@interface BilliardsView : NSView {
  GameState     *_state;
  Table         *_table;
  PhysicsEngine *_physics;
  GameRules     *_rules;
  NSImage       *_tableImage;
  NSTimer       *_timer;
  BOOL           _wasMoving;
}

+ (NSSize)preferredViewSize;
- (void)newGameWithType:(GameType)type;

@end
