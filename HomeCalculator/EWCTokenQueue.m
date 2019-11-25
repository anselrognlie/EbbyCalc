//
//  EWCTokenQueue.m
//  HomeCalculator
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

#import "EWCTokenQueue.h"

@interface EWCTokenQueue () {
  NSMutableArray<EWCCalculatorToken *> *_queue;  // queue of tokens to be interpreted as calculator operations
  short _ip;  // an instruction pointer for looking into the token queue.  used for cleaning up tokens we have used
  BOOL _didChange;  // whether the queue has changed since it was last inspected for tokens
}

@end

@implementation EWCTokenQueue

/**
  Designated initializer.
 */
- (instancetype)init {
  self = [super init];
  if (self) {
    _queue = [NSMutableArray<EWCCalculatorToken *> new];
    _ip = 0;
    _didChange = NO;
    _hasError = NO;
  }

  return self;
}

- (BOOL)didChange {
  BOOL value = _didChange;
  _didChange = NO;
  return value;
}

- (void)clear {
  [_queue removeAllObjects];
  _ip = 0;
}

- (void)commit {
  [_queue removeObjectsInRange:NSMakeRange(0, _ip)];
  _ip = 0;
}

- (void)moveToFirst {
  _ip = 0;
}

- (EWCCalculatorToken *)nextTokenAs:(EWCCalculatorTokenType)tokenType {
  if (_queue.count == 0 || _ip >= _queue.count) { return nil; }

  EWCCalculatorToken *token = _queue[_ip];
  if (token.tokenType == tokenType) {
    ++_ip;
  } else {
    token = nil;
  }

  return token;
}

- (EWCCalculatorToken *)nextToken {
  if (_queue.count == 0 || _ip >= _queue.count) { return nil; }

  EWCCalculatorToken *token = _queue[_ip];
  ++_ip;

  return token;
}

- (EWCCalculatorToken *)popToken {
  if (_queue.count == 0 || _ip >= _queue.count) { return nil; }

  // get the token, then remove it from the queue
  EWCCalculatorToken *token = _queue[_ip];
  [_queue removeObjectAtIndex:_ip];

  // return *without* advancing the ip

  return token;
}

- (void)pushbackToken {
  --_ip;
}

- (void)enqueueBinOp:(EWCCalculatorOpcode)op {

  // if the last item in queue is a binary op, and we are adding a binary op,
  // just replace it (user changed mind about operator)
  BOOL replaced = NO;
  if (_queue.count > 0) {
    EWCCalculatorToken *last = _queue[_queue.count - 1];
    if (last.tokenType == EWCCalculatorBinOpTokenType) {
      _queue[_queue.count - 1] = [EWCCalculatorToken tokenWithBinOp:op];
      replaced = YES;
    }
  }

  if (! replaced) {
    [_queue addObject:[EWCCalculatorToken tokenWithBinOp:op]];
  }

  _didChange = YES;
}

- (void)enqueueEqual:(EWCCalculatorOpcode)op {

  // should not allow back to back equal tokens
  // they get removed due to processing, so a back to back equal is strange
  if (_queue.count > 0) {
    EWCCalculatorToken *last = _queue[_queue.count - 1];
    if (last.tokenType == EWCCalculatorEqualTokenType) {
      _hasError = YES;
      return;
    }
  }

  [_queue addObject:[EWCCalculatorToken tokenWithEqual:op]];

  _didChange = YES;
}

- (void)enqueueData:(NSDecimalNumber *)data {

  // if the last item in queue is data, and we are adding data,
  // just replace it (user could have been working with memory or rate)
  BOOL replaced = NO;
  if (_queue.count > 0) {
    EWCCalculatorToken *last = _queue[_queue.count - 1];
    if (last.tokenType == EWCCalculatorDataTokenType) {
      _queue[_queue.count - 1] = [EWCCalculatorToken tokenWithData:data];
      replaced = YES;
    }
  }

  if (! replaced) {
    [_queue addObject:[EWCCalculatorToken tokenWithData:data]];
  }

  _didChange = YES;
}

- (EWCCalculatorToken *)getLastToken {
  if (_queue.count > 0) {
    return _queue[_queue.count - 1];
  }

  return nil;
}

- (void)removeLastToken {
  if (_queue.count > 0) {
    [_queue removeObjectAtIndex:_queue.count - 1];
  }
}


@end
