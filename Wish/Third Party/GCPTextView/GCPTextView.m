//
//  GCPTextView.m
//  GCPTextView
//
//  Created by Max on 9/27/13.
//  Copyright (c) 2013 Emotz. All rights reserved.
//

// VERSION 0.3


#import <QuartzCore/QuartzCore.h>
#import "GCPTextView.h"

const NSInteger kGCPNoMaximumStringLength = -1;

@implementation GCPTextView {

    NSString *_placeholder;
    UIColor *_placeholderColor;
    CATextLayer *_placeholderLayer;
    
    CATextLayer *_cursorExtensionLayer;
    NSInteger _maximumStringLength;
    
    CGFloat _minimumContentHeight;
    CGFloat _contentHeight;
    
    id <GCPTextViewDelegate> _otherDelegate;
}


- (void)setup {
    
    [super setDelegate: (id <UITextViewDelegate>) self];
    _contentHeight = 0;
    [self setMinimumContentHeight:0];
    [self setMaximumStringLength:kGCPNoMaximumStringLength];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setup];
    }
    
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    
    [super layoutSublayersOfLayer:layer];
    [self updatePlaceholderLayer:NO];
}


#pragma mark - Placeholder

- (void)setPlaceholder:(NSString *)placeholder {

    _placeholder = [NSString stringWithString:placeholder];
    [self updatePlaceholderLayer:YES];
}

- (NSString *)placeholder {
    
    return _placeholder;
}

- (void)setPlaceholderColor:(UIColor *)color {
    
    _placeholderColor = color;
    [self updatePlaceholderLayer:YES];
}

- (UIColor *)placeholderColor {
    
    if (_placeholderColor)
        return _placeholderColor;
    
    return [UIColor colorWithWhite:0.7 alpha:1.0];
}

- (void)showPlaceholder {

    [self updatePlaceholderLayer:NO];
    [[self placeholderLayer] setHidden:NO];
}

- (void)hidePlaceholder {
  
    [[self placeholderLayer] setHidden:YES];
}

- (BOOL)placeholderIsVisible {
  
    return [[self placeholderLayer] isHidden] == NO;
}

- (CATextLayer *)placeholderLayer {
    
    if (_placeholderLayer)
        return _placeholderLayer;
    
    [_placeholderLayer setBackgroundColor:[[UIColor grayColor] CGColor]];
    
    _placeholderLayer = [CATextLayer layer];
    [_placeholderLayer setContentsScale:[[UIScreen mainScreen] scale]];
    
    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)[self font].fontName);
    [_placeholderLayer  setFont:cgFont];
    CFRelease(cgFont);
    [_placeholderLayer setFontSize:[[self font] pointSize]];
    [_placeholderLayer setForegroundColor:[[self placeholderColor] CGColor]];
    [_placeholderLayer setString:[self placeholder]];
    
    
    switch ([self textAlignment]) {
            
        case NSTextAlignmentCenter:
            
            [[self placeholderLayer]  setAlignmentMode:kCAAlignmentCenter];
            break;
            
        case NSTextAlignmentJustified:
            
            [[self placeholderLayer]  setAlignmentMode:kCAAlignmentJustified];
            break;
            
        case NSTextAlignmentRight:
            
            [[self placeholderLayer]  setAlignmentMode:kCAAlignmentRight];
            break;
            
        case NSTextAlignmentNatural:
            
            [[self placeholderLayer]  setAlignmentMode:kCAAlignmentNatural];
            break;
            
        default:
            [[self placeholderLayer]  setAlignmentMode:kCAAlignmentLeft];
            break;
    }
    
    [self.layer addSublayer:_placeholderLayer];
    
    return _placeholderLayer;
}

- (void)updatePlaceholderLayer:(BOOL)completeUpdate {
    
    if ([self placeholder] == nil) {

        [[self placeholderLayer] setString:@""];
        return;
    }

    if (completeUpdate) {
        
        [_placeholderLayer removeFromSuperlayer];
        _placeholderLayer = nil;
    }
    
    CGRect caretRect = [self caretRectForPosition:[self beginningOfDocument]];
    CGFloat yPos = floorf(caretRect.origin.y) + 1;
    CGFloat height = self.frame.size.height;
    CGFloat xPos;
    CGFloat width;
    
    if (self.textAlignment == NSTextAlignmentRight) {
        
        xPos = 0;
        width = floorf(self.frame.size.width - caretRect.size.width) - self.textContainerInset.right - 2;
    }
    else {
        
        xPos = floorf(caretRect.origin.x + caretRect.size.width) + self.textContainerInset.left;
        width = self.frame.size.width;
    }
    
    [[self placeholderLayer] setFrame:CGRectMake(xPos, yPos, width, height)];
}


