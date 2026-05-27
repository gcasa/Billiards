//
//  GameRules.h
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.

#import <Foundation/Foundation.h>
#import "GameType.h"

@class GameState;
@class Table;

@interface GameRules : NSObject

- (void)beginNewRack:(GameState *)state table:(Table *)table;
- (void)shotEnded:(GameState *)state table:(Table *)table;
- (BOOL)isGameOver:(GameState *)state;

@end
