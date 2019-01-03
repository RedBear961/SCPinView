/**
 * @class SCPinView
 * @protected MIT License
 *
 * @copyright (c) 2018 Georgiy Cheremnikh.
 * All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCPinView;

@protocol SCPinViewDelegate <NSObject>
@required
/**
 * @method pinView:didEndTyping:
 * @brief Reports that the user has finished entering the password.
 * @param pin User-entered password.
 * @return A Boolean value that determines whether the password entered by the user is correct.
 		If the password is incorrect, it starts an animation showing the user that the password
 		is incorrect.
 */
- (BOOL)pinView:(SCPinView *)pinView didEndTyping:(NSString *)pin;

@end

/**
 * @class SCPinView
 * @brief A simple way to simplify password entry. Intuitive interface for
 		entering a password of a certain length.
 */
@interface SCPinView : UIView <NSCoding, UIKeyInput>

/**
 * @property delegate
 * @brief The class responsible for the correctness and correctness of the entered password.
 */
@property (weak, nonatomic) id<SCPinViewDelegate> delegate;

/**
 * @property lenght
 * @brief The length of the password to enter. Determines the number of circles
 		in the visual input. Setting values to force a redraw. The default is 4.
 */
@property (nonatomic) IBInspectable NSUInteger lenght;

/**
 * @property fillColor
 * @brief Defines the color of the circles. Default is black.
 */
@property (strong, nonatomic) UIColor *fillColor;

/**
 * @property strokeColor
 * @brief Defines the color of the circle border. Default value is equal to the
 		color fill, black.
 */
@property (strong, nonatomic) UIColor *strokeColor;

/**
 * @property text
 * @brief Input text. After the length of the text reaches the length of the password,
 		calls the delegate method pinView:didEndTyping:.
 */
@property (readonly, nonatomic) NSString *text;

@end

NS_ASSUME_NONNULL_END
