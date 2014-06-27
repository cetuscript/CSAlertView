//
//  CSAlertView.m
//  Common/Utilities
//
//  Created by Mark Morrill on 2013/11/08.
//  Copyright (c) 2013 Cetuscript Systems. All rights reserved.
//

#import "CSAlertView.h"

static NSMutableSet* CSAlertView_Alerts = nil;

@interface CSAlertViewItem ()
@property (nonatomic, strong) NSString*         item;
@property (nonatomic, copy) CSAlertView_Block   action;

- (id) initWithItem:(NSString*)item action:(CSAlertView_Block)action;
@end

@implementation CSAlertViewItem

+ (CSAlertViewItem *)alertItem:(NSString *)item action:(CSAlertView_Block)action
{
    return [[self alloc]initWithItem:item action:action];
}

+ (CSAlertViewItem*) cancelItem
{
    return [self cancelItemAction:NULL];
}

+ (CSAlertViewItem*) cancelItemAction:(CSAlertView_Block)action
{
    return [CSAlertViewItem alertItem:NSLocalizedString(@"Cancel", nil)
                               action:action];
}

+ (CSAlertViewItem *)okayItem
{
    return [self okayItemAction:NULL];
}

+ (CSAlertViewItem*) okayItemAction:(CSAlertView_Block)action
{
    return [CSAlertViewItem alertItem:NSLocalizedString(@"OK", nil)
                               action:action];
}

+ (CSAlertViewItem*) noItem
{
    return [self noItemAction:NULL];
}

+ (CSAlertViewItem*) noItemAction:(CSAlertView_Block)action
{
    return [CSAlertViewItem alertItem:NSLocalizedString(@"No", nil)
                               action:action];
}


+ (CSAlertViewItem*) yesItemAction:(CSAlertView_Block)action
{
    return [CSAlertViewItem alertItem:NSLocalizedString(@"Yes", nil)
                               action:action];
}

- (id)initWithItem:(NSString *)item action:(CSAlertView_Block)action
{
    self = [super init];
    
    if( self )
    {
        self.item = item;
        self.action = action;
    }
    
    return self;
}

@end

#if TARGET_OS_IPHONE
@interface CSAlertView ()
<UIAlertViewDelegate>
@property (nonatomic, copy) CSAlertView_Block   postAction;
@property (nonatomic, strong) UIAlertView*      alertView;
@property (nonatomic, strong) CSAlertViewItem*  cancelButton;
@property (nonatomic, strong) NSArray*          otherButtons;

- (id) initWithTitle:(NSString *)title
             message:(NSString *)message
        cancelButton:(CSAlertViewItem*)cancelButton
        otherButtons:(NSArray*)otherButtons;    // array of CSAlertViewItem

@end

@implementation CSAlertView

+ (NSMutableSet*) globalAlerts
{
    if( nil == CSAlertView_Alerts )
        CSAlertView_Alerts = [NSMutableSet setWithCapacity:5];
    return CSAlertView_Alerts;
}

+ (void) addToGlobalAlerts:(CSAlertView*)alert
{
    [[self globalAlerts] addObject:alert];
}

+ (void) removeFromGlobalAlerts:(CSAlertView*)alert
{
    [[self globalAlerts] removeObject:alert];
}

+ (CSAlertView*) alertWithTitle:(NSString *)title
                        message:(NSString *)message
                   cancelButton:(CSAlertViewItem*)cancelButton
                   otherButtons:(NSArray*)otherButtons    // array of CSAlertViewItem
{
    return [[self alloc]initWithTitle:title
                              message:message
                         cancelButton:cancelButton
                         otherButtons:otherButtons];
}

