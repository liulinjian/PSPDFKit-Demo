//
//  PSCBasicViewController.h
//  PSPDFCatalog
//
//  Copyright 2011-2013 Peter Steinberger. All rights reserved.
//

#define kDismissActivePopover @"kDismissActivePopover"

// Basic viewController subclass that handles popovers.
@interface PSCBasicViewController : PSPDFBaseViewController <UIPopoverControllerDelegate>

@property (nonatomic, strong) UIPopoverController *popoverController;

// Helper to close a modal view
- (void)closeModalView;

@end
