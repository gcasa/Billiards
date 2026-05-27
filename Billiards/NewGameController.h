//
//  NewGameController.h
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.

#import <AppKit/AppKit.h>
#import "GameType.h"

@interface NewGameController : NSObject {
  NSPanel   *_panel;
  NSMatrix  *_radioMatrix;
  GameType   _selectedType;
  BOOL       _cancelled;
}

// Runs a modal game-selection dialog and returns the chosen type.
// Returns GameTypePool (default) if the user cancels.
- (GameType)runModal;

@end
