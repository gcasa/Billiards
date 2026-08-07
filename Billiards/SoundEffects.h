#import <AppKit/AppKit.h>

@interface SoundEffects : NSObject

+ (SoundEffects *)sharedEffects;
- (void)playCueHitWithPower:(CGFloat)power;
- (void)playBallCollisionWithSpeed:(CGFloat)speed;

@end