- (id) initWithTitle:(NSString *)title
             message:(NSString *)message
        cancelButton:(CSAlertViewItem*)cancelButton
        otherButtons:(NSArray*)otherButtons    // array of CSAlertViewItem
{
    self = [super init];
    if( self )
    {
        self.cancelButton = cancelButton;
        self.otherButtons = otherButtons;
        
        self.alertView = [[UIAlertView alloc]initWithTitle:title
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:cancelButton.item
                                         otherButtonTitles:nil];
        
        for( CSAlertViewItem* item in self.otherButtons ) {
            [self.alertView addButtonWithTitle:item.item];
        }
        
        [self.class addToGlobalAlerts:self];
    }
    return self;
}

- (void) show
{
    [self showPre:NULL post:NULL];
}

- (void) showPre:(CSAlertView_Block)pre
{
    [self showPre:pre post:NULL];
}

- (void) showPost:(CSAlertView_Block)post
{
    [self showPre:NULL post:post];
}

- (void) showPre:(CSAlertView_Block)pre post:(CSAlertView_Block)post
{
    self.postAction = post;
    if( pre )
        pre( self.alertView );
    [self.alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSParameterAssert( self.alertView == alertView );

    if( buttonIndex == alertView.cancelButtonIndex )
    {
        if( self.cancelButton.action )
            self.cancelButton.action( self.alertView );
    }
    else
    {
        if( alertView.cancelButtonIndex >= 0 )
            buttonIndex -= 1;
        
        if( (buttonIndex >= 0) && (buttonIndex < self.otherButtons.count) )
        {
            CSAlertViewItem*    item = [self.otherButtons objectAtIndex:buttonIndex];
            if( item.action )
                item.action( self.alertView );
        }
    }

    if( self.postAction )
        self.postAction( self.alertView );

    [self.class removeFromGlobalAlerts:self];
}



@end
#else
@interface CSAlertView()
@property (nonatomic, strong) CSAlertViewItem*  defaultItem;
@property (nonatomic, strong) CSAlertViewItem*  alternateItem;
@property (nonatomic, strong) CSAlertViewItem*  otherItem;
@property (nonatomic, strong) NSString*         title;
@property (nonatomic, strong) NSString*         message;

@end

@implementation CSAlertView

+ (CSAlertView*) alertWithTitle:(NSString *)title
                        message:(NSString *)message
                   cancelButton:(CSAlertViewItem*)cancelButton
                   otherButtons:(NSArray*)otherButtons    // array of CSAlertViewItem
{
    CSAlertView*    alert = [CSAlertView new];
    
    alert.title = title;
    alert.message = message ? message : @"";
    
    alert.defaultItem = cancelButton;
    if( otherButtons.count > 0 )
    {
        alert.alternateItem = [otherButtons objectAtIndex:0];
        if( otherButtons.count > 1 )
            alert.otherItem = [otherButtons objectAtIndex:1];
    }
    
    return alert;
}

- (void) show
{
    [self showPre:nil
             post:nil];
}

- (void) showPre:(CSAlertView_Block)pre
{
    [self showPre:pre
             post:nil];
}

- (void) showPost:(CSAlertView_Block)post
{
    [self showPre:nil
             post:post];
}

- (void) showPre:(CSAlertView_Block)pre     // called before show
            post:(CSAlertView_Block)post   // called in clicked button, after processing the buttons.
{
    NSAlert*    alert = [NSAlert alertWithMessageText:self.title
                                        defaultButton:self.defaultItem.item
                                      alternateButton:self.alternateItem.item
                                          otherButton:self.otherItem.item
                            informativeTextWithFormat:@"%@", self.message];
    
    if( pre )
        pre( alert );
    
    NSInteger response = alert.runModal;
    
    switch (response) {
        case NSAlertDefaultReturn:
            if( self.defaultItem.action )
                self.defaultItem.action( alert );
            break;
            
        case NSAlertAlternateReturn:
            if( self.alternateItem.action )
                self.alternateItem.action( alert );
            break;
            
        case NSAlertOtherReturn:
            if( self.otherItem.action )
                self.otherItem.action( alert );
            break;
            
        default:
            // nothing
            break;
    }
    
    if( post )
        post( alert );
}

@end
#endif
