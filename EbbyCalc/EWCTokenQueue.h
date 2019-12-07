//
//  EWCTokenQueue.h
//  EbbyCalc
//
//  Created by Ansel Rognlie on 11/22/19.
//  Copyright © 2019 Ansel Rognlie. All rights reserved.
//

//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

#import <Foundation/Foundation.h>
#import "EWCCalculatorToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface EWCTokenQueue : NSObject

/**
  Whether there was a change to the queue since the last time this property was checked.
 */
@property (nonatomic, readonly) BOOL didChange;

/**
 Whether an enqueue operation has put the queue into an error state.  Only `enqueueEqual` is able to place the queue in such a state.
*/
@property (nonatomic, readonly) BOOL hasError;

/**
  Resets the queue to an empty state.
 */
- (void)clear;

/**
  Commits the token parsing that has occurred.

  This fully removes the tokens that have been traversed by the instruction pointter from the queue, and resets the instruction pointer to zero.

  @note After calling this method, any token that was used in the last parse can no longer be pushed back into the queue using `pushbackToken`.
 */
- (void)commit;

/**
  Ensures that the queue is configured with the next token being the front of the queue.
 */
- (void)moveToFirst;

/**
  Gets the next token in the token queue as long as it matches the requested type.

  If a token is returned, as with `nextToken`, the instruction pointer is advanced.  The token may still be pushed back into the queue until the parse is comitted.

  @param tokenType The type of the token to retrieve, if present.

  @return The next token in the queue, if it matches the requested type.  Returns nil if there is no token, or the type does not match.
 */
- (EWCCalculatorToken *)nextTokenAs:(EWCCalculatorTokenType)tokenType;

/**
  Returns the next token in the operation, auto-advancing the instruction pointer to the next token in the process.

  @return The token at the current instruction pointer.  This is logically removed from the queue, but still present until commited.  A subsequent pushback would return it to the head of the queue.
 */
- (EWCCalculatorToken *)nextToken;

/**
  Removes the token at the current instruction pointer from the operation queue entirely, returning it.

  Primarily useful when removing part of a parse that is effectively a no-op, or a non-error invalid operation, while leaving the operators alone.

  @return The token at the current instruction pointer (now removed from the queue), or nil if the queue is empty or the instruction pointer is at the end of the queue.
 */
- (EWCCalculatorToken *)popToken;

/**
  Prior to committing a parse, this will "pushback" the last read by moving the instruction pointer towards the front of the queue.

  @note This should not be called after a commit, as this effectively causes an instruciton pointer underflow.
 */
- (void)pushbackToken;

/**
  Adds a binary operator to the operation queue.

  @note If the last item in the queue is already a binary operator, then adding an additional one will simply overwrite it.

  @param op The type of binary operator to add to the queue.
 */
- (void)enqueueBinOp:(EWCCalculatorOpcode)op;

/**
  Adds an equal operator to the operation queue.

  @note Atempting to add an equal operator to the queue if one exists results in the calculator entering an error state, which will clear the queue as a the user clears the error.  This really shouldn't ever happen, as the queue is processed after every addition, and encountering an equal operation triggers processing and removal.

  @param op The type of equal operation (equal or percent) to add to the queue.
 */
- (void)enqueueEqual:(EWCCalculatorOpcode)op;

/**
  Adds a data to the operation queue.

  @note If the last item in the queue is already data, then adding additional data will simply overwrite it.

  @param data The data value to add to the queue.  It will be wrapped in a data token.
 */
- (void)enqueueData:(NSDecimalNumber *)data;

/**
  Gets the final token from the end of the operation queue.

  @return The token at the end of the operation queue, or nil if empty.
 */
- (EWCCalculatorToken *)getLastToken;

/**
  Removes the final token from the end of the operation queue.
 */
- (void)removeLastToken;

@end

NS_ASSUME_NONNULL_END
