# Discover Feature Animation Architecture

This directory contains the animation definitions for the Discover feature. The animations are organized into separate classes to promote reusability, maintainability, and separation of concerns.

## Animation Classes

### `DiscoverAnimations`

Contains all the constants used for animations in the Discover feature:

- Duration constants
- Threshold values for interactions
- Scaling factors
- Rotation factors
- Perspective values

### `DiscoverCurves`

Defines the animation curves used in the Discover feature:

- `returnToCenterCurve`: Used when a card returns to the center
- `swipeOutCurve`: Used when a card is swiped out
- `getSwipeCurve()`: Helper method to get the appropriate curve based on the animation type

### `ShakeAnimation`

Handles the shake animation for the rewind button:

- `oscillations`: Number of oscillations in the shake animation
- `maxRotationAngle`: Maximum rotation angle
- `calculateRotationAngle()`: Calculates the rotation angle based on the animation value
- `createController()`: Creates an animation controller for the shake animation
- `triggerShake()`: Triggers the shake animation and resets when complete

### `SwipeAnimation`

Manages the card swipe animations:

- `createController()`: Creates an animation controller for swipe animations
- `calculateTargetOffset()`: Calculates the target offset for a swipe in a specific direction
- `calculateCardTransform()`: Calculates the transform matrix for a card based on its offset

### `NextCardAnimation`

Handles the animations for revealing the next card:

- `calculateOpacity()`: Calculates the opacity of the next card
- `calculateScale()`: Calculates the scale of the next card

## SwipeDirection Enum

Defines the possible swipe directions:

- `left`: Swipe left (dislike)
- `right`: Swipe right (like)
- `up`: Swipe up (superlike)
- `none`: No swipe

## Usage

The animation definitions are used by the following controllers:

- `SwipeAnimationController`: Uses the animation definitions to manage card swipe animations
- `CardInteractionController`: Uses the animation definitions to handle user interactions

And by the following UI components:

- `TestDiscoverPage`: Uses the animation definitions to create and configure animation controllers

## Benefits

This architecture provides several benefits:

1. **Centralized Animation Constants**: All animation constants are defined in one place, making them easy to adjust
2. **Reusable Animation Logic**: Animation calculations are encapsulated in static methods that can be reused
3. **Separation of Concerns**: Animation logic is separated from UI and business logic
4. **Improved Testability**: Animation logic can be tested independently
5. **Consistent Animations**: Ensures consistent animations throughout the app 