#pragma mark -
#pragma mark Cursor Extension

+ (CGFontRef)cursorExtensionAlertFontRef {
    
    static CGFontRef _cursorExtensionAlertFontRef;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _cursorExtensionAlertFontRef = CGFontCreateWithFontName((CFStringRef)@"HelveticaNeue-Bold");
    });
    
    return _cursorExtensionAlertFontRef;
}

+ (CGFontRef)cursorExtensionFontRef {
    
    static CGFontRef _cursorExtensionFontRef;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _cursorExtensionFontRef = CGFontCreateWithFontName((CFStringRef)@"HelveticaNeue");
    });
    
    return _cursorExtensionFontRef;
}

- (CATextLayer *)cursorExtensionLayer {
    
    if (_cursorExtensionLayer)
        return _cursorExtensionLayer;
    
    _cursorExtensionLayer = [CATextLayer layer];
    [_cursorExtensionLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [_cursorExtensionLayer setFontSize:10];
    [_cursorExtensionLayer  setAlignmentMode:kCAAlignmentLeft];
    
    [self.layer addSublayer:_cursorExtensionLayer];
    
    return _cursorExtensionLayer;
}

- (void)updateCursorExtensionLayerWithString:(NSString *)string alert:(BOOL)alert {
    
    // move frame to end of document
    CGRect caretRect = [self caretRectForPosition:[self endOfDocument]];
    CGRect rectForText = [[self cursorExtensionLayer] frame];
    rectForText.origin.y = floorf(caretRect.origin.y) + 1;
    rectForText.origin.x = ceilf(caretRect.origin.x) + ceilf(caretRect.size.width) + 2;
    
    if (self.textAlignment != NSTextAlignmentRight)
        rectForText.origin.x += 6;
    
    [[self cursorExtensionLayer] setFrame:rectForText];
    
    // set string and font
    [[self cursorExtensionLayer] setString:string];
    
    if (alert) {
        
        [[self cursorExtensionLayer] setFont:[self.class cursorExtensionAlertFontRef]];
        UIColor *foregroundColor = [[UIColor redColor] colorWithAlphaComponent:1.0];
        [[self cursorExtensionLayer] setForegroundColor:[foregroundColor CGColor]];
    }
    else {
        
        [[self cursorExtensionLayer] setFont:[self.class cursorExtensionFontRef]];
        UIColor *foregroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        [[self cursorExtensionLayer] setForegroundColor:[foregroundColor CGColor]];
    }
    
    [[self cursorExtensionLayer] setHidden:NO];
}


#pragma mark - String Length

- (BOOL)limitStringLength {
    
    return [self maximumStringLength] != kGCPNoMaximumStringLength;
}

- (void)setMaximumStringLength:(NSInteger)maximumStringLength {
    
    _maximumStringLength = maximumStringLength;
    
    if (_maximumStringLength <= 0) {
        
        // return edge insets to normal
        UIEdgeInsets insets = self.textContainerInset;
        insets.right = insets.left = 0;
        [self setTextContainerInset:insets];
        
        return;
    }
    
    _maximumStringLength = maximumStringLength;
    
    // calculate layer size based on length
    
    NSString *dummyStringForSizeDetermination;
    if (_maximumStringLength < 10) {
        
        dummyStringForSizeDetermination = @"8";
    }
    else if (_maximumStringLength < 100) {
        
        dummyStringForSizeDetermination = @"88";
    }
    else if (_maximumStringLength < 1000) {
        
        dummyStringForSizeDetermination = @"888";
    }
    else {
        
        dummyStringForSizeDetermination = @"8888";
    }
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"HelveticaNeue" size:10] forKey:NSFontAttributeName];
    CGSize sizeOfLayer = [dummyStringForSizeDetermination sizeWithAttributes:attributes];
    
    // set layer size
    [[self cursorExtensionLayer] setFrame:CGRectMake(0, 0, ceilf(sizeOfLayer.width), ceilf(sizeOfLayer.height))];
    
    // adjust content width inset to accomodate cursor extension
    UIEdgeInsets insets = self.textContainerInset;
    insets.right = sizeOfLayer.width + 2;
    [self setTextContainerInset:insets];
}

