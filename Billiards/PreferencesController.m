//
//  PreferencesController.m
//  Billiards
//

#import "PreferencesController.h"

NSString * const BilliardsTableColourDidChangeNotification = @"BilliardsTableColourDidChange";
NSString * const BilliardsTableColourDefaultsKey           = @"BilliardsTableColour";

static NSArray *_imageNames(void) {
    return @[@"billiard_table_black",
             @"billiard_table_blue",
             @"billiard_table",
             @"billiard_table_red",
             @"billiard_table_white"];
}

static PreferencesController *_sharedController = nil;

@implementation PreferencesController

+ (PreferencesController *)sharedController {
    if (!_sharedController)
        _sharedController = [[self alloc] init];
    return _sharedController;
}

- (void)showWindow:(id)sender {
    if (_panel) {
        [_panel makeKeyAndOrderFront:nil];
        return;
    }

    _panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 300, 450)
                                        styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                          backing:NSBackingStoreBuffered
                                            defer:NO];
    [_panel setTitle:@"Preferences"];

    NSView *content = [_panel contentView];

    // "Table Colour:" label
    NSTextField *colourLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 408, 260, 22)];
    [colourLabel setStringValue:@"Table Colour:"];
    [colourLabel setBezeled:NO];
    [colourLabel setDrawsBackground:NO];
    [colourLabel setEditable:NO];
    [colourLabel setSelectable:NO];
    [colourLabel setFont:[NSFont boldSystemFontOfSize:13.0]];
    [content addSubview:colourLabel];

    // Radio button matrix — 5 rows, same pattern as NewGameController
    NSButtonCell *proto = [[NSButtonCell alloc] init];
    [proto setButtonType:NSRadioButton];

    _colorMatrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(30, 253, 240, 148)
                                              mode:NSRadioModeMatrix
                                         prototype:proto
                                      numberOfRows:5
                                   numberOfColumns:1];
    [_colorMatrix setCellSize:NSMakeSize(240, 24)];
    [_colorMatrix setIntercellSpacing:NSMakeSize(0, 5)];
    [[_colorMatrix cellAtRow:0 column:0] setTitle:@"Black"];
    [[_colorMatrix cellAtRow:1 column:0] setTitle:@"Blue"];
    [[_colorMatrix cellAtRow:2 column:0] setTitle:@"Green"];
    [[_colorMatrix cellAtRow:3 column:0] setTitle:@"Red"];
    [[_colorMatrix cellAtRow:4 column:0] setTitle:@"White"];

    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:BilliardsTableColourDefaultsKey];
    if (!saved) saved = @"billiard_table";
    NSInteger row = [_imageNames() indexOfObject:saved];
    if (row == NSNotFound) row = 2;
    [_colorMatrix selectCellAtRow:row column:0];

    [_colorMatrix setTarget:self];
    [_colorMatrix setAction:@selector(colourMatrixChanged:)];
    [content addSubview:_colorMatrix];

    // "Preview:" label
    NSTextField *previewLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 227, 260, 18)];
    [previewLabel setStringValue:@"Preview:"];
    [previewLabel setBezeled:NO];
    [previewLabel setDrawsBackground:NO];
    [previewLabel setEditable:NO];
    [previewLabel setSelectable:NO];
    [content addSubview:previewLabel];

    // Preview image view (table aspect ratio 1438:889 ≈ 1.62; at 260px wide → ~161px tall)
    _previewImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(20, 58, 260, 162)];
    [_previewImageView setImageScaling:NSScaleProportionally];
    [_previewImageView setImage:[NSImage imageNamed:saved]];
    [content addSubview:_previewImageView];

    // Close button
    NSButton *closeBtn = [[NSButton alloc] initWithFrame:NSMakeRect(180, 14, 100, 32)];
    [closeBtn setTitle:@"Close"];
    [closeBtn setTarget:_panel];
    [closeBtn setAction:@selector(orderOut:)];
    [closeBtn setKeyEquivalent:@"\r"];
    [content addSubview:closeBtn];

    [_panel center];
    [_panel makeKeyAndOrderFront:nil];
}

- (void)colourMatrixChanged:(id)sender {
    NSInteger row       = [_colorMatrix selectedRow];
    NSString *imageName = _imageNames()[row];

    [[NSUserDefaults standardUserDefaults] setObject:imageName forKey:BilliardsTableColourDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [_previewImageView setImage:[NSImage imageNamed:imageName]];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:BilliardsTableColourDidChangeNotification
                      object:self
                    userInfo:@{@"imageName": imageName}];
}

@end
