//
//  PhysicsEngine.h
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class GameState;
@class Table;
@class Ball;

@interface PhysicsEngine : NSObject {
  CGFloat _friction;
  CGFloat _restitution;
  CGFloat _stopThreshold;
}

- (void)step:(CGFloat)dt state:(GameState *)state table:(Table *)table;

@end
