//
//  NewGameController.m
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.

#import "NewGameController.h"

@implementation NewGameController

- (GameType)runModal {
  _selectedType = GameTypePool;
  _cancelled    = NO;

  _panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 300, 240)
                                      styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                        backing:NSBackingStoreBuffered
                                          defer:NO];
  [_panel setTitle:@"New Game"];

  NSView *content = [_panel contentView];

  // Label
  NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 195, 260, 22)];
  [label setStringValue:@"Select Game Type:"];
  [label setBezeled:NO];
  [label setDrawsBackground:NO];
  [label setEditable:NO];
  [label setSelectable:NO];
  [label setFont:[NSFont boldSystemFontOfSize:13.0]];
  [content addSubview:label];

  // Radio matrix
  NSButtonCell *proto = [[NSButtonCell alloc] init];
  [proto setButtonType:NSRadioButton];

  _radioMatrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(20, 65, 260, 125)
                                            mode:NSRadioModeMatrix
                                       prototype:proto
                                    numberOfRows:4
                                 numberOfColumns:1];
  [_radioMatrix setCellSize:NSMakeSize(260, 24)];
  [_radioMatrix setIntercellSpacing:NSMakeSize(0, 7)];

  [[_radioMatrix cellAtRow:0 column:0] setTitle:@"Billiards"];
  [[_radioMatrix cellAtRow:1 column:0] setTitle:@"Pool (8-ball)"];
  [[_radioMatrix cellAtRow:2 column:0] setTitle:@"Pool (9-ball)"];
  [[_radioMatrix cellAtRow:3 column:0] setTitle:@"Snooker"];

  [_radioMatrix selectCellAtRow:1 column:0]; // default Pool
  [content addSubview:_radioMatrix];

  // Cancel button
  NSButton *cancelBtn = [[NSButton alloc] initWithFrame:NSMakeRect(20, 18, 110, 32)];
  [cancelBtn setTitle:@"Cancel"];
  [cancelBtn setTarget:self];
  [cancelBtn setAction:@selector(cancel:)];
  [cancelBtn setKeyEquivalent:@"\033"];
  [content addSubview:cancelBtn];

  // Start button
  NSButton *startBtn = [[NSButton alloc] initWithFrame:NSMakeRect(168, 18, 112, 32)];
  [startBtn setTitle:@"Start Game"];
  [startBtn setTarget:self];
  [startBtn setAction:@selector(startGame:)];
  [startBtn setKeyEquivalent:@"\r"];
  [content addSubview:startBtn];

  [_panel center];
  [NSApp runModalForWindow:_panel];

  return _cancelled ? GameTypePool : _selectedType;
}

- (void)startGame:(id)sender {
  _selectedType = (GameType)[_radioMatrix selectedRow];
  [NSApp stopModal];
  [_panel orderOut:nil];
}

- (void)cancel:(id)sender {
  _cancelled = YES;
  [NSApp stopModal];
  [_panel orderOut:nil];
}

@end
