/*
 * SCPinView
 * Protected MIT License
 *
 * Copyright (c) 2018 Georgiy Cheremnikh.
 * All rights reserved.
 */

#import "SCPinView.h"

@interface SCPinView ()

// Visual input circles. Initialized at startup.
// In the case of the set length, the system re-initialization.
@property (strong, nonatomic) NSArray<UIView *> *items;

@end

@implementation SCPinView

- (instancetype)initWithFrame:(CGRect)frame {
	// Standard constructor. Initializes and sets default values.
	if (self = [super initWithFrame:frame]) {
		[self setDefaultValues];
	}
	return self;
}

#pragma mark - NSCoder

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	// Standard constructor. Initializes and sets default values.
	if (self = [super initWithCoder:aDecoder]) {
		[self setDefaultValues];
		
		// Getting values from the encoder.
		NSUInteger lenght 		= [aDecoder decodeIntegerForKey:@"lenght"];
		UIColor *fillColor		= [aDecoder decodeObjectForKey:@"fillColor"];
		UIColor *strokeColor	= [aDecoder decodeObjectForKey:@"strokeColor"];
		
		// Settings of the received values.
		[self setLenght:lenght];
		[self setFillColor:fillColor];
		[self setStrokeColor:strokeColor];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	// Encode basic values for later playback.
	[aCoder encodeInteger:_lenght forKey:@"lenght"];
	[aCoder encodeObject:_fillColor forKey:@"fillColor"];
	[aCoder encodeObject:_strokeColor forKey:@"strokeColor"];
}

- (void)setDefaultValues {
	// Set default values.
	_lenght = 4;
	_text 	= @"";
	
	// Fill colors and borders.
	_fillColor		= [UIColor blackColor];
	_strokeColor 	= [UIColor blackColor];
	
	// Initialize circles visual input.
	[self initPinItems];
}

- (void)setLenght:(NSUInteger)lenght {
	// Sets the length and forces a redraw.
	_lenght = lenght ?: 4;
	[self ravageAll:NO];
	[self initPinItems];
	[self setNeedsDisplay];
}

- (void)setFillColor:(UIColor *)fillColor {
	// Sets and applies the fill color to all circles if it is not zero.
	if (fillColor) {
		_fillColor = fillColor;
		for (UIView *item in _items) {
			if (item.layer.backgroundColor)
				item.layer.backgroundColor = fillColor.CGColor;
		}
	}
}

- (void)setStrokeColor:(UIColor *)strokeColor {
	// Sets and applies the border color to all circles if it is not zero.
	if (strokeColor) {
		_strokeColor = strokeColor;
		for (UIView *item in _items) {
			item.layer.borderColor = strokeColor.CGColor;
		}
	}
}

- (void)initPinItems {
	// If circles exist, deletes each of them.
	for (UIView *item in _items) {
		[item removeFromSuperview];
	}
	
	// Clears the array of circles.
	_items = nil;
	
	// Mutable buffer of circles.
	NSMutableArray *aItems = [@[] mutableCopy];
	
	// Calculate the size of the circle.
	CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
	CGFloat sideLenght = screenWidth / 23.0;
	
	// The size of the mug is not more than 30 points.
	if (sideLenght > 30.0)
		sideLenght = 30.0;
	
	// The creation and initialization of all groups.
	CGFloat stepLenght = screenWidth / 2.0 - sideLenght * 5.5;
	for (int i = 0; i < _lenght; ++i) {
		CGRect itemRect = CGRectMake(stepLenght, sideLenght, sideLenght, sideLenght);
		
		UIView *item = [[UIView alloc] initWithFrame:itemRect];
		item.layer.backgroundColor	= nil;
		item.layer.cornerRadius		= sideLenght / 2.0;
		item.layer.borderWidth		= 1.0;
		item.layer.borderColor		= _strokeColor.CGColor;
		
		[aItems addObject:item];
		[self addSubview:item];
		stepLenght += sideLenght * 2;
	}
	
	// Copy the buffer to an immutable array.
	_items = [aItems copy];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	// Drawing code
	
	// Calculates the size of the circle and the starting position.
	CGFloat screenWidth	= UIScreen.mainScreen.bounds.size.width;
	CGFloat sideLenght 	= screenWidth / 23.0;
	CGFloat stepLenght 	= screenWidth / 2.0 - sideLenght * 5.5;
	
	// Setting a new position.
	for (UIView *item in _items) {
		CGRect itemRect = CGRectMake(stepLenght, sideLenght, sideLenght, sideLenght);
		item.frame = itemRect;
		stepLenght += sideLenght * 2;
	}
}

