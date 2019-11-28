About Home Calculator
=====================

Home Calculator is a simple calculator app primarily targeting the iPad since it does not ship with a native calculator app. I was frustrated with the other basic iPad calculators, so I decided to write my own. I wanted it to resemble the style of the iPhone native app, while supporting the set of operations that the physical calculator I normally used for household expense tracking provided, most importantly a stored tax calculation (for sales tax) and the particular behavior of the sign key combined with chained operations.

This is not a scientific calculator, nor an engineering calculator, and I don't expect it will ever become one.  It does properly use decimal-based number types to avoid floating point rounding errors, and provides 16-digits of display precision, which is more than enough for my needs.

The regular view of the calculator follows the layout of the aforementioned physical calculator, as that's where I'm used to the buttons being, but the layout does get rearranged for very narrow layouts, such as during Split View or Slide Over scenarios.

This app is available for installation in the App Store.  Please file any bug or feature requests on github.com, though no guarantees are given regarding response or timeliness.  But feel free to make your own fork!

# Features

- Up to 16 digit numeric representation
- Large, adaptive buttons
- Support for Slide Over and Split View
- Decimal-based numeric engine to avoid currency rounding errors
- Customizable key click audible feedback
- VoiceOver accessibility
- Support for common 4-function calculator operations
- Additional operations including square, root, reciprocal, and percent
- Tax rate calculations
- Memory store, edit, recall, and clear
- Clear most recent calculation input (for fixing mis-typed data)
- Backspace to delete digits of most recently entered input
- Copy and paste of the input field
- Hardware keyboard support

# Operations

## Binary Addition

e.g. Enter 1 + 2 =

Yields 3.  Subsequent presses of = will continue to add the same value.

= 5  
= 7, and so on.

## Unary Addition

e.g. Enter 3 + =

Yields 3.  Subsequent presses of = will continue to add the same value.

= 6  
= 9, and so on.

## Binary Subtraction

e.g. Enter 5 - 4 =

Yields 1.  Subsequent presses of = will continue to subtract the same value.

= -3  
= -7, and so on.

## Unary Subtraction

e.g. Enter 2 - =

Yields -2.  Subsequent presses of = will continue to subtract the same value.

= -4  
= -6, and so on.

## Binary Multiplication

e.g. Enter 3 × 7 =

Yields 21.  Subsequent presses of = will continue to multiply by the same value.

= 147  
= 1029, and so on.

## Unary Multiplication (Square)

e.g. Enter 3 × =

Yields 9, the square.  Subsequent presses of = will continue to multiply by the same value.

= 27 (third power)
= 81 (fourth power), and so on.

## Binary Division

e.g. Enter 8 ÷ 4 =

Yields 2.  Subsequent presses of = will continue to divide by the same value.

= 0.5  
= 0.125, and so on.

## Unary Division (Reciprocal)

e.g. Enter 2 ÷ =

Yields 0.5, the reciprocal.  Subsequent presses of = will continue to divide by the same value.

= 0.25
= 0.125, and so on.

## Sign Change

Press the +|− button to change the sign of the displayed value.  This can be done to the result of a calculation, and the calculation continued on without reseting the input.

## Square Root

Press the √ button to take the square root of the value currently being displayed.  This can be done to the result of a calculation, or to an argument being entered, and the calculation continued on without reseting the input.  The calculator will take the square root of a negative value as though it were positive, but will place the calculator into an error state.

## Percent Calculations

The % key works as a sort of equal sign, indicating that whatever binary operation has been input, the second argument should be interpreted as a percent.  Thus,

80 + 50 % yields 120 (80 plus 50 percent of 80).  
80 - 50 % yields 40 (80 minus 50 percent of 80).  
80 × 50 % yields 40 (80 times 50 percent (= .5 = divided by 2)).  
80 ÷ 50 % yields 160 (80 divided by 50 percent (= .5 = times 2)).  

Each press of the = key will perform the same percent calculation on the current result.  So each of the above examples would either add, subtract, multiply, or divide 50 percent from the new result.

e.g. 80 + 50 % yields 120  
= 180  
= 270, and so forth, each adding an additional 50 percent.

