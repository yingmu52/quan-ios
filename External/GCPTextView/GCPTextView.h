//
//  GCPTextView.h
//  GCPTextView
//
//  Created by Max on 9/27/13.
//  Copyright (c) 2013 Emotz. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.



// VERSION 0.3

#import <UIKit/UIKit.h>

@class GCPTextView;

///-------------------------------------
/// @name GCPTextViewDelegate
///-------------------------------------

/**
 `GCPTextViewDelegate` is an optional delegate for the view
 */
@protocol  GCPTextViewDelegate <UITextViewDelegate>

/**
 Sent to delegate when user hits backspace when no text has been entered
 */
- (void)backspaceDidOccurInEmptyField;

/**
 Sent to delegate when the height of the content changed
 */
- (void)textView:(GCPTextView *)textView contentHeightDidChange:(CGFloat)height;

@end

///-------------------------------------
/// @name GCPTextView
///-------------------------------------

/**
 `GCPTextView` is a subclass of UITextView that adds placeholder support
 */
@interface GCPTextView : UITextView

/**
The view's delegate
 */
//- (void)setDelegate:(id<GCPTextViewDelegate>)delegate;

/**
 The placeholder text
 */
- (void)setPlaceholder:(NSString *)placeholder;

/**
 The placeholder text color.  This defaults to a light grey if not set.
 */
- (void)setPlaceholderColor:(UIColor *)color;

/**
 Maximum length of string.  Defaults to no maximum
 */
- (void)setMaximumStringLength:(NSInteger)maximumStringLength;

/**
 If the maximum length of a string is set, setting this to TRUE will display the number of characters remaining
 */
@property BOOL showNumberOfAllowedCharacters;

/**
 If placeholder is visible (i.e., no text has been entered)
 */
- (BOOL)placeholderIsVisible;


- (void)setMinimumContentHeight:(CGFloat)height;

/**
 Height of content given current width
 */
- (CGFloat)contentHeight;

/**
 Recalculate content height
 */
- (void)updateContentHeight;


@end
