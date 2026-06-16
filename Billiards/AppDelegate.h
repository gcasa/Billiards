//
//  AppDelegate.h
//  Billiards
//
//  Created by Gregory Casamento on 5/23/26.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class BilliardsView;
@class PreferencesController;

@interface AppDelegate : NSObject {
  NSWindow             *_window;
  BilliardsView        *_view;
  PreferencesController *_prefsController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)newGame:(id)sender;
- (void)showPreferences:(id)sender;
- (void)setupMainMenu;

@end
