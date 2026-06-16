//
//  PreferencesController.h
//  Billiards
//

#import <AppKit/AppKit.h>

extern NSString * const BilliardsTableColourDidChangeNotification;
extern NSString * const BilliardsTableColourDefaultsKey;

@interface PreferencesController : NSObject {
    NSPanel     *_panel;
    NSMatrix    *_colorMatrix;
    NSImageView *_previewImageView;
}

+ (PreferencesController *)sharedController;
- (void)showWindow:(id)sender;

@end
