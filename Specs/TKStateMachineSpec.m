//
//  TKStateMachineSpec.m
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
#import "TransitionKit.h"

@interface TKSpecPerson : NSObject
@property (nonatomic, assign, getter = isHappy) BOOL happy;
@property (nonatomic, assign, getter = isLookingForLove) BOOL lookingForLove;
@property (nonatomic, assign, getter = isDepressed) BOOL depressed;
@property (nonatomic, assign, getter = isConsultingLawyer) BOOL consultingLawyer;
@property (nonatomic, assign, getter = wasPreviouslyMarried) BOOL previouslyMarried;
@property (nonatomic, assign, getter = isWillingToGiveUpHalfOfEverything) BOOL willingToGiveUpHalfOfEverything;

- (void)updateRelationshipStatusOnFacebook;
- (void)startDrinkingHeavily;
- (void)startTryingToPickUpCollegeGirls;
@end

@implementation TKSpecPerson
- (void)updateRelationshipStatusOnFacebook {}
- (void)startDrinkingHeavily {}
- (void)startTryingToPickUpCollegeGirls {}
@end

SPEC_BEGIN(TKStateMachineSpec)

__block TKStateMachine *stateMachine = nil;

beforeEach(^{
    stateMachine = [TKStateMachine new];
});

context(@"when initialized", ^{
    it(@"has no states", ^{
        [[stateMachine.states should] haveCountOf:0];
    });
    
    it(@"has a nil initial state", ^{
        [stateMachine.initialState shouldBeNil];
    });
    
    it(@"has no events", ^{
        [[stateMachine.events should] haveCountOf:0];
    });
    
    context(@"and a state is added", ^{
        __block TKState *state = nil;
        
        beforeEach(^{
            state = [TKState stateWithName:@"Single"];
            [stateMachine addState:state];
        });
        
        it(@"has a state count of 1", ^{
            [[stateMachine.states should] haveCountOf:1];
        });
        
        it(@"contains the state that was added", ^{
            [[stateMachine.states should] contain:state];
        });
        
        it(@"can retrieve the state by name", ^{
            TKState *fetchedState = [stateMachine stateNamed:@"Single"];
            [[fetchedState should] equal:state];
        });
        
        it(@"sets the initial state to the newly added state", ^{
            [[stateMachine.initialState should] equal:state];
        });
    });
    
    context(@"when an event is added", ^{
        __block TKEvent *event = nil;
        __block TKState *singleState = nil;
        __block TKState *datingState = nil;
        
        context(@"when a state referenced by the event is not added to the state machine", ^{
            it(@"raises an exception", ^{
                stateMachine = [TKStateMachine new];
                [stateMachine addState:singleState];
                event = [TKEvent eventWithName:@"Start Dating" transitioningFromStates:@[ singleState ] toState:datingState];
                [[theBlock(^{
                    [stateMachine addEvent:event];
                }) should] raiseWithName:NSInternalInconsistencyException reason:@"Cannot add event 'Start Dating' to the state machine: the event references a state 'Dating', which has not been added to the state machine."];
            });
        });
        
        beforeEach(^{
            singleState = [TKState stateWithName:@"Single"];
            datingState = [TKState stateWithName:@"Dating"];
            event = [TKEvent eventWithName:@"Start Dating" transitioningFromStates:@[ singleState ] toState:datingState];
            [stateMachine addStates:@[ singleState, datingState ]];
            [stateMachine addEvent:event];
        });
        
        it(@"has an event count of 1", ^{
            [[stateMachine.events should] haveCountOf:1];
        });
        
        it(@"contains the event that was added", ^{
            [[stateMachine.events should] contain:event];
        });
        
        it(@"can retrieve the event by name", ^{
            TKEvent *fetchedEvent = [stateMachine eventNamed:@"Start Dating"];
            [[fetchedEvent should] equal:event];
        });
    });
});

context(@"when a state machine is copied", ^{
    __block TKState *firstState;
    __block TKState *secondState;
    __block TKEvent *event;
    __block TKStateMachine *copiedStateMachine;
    
    beforeEach(^{
        firstState = [TKState stateWithName:@"First"];
        secondState = [TKState stateWithName:@"Second"];
        [stateMachine addStates:@[ firstState, secondState ]];
        event = [TKEvent eventWithName:@"Event" transitioningFromStates:@[ firstState ] toState:secondState];
        [stateMachine addEvent:event];
        
        stateMachine.initialState = firstState;
        [stateMachine activate];
        
        copiedStateMachine = [stateMachine copy];
    });
    
    it(@"is not active", ^{
        [[@(copiedStateMachine.isActive) should] beNo];
    });
    
    it(@"copies all states", ^{
        [[copiedStateMachine.states should] haveCountOf:2];
        [[copiedStateMachine.states shouldNot] contain:firstState];
        [[copiedStateMachine.states shouldNot] contain:secondState];
    });
    
    it(@"copies all events", ^{
        [[copiedStateMachine.events should] haveCountOf:1];
        [[copiedStateMachine.events shouldNot] contain:event];
    });
    
    it(@"copies the initial state", ^{
        [[copiedStateMachine.initialState.name should] equal:@"First"];
    });
    
    it(@"has a `nil` current state", ^{
        [copiedStateMachine.currentState shouldBeNil];
    });
});