- (NSUInteger)maximumStringLength {
    
    return _maximumStringLength;
}


#pragma mark - Content Height

- (void)updateContentHeight {
    
    CGFloat height = MAX(ceil([self sizeThatFits:self.frame.size].height), [self minimumContentHeight]);
    if (height != _contentHeight) {
        
        _contentHeight = height;
        
        if ([_otherDelegate respondsToSelector:@selector(textView:contentHeightDidChange:)]) {
            
            [_otherDelegate textView:self contentHeightDidChange:_contentHeight];
        }
    }
}

- (void)setMinimumContentHeight:(CGFloat)height {
    
    _minimumContentHeight = height;
    [self updateContentHeight];
}

- (CGFloat)minimumContentHeight {
    
    return _minimumContentHeight;
}

- (CGFloat)contentHeight {
    
    return _contentHeight;
}


#pragma mark -
#pragma mark Overridden TextView Methods

- (void)setDelegate:(id<GCPTextViewDelegate>)delegate {
    
    _otherDelegate = delegate;
}

- (void)setText:(NSString *)text {
    
    if ([text length] == 0) {
        
        [self showPlaceholder];
        [[self cursorExtensionLayer] setHidden:YES];
    }
    else
        [self hidePlaceholder];
    
    [super setText:text];
    [self updateContentHeight];
}

- (void)setFont:(UIFont *)font {
    
    [super setFont:font];
    [self updatePlaceholderLayer:YES];
    [self updateContentHeight];
}


#pragma mark - TextView Delegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    [self updateCursorExtensionLayerWithString:@"" alert:NO];
    
    if (!_otherDelegate)
        return YES;
    
    if ([_otherDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
        return [_otherDelegate textViewShouldBeginEditing:textView];
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if (!_otherDelegate)
        return;
    
    if ([_otherDelegate respondsToSelector:@selector(textViewDidBeginEditing:)])
        [_otherDelegate textViewDidBeginEditing:textView];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if ([textView.text length] == 0) {
        
        [[self cursorExtensionLayer] setHidden:YES];
        [self showPlaceholder];
    }
    else {
        
        [self hidePlaceholder];
        
        if (self.showNumberOfAllowedCharacters && (self.maximumStringLength != kGCPNoMaximumStringLength)) {
            
            [[self cursorExtensionLayer] setHidden:NO];
            NSInteger characterCount = [self maximumStringLength] - [self.text length];
            NSString *characterCountString = [NSString stringWithFormat:@"%ld", (long)characterCount];
            [self updateCursorExtensionLayerWithString:characterCountString alert:characterCount == 0];
        }
    }
    
    [self updateContentHeight];
    
    if (!_otherDelegate)
        return;
    
    if ([_otherDelegate respondsToSelector:@selector(textViewDidChange:)])
        [_otherDelegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    if (!_otherDelegate)
        return;
    
    if ([_otherDelegate respondsToSelector:@selector(textViewDidChangeSelection:)])
        [_otherDelegate textViewDidChangeSelection:textView];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    if (!_otherDelegate)
        return YES;
    
    if ([_otherDelegate respondsToSelector:@selector(textViewShouldEndEditing:)])
        return [_otherDelegate textViewShouldEndEditing:textView];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if (!_otherDelegate)
        return;
    
    if ([_otherDelegate respondsToSelector:@selector(textViewDidEndEditing:)])
        [_otherDelegate textViewDidEndEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    BOOL otherDelegateResult = YES;
    if (_otherDelegate) {
        
        if ([_otherDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
            otherDelegateResult = [_otherDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    
    if (otherDelegateResult == NO)
        return NO;
    
    NSInteger textLength = [text length];
    if (textLength > 0) {
        
        if ([self placeholderIsVisible])
            [self hidePlaceholder];
        
        if ([self limitStringLength]) {
            
            NSInteger numberOfCharactersInserted = textLength - range.length;
            if ((self.text.length + numberOfCharactersInserted) > self.maximumStringLength)
                return NO;
        }
    }
    else if ((textLength == 0) && (range.location == 0)) {
        
        if ([self placeholderIsVisible]) {
            
            [_otherDelegate backspaceDidOccurInEmptyField];
        }
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    
    if (!_otherDelegate)
        return YES;
    
    if ([_otherDelegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)])
        return [_otherDelegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if (!_otherDelegate)
        return YES;
    
    if ([_otherDelegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)])
        return [_otherDelegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
    
    return YES;
}

@end
