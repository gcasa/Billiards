#import "SoundEffects.h"
#include <math.h>

static void AppendLE16(NSMutableData *data, uint16_t value) {
  uint8_t bytes[] = { value & 0xff, (value >> 8) & 0xff };
  [data appendBytes:bytes length:sizeof(bytes)];
}

static void AppendLE32(NSMutableData *data, uint32_t value) {
  uint8_t bytes[] = { value & 0xff, (value >> 8) & 0xff,
                      (value >> 16) & 0xff, (value >> 24) & 0xff };
  [data appendBytes:bytes length:sizeof(bytes)];
}

static NSSound *SoundWithTone(CGFloat frequency, CGFloat duration, BOOL noisy) {
  const uint32_t sampleRate = 22050;
  uint32_t sampleCount = (uint32_t)(duration * sampleRate);
  uint32_t dataSize = sampleCount * sizeof(int16_t);
  NSMutableData *wav = [NSMutableData data];

  [wav appendBytes:"RIFF" length:4]; AppendLE32(wav, 36 + dataSize);
  [wav appendBytes:"WAVEfmt " length:8]; AppendLE32(wav, 16);
  AppendLE16(wav, 1); AppendLE16(wav, 1); AppendLE32(wav, sampleRate);
  AppendLE32(wav, sampleRate * 2); AppendLE16(wav, 2); AppendLE16(wav, 16);
  [wav appendBytes:"data" length:4]; AppendLE32(wav, dataSize);

  uint32_t noiseState = 0x13579bdu;
  for (uint32_t i = 0; i < sampleCount; i++) {
    CGFloat t = (CGFloat)i / sampleRate;
    CGFloat envelope = exp(-t * (noisy ? 45.0 : 24.0));
    CGFloat sample = sin(2.0 * M_PI * frequency * t);
    if (noisy) {
      noiseState = noiseState * 1664525u + 1013904223u;
      CGFloat noise = ((noiseState >> 16) / 32768.0) - 1.0;
      sample = sample * 0.55 + noise * 0.45;
    }
    int16_t pcm = (int16_t)(sample * envelope * 26000.0);
    AppendLE16(wav, (uint16_t)pcm);
  }
  return [[NSSound alloc] initWithData:wav];
}

@implementation SoundEffects {
  NSSound *_cueHit;
  NSSound *_ballCollision;
  NSTimeInterval _lastCollisionTime;
}

+ (SoundEffects *)sharedEffects {
  static SoundEffects *effects = nil;
  if (!effects) effects = [[SoundEffects alloc] init];
  return effects;
}

- (id)init {
  self = [super init];
  if (self) {
    _cueHit = SoundWithTone(145.0, 0.11, NO);
    _ballCollision = SoundWithTone(720.0, 0.065, YES);
  }
  return self;
}

- (void)playCueHitWithPower:(CGFloat)power {
  [_cueHit setVolume:MIN(1.0, MAX(0.25, power / 140.0))];
  if ([_cueHit isPlaying]) [_cueHit stop];
  [_cueHit play];
}

- (void)playBallCollisionWithSpeed:(CGFloat)speed {
  if (speed < 18.0) return;
  NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
  if (now - _lastCollisionTime < 0.018) return;
  _lastCollisionTime = now;
  [_ballCollision setVolume:MIN(0.9, MAX(0.12, speed / 700.0))];
  if ([_ballCollision isPlaying]) [_ballCollision stop];
  [_ballCollision play];
}

@end