context(@"when a state machine is serialized", ^{
});

describe(@"setting the initial state", ^{
    beforeEach(^{
        TKState *single = [TKState stateWithName:@"Single"];
        TKState *dating = [TKState stateWithName:@"Dating"];
        [stateMachine addStates:@[ single, dating ]];
        [stateMachine addEvent:[TKEvent eventWithName:@"Break Up" transitioningFromStates:@[ dating ] toState:single]];
    });
    
    context(@"when the state machine has not been started", ^{
        beforeEach(^{
            [stateMachine addState:[TKState stateWithName:@"Dating"]];
            stateMachine.initialState = [stateMachine stateNamed:@"Dating"];
        });
        
        it(@"sets the initial state", ^{
            [[stateMachine.initialState.name should] equal:@"Dating"];
        });
        
        it(@"does not have a current state", ^{
            [stateMachine.currentState shouldBeNil];
        });
        
        context(@"and then is started", ^{
            it(@"changes the current state to the initial state", ^{
                [stateMachine activate];
                [[stateMachine.currentState.name should] equal:@"Dating"];
            });
        });
    });
    
    context(@"when the state machine has been started", ^{
        it(@"raises an exception", ^{
            stateMachine.initialState = [stateMachine stateNamed:@"Dating"];
            [stateMachine fireEvent:@"Break Up" error:nil];
            [[theBlock(^{
                stateMachine.initialState = [stateMachine stateNamed:@"Married"];
            }) should] raiseWithName:TKStateMachineIsImmutableException reason:@"Unable to modify state machine: The state machine has already been activated."];
        });
    });
});

describe(@"addState:", ^{
    context(@"when given an object that is not a TKState", ^{
        it(@"raises an NSInvalidArgumentException", ^{
            [[theBlock(^{
                [stateMachine addState:(TKState *)@1234];
            }) should] raiseWithName:NSInvalidArgumentException reason:@"Expected a `TKState` object or `NSString` object specifying the name of a state, instead got a `__NSCFNumber` (1234)"];
        });
    });
});

describe(@"isInState:", ^{
    context(@"when given an object that is not a TKState or an NSString", ^{
        it(@"raises an NSInvalidArgumentException", ^{
            [[theBlock(^{
                [stateMachine isInState:(TKState *)@1234];
            }) should] raiseWithName:NSInvalidArgumentException reason:@"Expected a `TKState` object or `NSString` object specifying the name of a state, instead got a `__NSCFNumber` (1234)"];
        });
    });
    
    context(@"when given a NSString that is not the name of a registered state", ^{
        it(@"raises an NSInvalidArgumentException", ^{
            [[theBlock(^{
                [stateMachine isInState:@"Invalid"];
            }) should] raiseWithName:NSInvalidArgumentException reason:@"Cannot find a State named 'Invalid'"];
        });
    });
});

