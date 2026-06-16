//
//  AppDelegate.m
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26. Enhanced by James Carthew on 5/27/26.

#import "AppDelegate.h"
#import "BilliardsView.h"
#import "NewGameController.h"
#import "PreferencesController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  [self setupMainMenu];

  NSSize viewSize = [BilliardsView preferredViewSize];
  NSRect frame    = NSMakeRect(100, 100, viewSize.width, viewSize.height);

  _window = [[NSWindow alloc] initWithContentRect:frame
                                        styleMask:(NSTitledWindowMask    |
                                                   NSClosableWindowMask  |
                                                   NSMiniaturizableWindowMask)
                                          backing:NSBackingStoreBuffered
                                            defer:NO];

  [_window setTitle:@"Billiards"];
  [[_window standardWindowButton:NSWindowZoomButton] setEnabled:NO];

  _view = [[BilliardsView alloc] initWithFrame:NSMakeRect(0, 0, viewSize.width, viewSize.height)];
  [_window setContentView:_view];
  [_window makeKeyAndOrderFront:nil];

  // Show game-selection dialog on launch
  [self newGame:nil];
}

- (void)setupMainMenu {
#ifdef GNUSTEP
  NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"Billiards"];
  [mainMenu setTitle:@"Billiards"];

  NSMenuItem *appMenuItem = [[NSMenuItem alloc] initWithTitle:@"Billiards"
                                                       action:nil
                                                keyEquivalent:@""];
  [mainMenu addItem:appMenuItem];

  NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"Billiards"];
  [appMenu setTitle:@"Billiards"];

  NSMenuItem *newGameItem = [[NSMenuItem alloc] initWithTitle:@"New Game"
                                                       action:@selector(newGame:)
                                                keyEquivalent:@"n"];
  [newGameItem setTarget:self];
  [appMenu addItem:newGameItem];

  [appMenu addItem:[NSMenuItem separatorItem]];

  NSMenuItem *prefsItem = [[NSMenuItem alloc] initWithTitle:@"Preferences…"
                                                     action:@selector(showPreferences:)
                                              keyEquivalent:@""];
  [prefsItem setTarget:self];
  [appMenu addItem:prefsItem];

  [appMenu addItem:[NSMenuItem separatorItem]];

  NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit Billiards"
                                                    action:@selector(terminate:)
                                             keyEquivalent:@"q"];
  [quitItem setTarget:NSApp];
  [appMenu addItem:quitItem];

  [mainMenu setSubmenu:appMenu forItem:appMenuItem];
  [NSApp setMainMenu:mainMenu];
#else
  NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@""];

  NSMenuItem *appMenuItem = [[NSMenuItem alloc] initWithTitle:@""
                                                       action:nil
                                                keyEquivalent:@""];
  [mainMenu addItem:appMenuItem];

  NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"Billiards"];

  NSMenuItem *newGameItem = [[NSMenuItem alloc] initWithTitle:@"New Game"
                                                       action:@selector(newGame:)
                                                keyEquivalent:@"n"];
  [newGameItem setTarget:self];
  [appMenu addItem:newGameItem];

  [appMenu addItem:[NSMenuItem separatorItem]];

  NSMenuItem *prefsItem2 = [[NSMenuItem alloc] initWithTitle:@"Preferences…"
                                                      action:@selector(showPreferences:)
                                               keyEquivalent:@""];
  [prefsItem2 setTarget:self];
  [appMenu addItem:prefsItem2];

  [appMenu addItem:[NSMenuItem separatorItem]];

  NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit Billiards"
                                                    action:@selector(terminate:)
                                             keyEquivalent:@"q"];
  [quitItem setTarget:NSApp];
  [appMenu addItem:quitItem];

  [mainMenu setSubmenu:appMenu forItem:appMenuItem];
  [NSApp setMainMenu:mainMenu];
#endif
}

- (void)newGame:(id)sender {
  NewGameController *controller = [[NewGameController alloc] init];
  GameType type = [controller runModal];
  [_view newGameWithType:type];
}

- (void)showPreferences:(id)sender {
  [[PreferencesController sharedController] showWindow:nil];
}

@end
