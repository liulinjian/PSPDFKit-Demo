//
//  PSCVerticalAnnotationToolbar.m
//  PSPDFCatalog
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSCVerticalAnnotationToolbar.h"

@interface PSCVerticalAnnotationToolbar() <PSPDFAnnotationToolbarDelegate>
@property (nonatomic, strong) UIButton *drawButton;
@property (nonatomic, strong) UIButton *freeTextButton;
@property (nonatomic, strong) PSPDFAnnotationToolbar *toolbar;
@end

@implementation PSCVerticalAnnotationToolbar

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithPDFController:(PSPDFViewController *)pdfController {
    if ((self = [super init])) {
        _pdfController = pdfController;

        self.toolbar = self.pdfController.annotationButtonItem.annotationToolbar;
        self.toolbar.delegate = self;
        self.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.8f];

        // draw button
        if ([self.pdfController.document.editableAnnotationTypes containsObject:PSPDFAnnotationTypeStringInk]) {
            UIButton *drawButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *sketchImage = [UIImage imageNamed:@"PSPDFKit.bundle/sketch"];
            [drawButton setImage:sketchImage forState:UIControlStateNormal];
            [drawButton addTarget:self action:@selector(drawButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:drawButton];
            self.drawButton = drawButton;
        }

        // draw button
        if ([self.pdfController.document.editableAnnotationTypes containsObject:PSPDFAnnotationTypeStringFreeText]) {
        UIButton *freetextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *freeTextImage = [UIImage imageNamed:@"PSPDFKit.bundle/freetext"];
        [freetextButton setImage:freeTextImage forState:UIControlStateNormal];
        [freetextButton addTarget:self action:@selector(freeTextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:freetextButton];
        self.freeTextButton = freetextButton;
        }

    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect rem = self.bounds, slice;
    PSPDFRectDivideWithPadding(rem, &slice, &rem, 44.f, 0, CGRectMinYEdge);
    self.drawButton.frame = slice;
    self.freeTextButton.frame = rem;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Events

- (void)drawButtonPressed:(id)sender {
    if (self.toolbar.toolbarMode != PSPDFAnnotationToolbarDraw) {
        self.pdfController.HUDViewMode = PSPDFHUDViewAlways;
        if (!self.toolbar.window) {
            // match style
            self.toolbar.barStyle = self.pdfController.navigationBarStyle;
            self.toolbar.translucent = self.pdfController.isTransparentHUD;
            self.toolbar.tintColor = self.pdfController.tintColor;

            // add the toolbar to the view hierarchy for color picking etc
            if (self.pdfController.navigationController) {
                CGRect targetRect = self.pdfController.navigationController.navigationBar.frame;
                [self.pdfController.navigationController.view insertSubview:self.toolbar aboveSubview:self.pdfController.navigationController.navigationBar];
                [self.toolbar showToolbarInRect:targetRect animated:YES];
            }else {
                CGRect contentRect = self.pdfController.contentRect;
                CGRect targetRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, self.pdfController.view.bounds.size.width, PSPDFToolbarHeightForOrientation(self.pdfController.interfaceOrientation));
                [self.pdfController.view addSubview:self.toolbar];
                [self.toolbar showToolbarInRect:targetRect animated:YES];
            }
        }

        // call draw mode of the toolbar
        [self.toolbar drawButtonPressed:sender];
    }else {
        self.pdfController.HUDViewMode = PSPDFHUDViewAutomatic;
        // remove toolbar
        [self.toolbar unlockPDFControllerAnimated:YES showControls:YES ensureToStayOnTop:NO];
        [self.toolbar finishDrawingAnimated:YES andSaveAnnotation:NO];
    }
}

- (void)freeTextButtonPressed:(id)sender {
    [self.toolbar freeTextButtonPressed:sender];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFAnnotationToolbarDelegate

// Called after a mode change is set (button pressed; drawing finished, etc)
- (void)annotationToolbar:(PSPDFAnnotationToolbar *)annotationToolbar didChangeMode:(PSPDFAnnotationToolbarMode)newMode {
    if (newMode == PSPDFAnnotationToolbarNone && annotationToolbar.window) {
        // don't show all toolbar features, hide instead.
        [annotationToolbar hideToolbarAnimated:YES completion:^{
            [annotationToolbar removeFromSuperview];
        }];
    }

    // update button selection status
    self.drawButton.backgroundColor = newMode == PSPDFAnnotationToolbarDraw ? [UIColor whiteColor] : [UIColor clearColor];
    self.freeTextButton.backgroundColor = newMode == PSPDFAnnotationToolbarFreeText ? [UIColor whiteColor] : [UIColor clearColor];
}

@end