describe(@"A State Machine Modeling Dating", ^{
    __block TKSpecPerson *person;
    __block TKState *singleState;
    __block TKState *datingState;
    __block TKState *marriedState;
    __block TKEvent *startDating;
    __block TKEvent *breakup;
    __block TKEvent *getMarried;
    __block TKEvent *divorce;
    
    beforeEach(^{
        person = [TKSpecPerson new];
        
        stateMachine = [TKStateMachine new];
        singleState = [TKState stateWithName:@"Single"];
        [singleState setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
            person.lookingForLove = YES;
        }];
        [singleState setDidExitStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
            person.lookingForLove = NO;
        }];
        datingState = [TKState stateWithName:@"Dating"];
        [datingState setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
            person.happy = YES;
        }];
        [datingState setDidExitStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
            person.happy = NO;
        }];
        marriedState = [TKState stateWithName:@"Married"];
        [stateMachine addStates:@[ singleState, datingState, marriedState ]];
        
        startDating = [TKEvent eventWithName:@"Start Dating" transitioningFromStates:@[ singleState ] toState:datingState];
        [startDating setDidFireEventBlock:^(TKEvent *event, TKStateMachine *stateMachine) {
            [person updateRelationshipStatusOnFacebook];
        }];
        breakup = [TKEvent eventWithName:@"Break Up" transitioningFromStates:@[ datingState ] toState:singleState];
        [breakup setDidFireEventBlock:^(TKEvent *event, TKStateMachine *stateMachine) {
            [person updateRelationshipStatusOnFacebook];
            [person startDrinkingHeavily];
        }];
        getMarried = [TKEvent eventWithName:@"Get Married" transitioningFromStates:@[ datingState ] toState:marriedState];
        divorce = [TKEvent eventWithName:@"Divorce" transitioningFromStates:@[ marriedState ] toState:singleState];
        [divorce setWillFireEventBlock:^(TKEvent *event, TKStateMachine *stateMachine) {
            person.consultingLawyer = YES;
        }];
        [divorce setShouldFireEventBlock:^BOOL(TKEvent *event, TKStateMachine *stateMachine) {
            return person.isWillingToGiveUpHalfOfEverything;
        }];
        [divorce setDidFireEventBlock:^(TKEvent *event, TKStateMachine *stateMachine) {
            person.consultingLawyer = NO;
            [person startDrinkingHeavily];
            [person startTryingToPickUpCollegeGirls];
        }];
        
        [stateMachine addEvents:@[ startDating, breakup, getMarried, divorce ]];
    });
    
    context(@"when a Single Person Starts Dating", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Single"];
            [stateMachine activate];
        });
        
        it(@"transitions to the Dating state", ^{
            [stateMachine fireEvent:@"Start Dating" error:nil];
            [[stateMachine.currentState.name should] equal:@"Dating"];
        });
        
        it(@"returns YES", ^{
            BOOL success = [stateMachine fireEvent:@"Start Dating" error:nil];
            [[@(success) should] beYes];
        });
        
        it(@"returns a nil error", ^{
            NSError *error = nil;
            [stateMachine fireEvent:@"Start Dating" error:&error];
            [error shouldBeNil];
        });
        
        it(@"is no longer looking for love", ^{
            [[@(person.isLookingForLove) should] beYes];
            [stateMachine fireEvent:@"Start Dating" error:nil];
            [[@(person.isLookingForLove) should] beNo];
        });
        
        it(@"is happy", ^{
            [[@(person.isHappy) should] beNo];
            [stateMachine fireEvent:@"Start Dating" error:nil];
            [[@(person.isHappy) should] beYes];
        });
        
        it(@"delivers a notification", ^{
            __block NSNotification *notification = nil;
            id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TKStateMachineDidChangeStateNotification object:stateMachine queue:nil usingBlock:^(NSNotification *note) {
                notification = note;
            }];
            [stateMachine fireEvent:@"Start Dating" error:nil];
            [[expectFutureValue(notification) shouldEventually] beNonNil];
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            [[[[notification.userInfo objectForKey:TKStateMachineDidChangeStateOldStateUserInfoKey] name] should] equal:@"Single"];
            [[[[notification.userInfo objectForKey:TKStateMachineDidChangeStateNewStateUserInfoKey] name] should] equal:@"Dating"];
            [[[[notification.userInfo objectForKey:TKStateMachineDidChangeStateEventUserInfoKey] name] should] equal:@"Start Dating"];
        });
    });
    
    context(@"when a Dating Person Breaks Up", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Dating"];
        });
        
        it(@"updates their relationship status on Facebook", ^{
            [[person should] receive:@selector(updateRelationshipStatusOnFacebook)];
            [stateMachine fireEvent:@"Break Up" error:nil];
        });
        
        it(@"starts drinking heavily", ^{
            [[person should] receive:@selector(startDrinkingHeavily)];
            [stateMachine fireEvent:@"Break Up" error:nil];
        });
        
        it(@"starts looking for love", ^{
            [stateMachine fireEvent:@"Break Up" error:nil];
            [[@(person.isLookingForLove) should] beYes];
        });
        
        it(@"becomes unhappy", ^{
            [stateMachine fireEvent:@"Break Up" error:nil];
            [[@(person.isHappy) should] beNo];
        });
    });
    
    context(@"when a Dating Person Gets Married", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Dating"];
        });
    });
    
    context(@"when a Married Person Divorces", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Married"];
            [stateMachine activate];
        });
        
        context(@"but is unwilling to give up half of everything", ^{
            beforeEach(^{
                person.willingToGiveUpHalfOfEverything = NO;
            });
            
            it(@"can be fired", ^{
                [[@([stateMachine canFireEvent:@"Divorce"]) should] beYes];
            });
            
            it(@"fails to fire the event", ^{
                [[@([stateMachine fireEvent:@"Divorce" error:nil]) should] beNo];
            });
            
            it(@"fails with a TKTransitionDeclinedError", ^{
                NSError *error = nil;
                [stateMachine fireEvent:@"Divorce" error:&error];
                [[@(error.code) should] equal:@(TKTransitionDeclinedError)];
            });
            
            it(@"sets a description on the error", ^{
                NSError *error = nil;
                [stateMachine fireEvent:@"Divorce" error:&error];
                [[error.localizedDescription should] equal:@"The event declined to be fired."];
            });
            
            it(@"sets a failure reason on the error", ^{
                NSError *error = nil;
                [stateMachine fireEvent:@"Divorce" error:&error];
                [[error.localizedFailureReason should] equal:@"An attempt to fire the 'Divorce' event was declined because `shouldFireEventBlock` returned `NO`."];
            });
            
            it(@"stays married", ^{
                [stateMachine fireEvent:@"Divorce" error:nil];
                [[stateMachine.currentState.name should] equal:@"Married"];
            });
        });
        
        context(@"when willing to give up half of everything", ^{
            beforeEach(^{
                person.willingToGiveUpHalfOfEverything = YES;
            });
            
            it(@"can be fired", ^{
                [[@([stateMachine canFireEvent:@"Divorce"]) should] beYes];
            });
            
            it(@"comsults a lawyer during the divorce", ^{
                [[person should] receive:@selector(setConsultingLawyer:) withArguments:theValue(YES)];
                [[person should] receive:@selector(setConsultingLawyer:) withArguments:theValue(NO)];
                [stateMachine fireEvent:@"Divorce" error:nil];
            });
            
            it(@"transitions to the Single state", ^{
                [stateMachine fireEvent:@"Divorce" error:nil];
                [[stateMachine.currentState.name should] equal:@"Single"];
            });
            
            it(@"starts drinking heavily", ^{
                [[person should] receive:@selector(startDrinkingHeavily)];
                [stateMachine fireEvent:@"Divorce" error:nil];
            });
            
            it(@"starts trying to pick up college girls", ^{
                [[person should] receive:@selector(startTryingToPickUpCollegeGirls)];
                [stateMachine fireEvent:@"Divorce" error:nil];
            });
        });
    });
    
    // Invalid Transitions
    context(@"when a Single Person tries to Break Up", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Single"];
        });
        
        it(@"cannot be fired", ^{
            [[@([stateMachine canFireEvent:@"Break Up"]) should] beNo];
        });
        
        context(@"when fired", ^{
            it(@"returns NO", ^{
                [[@([stateMachine fireEvent:@"Break Up" error:nil]) should] beNo];
            });
            
            it(@"sets an TKInvalidTransitionError error", ^{
                NSError *error = nil;
                [stateMachine fireEvent:@"Break Up" error:&error];
                [[@(error.code) should] equal:@(TKInvalidTransitionError)];
            });
            
            it(@"sets an informative description on the error", ^{
                NSError *error = nil;
                [stateMachine fireEvent:@"Break Up" error:&error];
                [[[error localizedDescription] should] equal:@"The event cannot be fired from the current state."];
            });
            
            it(@"sets an informative failure reason on the error", ^{
                NSError *error = nil;
                [stateMachine fireEvent:@"Break Up" error:&error];
                [[[error localizedFailureReason] should] equal:@"An attempt was made to fire the 'Break Up' event while in the 'Single' state, but the event can only be fired from the following states: Dating"];
            });
        });
    });
    
    context(@"when a Single Person tries to Get Married", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Single"];
        });
        
        it(@"cannot be fired", ^{
            [[@([stateMachine canFireEvent:@"Get Married"]) should] beNo];
        });
    });
    
    context(@"when a Single Person tries to Divorce", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Single"];
        });
        
        it(@"cannot be fired", ^{
            [[@([stateMachine canFireEvent:@"Divorce"]) should] beNo];
        });
    });
    
    context(@"when a Dating Person tries to Divorce", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Dating"];
        });
        
        it(@"cannot be fired", ^{
            [[@([stateMachine canFireEvent:@"Divorce"]) should] beNo];
        });
    });
    
    context(@"when a Dating Person tries to Start Dating", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Dating"];
        });
        
        it(@"cannot be fired", ^{
            [[@([stateMachine canFireEvent:@"Start Dating"]) should] beNo];
        });
    });
    
    context(@"when a Married Person tries to Break Up", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Married"];
        });
        
        it(@"cannot be fired", ^{
            [[@([stateMachine canFireEvent:@"Break Up"]) should] beNo];
        });
    });
    
    context(@"when a Married Person tries to Start Dating", ^{
        beforeEach(^{
            stateMachine.initialState = [stateMachine stateNamed:@"Married"];
        });
        
        it(@"cannot be fired", ^{
            [[@([stateMachine canFireEvent:@"Start Dating"]) should] beNo];
        });
    });
});

SPEC_END