- (void)fillNext {
	// Fills the next circle.
	[self setColorNext:_fillColor inserting:YES];
}

- (void)ravageNext {
	// Removes the filling of the next circle.
	[self setColorNext:nil inserting:NO];
}

- (void)setColorNext:(UIColor *)color inserting:(BOOL)flag {
	// Getting the right circle.
	NSUInteger nextIndex = _text.length - 1 * flag;
	UIView *item = _items[nextIndex];
	
	// Sets the color depending on whether the character is entered or deleted.
	if (flag) {
		item.layer.backgroundColor = [color CGColor];
	}
	else {
		[UIView animateWithDuration:0.3 animations:^{
			item.layer.backgroundColor = [color CGColor];
		}];
	}
}

- (void)ravageAll:(BOOL)animated {
	// Clears the fill from each circle.
	if (animated) {
		// The position of the class to create the animation.
		CGRect startRect 	= self.frame;
		CGRect leftRect		= self.frame;
		CGRect rightRect	= self.frame;
		
		leftRect.origin.x	= self.frame.origin.x - 20.0;
		rightRect.origin.x	= self.frame.origin.x + 20.0;
		
		// The launch of the device
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		
		// Animation of the left movement.
		[UIView animateWithDuration:0.05 animations:^{
			self.frame = leftRect;
		}];
		
		// Animation of the right movement.
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:0.1 animations:^{
				self.frame = rightRect;
			}];
		});
		
		// Return to the starting point.
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:0.2 animations:^{
				self.frame = startRect;
			}];
		});
		
		// The animation is clean fill circles.
		CGFloat delay = 0.0;
		for (NSInteger i = _items.count - 1; i >= 0; --i) {
			delay += 0.1;
			NSUInteger index = i;
			[UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionBeginFromCurrentState animations:^{
				self.items[index].layer.backgroundColor = nil;
			} completion:nil];
		}
	}
	else {
		// Simple cleaning of filling circles.
		for (UIView *item in _items) {
			item.layer.backgroundColor = nil;
		}
	}
}

#pragma mark - First responder

- (BOOL)canBecomeFirstResponder {
	// Could be the first defendant.
	// After will be can not absolve themselves of this status.
	return YES;
}

- (BOOL)becomeFirstResponder {
	// Appointed by the first responder.
	[super becomeFirstResponder];
	return YES;
}

#pragma mark - UIKeyInput

- (UIKeyboardType)keyboardType {
	// Only numeric input is supported.
	return UIKeyboardTypeNumberPad;
}

- (BOOL)hasText {
	// Return if there are any characters in the string.
	return !!_text.length;
}

- (void)insertText:(NSString *)text {
	// Incrementorum line and fill in another circle.
	_text = [_text stringByAppendingString:text];
	[self fillNext];
	
	// If the text you enter is equal to the length of the password, notify the delegate.
	if (_text.length == _lenght) {
		BOOL animated = ![_delegate pinView:self didEndTyping:_text];
		_text = @"";
		[self ravageAll:animated];
	}
}

- (void)deleteBackward {
	// Check that the line is not empty and there is something to delete.
	if (_text.length) {
		// Delete the last character of the string.
		NSRange range = NSMakeRange(_text.length - 1, 1);
		_text = [_text stringByReplacingCharactersInRange:range withString:@""];
		
		// Remove the filling of the last filled circle.
		[self ravageNext];
	}
}

@end