## Memory Operations

### Add to memory (set memory)

m+ will add the current result to the value stored in the general purpose memory location (initially 0).  If the result would exceed 16 digits, the calculator will enter an error state.  Note that the memory state indicator (M) will become visible upon setting the memory location if it was not already visible.

### Subtract from memory

m- will subtract the current result from the value stored in the general purpose memory location (initially 0).  If the result would exceed 16 digits, the calculator will enter an error state.  Note that the memory state indicator (M) will become visible upon setting the memory location if it was not already visible.

### Display or clear memory

mrc will display the currently stored value so that it can be used in a calculation.  Pressing it twice in a row will first display the memory value, then clear the general purpose memory.  If the memory location is cleared, the memory state indicator (M) will turn off.

## Tax Operations

To use the tax operations, first the tax rate must be set.

### Set the tax rate

1. Enter the tax rate.  For example, if the tax rate is 10.1%, just enter 10.1
2. Press the rate key.  Note the tax+ key becomes a store key.
3. Press the store key.  Note that the tax rate indicator (TAX%) will become visible, indicating that the displayed value is the tax rate.

### Reviewing the tax rate

1. Press the rate key.  Note that the tax- key becomes a recall key.
2. Press the recall key.  The tax rate will be displayed, and the tax rate indicator (TAX%) will become visible, indicating that the displayed valued is the tax rate.

### Add tax to a value

After any calculation, or simply by entering a value, tax can be added to it by pressing the tax+ button.  The display will be updated with the tax-added result, and the TAX+ indicator will become visible, indicating the current display represents a result including tax.

By pressing the tax+ key again, the TAX indicator will instead become visible, and the display will change to show the amount of tax that was included in the previous calculation.

Pressing the tax+ key yet again will revert back to the tax-added result, and so forth.

### Remove tax from a quantity

After any calculation, or simply by entering a value, tax can be removed from it by pressing the tax- button.  The display will be updated with the tax-reduced result, and the TAX- indicator will become visible, indicating the current display represents a result excluding tax.

By pressing the tax- key again, the TAX indicator will instead become visible, and the display will change to show the amount of tax that was removed from the previous calculation.

Pressing the tax- key yet again will revert back to the tax-excluded result, and so forth.

## Mid-calculation Clear

When entering a value, if a mistake is made, pressing C will only clear the current input, but will not halt the current calculation.  Pressing C again will fully halt the calculation, returning to a fresh input state.

## Input backspace

When entering a value, swiping to the left in the display area will delete the last digit entered, then the digit before that, and so forth until the input is cleared back to 0.  This swiping action has no effect on the result of a calculation.

## Copy and paste

The display can be copied or pasted by long tapping in the display area, then selecting either copy or paste from the context menu that appears.  Any value pasted must "look" like a number in the current locale.

## Errors

As with most fixed-digit calculators, a number of situations can cause the calculator to enter an error state.  In the error state, some result may be shown, but it cannot be guaranteed to make sense for the calculation which was attempted.

Errors can arise from any of the following:

- Attempt to divide by zero
- Attempt to take the square root of a negative number
- Attempt to perform any calculation that would exceed 16 digits in the result
- Attempt to alter the general purpose memory location in such a way that it would exceed 16 digits

# Keyboard Input

All operations of the calculator are also made available through hardware keyboard keys, with the following mappings:

| Calculator Key | Keyboard Key |
| --- | --- |
| C | Escape (esc) key |
| Backspace | Backspace (delete) key |
| Digits | Use any numeric key |
| . | Period (.) key |
| = | = or Enter (Return) key |
| +&#124;- | Backslash (\) key |
| % | Percent (%) key |
| √ | Letter Y key |
| × | Asterisk (*) key |
| ÷ | Slash (/) key |
| + | Plus (+) key |
| − | Minus (-) key |
| rate | Letter Q key |
| tax+/store | Letter W key |
| tax-/recall | Letter E key |
| mrc | Letter A key |
| m+ | Letter S key |
| m- | Letter D key |

# Copyright and License

Copyright (c) 2019, Ansel Rognlie
All rights reserved.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.
