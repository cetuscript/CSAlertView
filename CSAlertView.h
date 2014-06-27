//
//  CSAlertView.h
//  Common/Utilities
//
//  Created by Mark Morrill on 2013/11/08.
//  Copyright (c) 2013 Cetuscript Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#define CSAlertViewNative   UIAlertView
#else
#define CSAlertViewNative   NSAlert
#endif

typedef void (^CSAlertView_Block)( CSAlertViewNative* alertView );

@interface CSAlertViewItem : NSObject
+ (CSAlertViewItem*) alertItem:(NSString*)item action:(CSAlertView_Block)action;

+ (CSAlertViewItem*) cancelItem;
+ (CSAlertViewItem*) cancelItemAction:(CSAlertView_Block)action;

+ (CSAlertViewItem*) okayItem;
+ (CSAlertViewItem*) okayItemAction:(CSAlertView_Block)action;

+ (CSAlertViewItem*) noItem;
+ (CSAlertViewItem*) noItemAction:(CSAlertView_Block)action;

+ (CSAlertViewItem*) yesItemAction:(CSAlertView_Block)action;

@end

@interface CSAlertView : NSObject

+ (CSAlertView*) alertWithTitle:(NSString *)title
                        message:(NSString *)message
                   cancelButton:(CSAlertViewItem*)cancelButton
                   otherButtons:(NSArray*)otherButtons;    // array of CSAlertViewItem

- (void) show;
- (void) showPre:(CSAlertView_Block)pre;
- (void) showPost:(CSAlertView_Block)post;
- (void) showPre:(CSAlertView_Block)pre     // called before show
            post:(CSAlertView_Block)post;   // called in clicked button, after processing the buttons.

@end
