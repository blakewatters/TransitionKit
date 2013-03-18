//
//  TKEventSpec.m
//  TransitionKit
//
//  Created by Blake Watters on 3/17/13.
//  Copyright (c) 2013 Blake Watters. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "Kiwi.h"
#import "TKEvent.h"

SPEC_BEGIN(TKEventSpec)

describe(@"eventWithName:transitioningFromStates:toState:", ^{
    context(@"when the name is `nil`", ^{
        it(@"raises an NSInvalidArgumentException", ^{
            [[theBlock(^{
                [TKEvent eventWithName:nil transitioningFromStates:nil toState:nil];
            }) should] raiseWithName:NSInvalidArgumentException reason:@"The event name cannot be blank."];
        });
    });
    
    context(@"when the name is blank", ^{
        it(@"raises an NSInvalidArgumentException", ^{
            [[theBlock(^{
                [TKEvent eventWithName:@"" transitioningFromStates:nil toState:nil];
            }) should] raiseWithName:NSInvalidArgumentException reason:@"The event name cannot be blank."];
        });
    });
    
    context(@"when the destinationState is `nil`", ^{
        it(@"raises an NSInvalidArgumentException", ^{
            [[theBlock(^{
                [TKEvent eventWithName:@"Name" transitioningFromStates:nil toState:nil];
            }) should] raiseWithName:NSInvalidArgumentException reason:@"The destination state cannot be nil."];
        });
    });
});

context(@"when copied", ^{
});

context(@"when archived", ^{
});

SPEC_END
