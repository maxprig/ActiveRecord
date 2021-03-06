//
//  ActiveRecord_Spec.m
//  ActiveRecord
//
//  Copyright (c) 2014 Michal Konturek
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Kiwi/Kiwi.h>

#import "ActiveRecord.h"
#import "Domain.h"
#import "Factory.h"

SPEC_BEGIN(ActiveRecord_Spec)

describe(@"ActiveRecord", ^{
    
    context(@"batch processing", ^{
        
        __block id students;
        
        beforeAll(^{
            [Factory deleteAll];
            
            students = [Factory fixture100];
            
            [students mk_each:^(id item) {
                [Student createOrUpdateWithData:item];
            }];
        });
        
        it(@"creates every object", ^{
            [[@([Student count]) should] equal:@([students count])];
            [[@([Module count]) should] equal:@10];
        });
        
        it(@"creates every object precisely", ^{
            [students mk_each:^(id item) {
                id sut = [Student objectWithID:[item objectForKey:@"uid"]];
                [[sut shouldNot] beNil];
                [[[sut age] should] equal:[item objectForKey:@"age"]];
                [[[sut firstName] should] equal:[item objectForKey:@"firstName"]];
                [[[sut lastName] should] equal:[item objectForKey:@"lastName"]];
            }];
        });
        
        it(@"creates every object relationship", ^{
            [students mk_each:^(id item) {
                id sut = [Student objectWithID:[item objectForKey:@"uid"]];
                [[sut shouldNot] beNil];

                [[[sut registration] shouldNot] beNil];
                
                NSInteger expected = [[item objectForKey:@"modules"] count];
                [[[sut modules] should] haveCountOf:expected];
            }];
        });
    });
    
    context(@"serialization", ^{
     
        __block id students;
        __block id modules;
        __block id course;
        
        beforeAll(^{
            [Factory deleteAll];
            
            students = @[
                         @{@"uid": @1,
                           @"age": @21, @"firstName": @"William", @"lastName": @"Adama",
                           @"modules": @[@1, @2, @3]
                           },
                         @{@"uid": @2,
                           @"age": @22, @"firstName": @"Laura", @"lastName": @"Roslin",
                           @"modules": @[@1, @2, @4]
                           },
                         @{@"uid": @3,
                           @"age": @23, @"firstName": @"Kara", @"lastName": @"Thrace",
                           @"modules": @[@1, @3]
                           },
                         @{@"uid": @4,
                           @"age": @24, @"firstName": @"Gaius", @"lastName": @"Baltar",
                           @"modules": @[@1, @3, @4, @5]
                           }
                         ];
            
            modules = @[
                        @{@"uid": @1, @"name": @"App Development"},
                        @{@"uid": @2, @"name": @"Database"},
                        @{@"uid": @3, @"name": @"Compilers"},
                        @{@"uid": @4, @"name": @"Object Oriented Design"},
                        @{@"uid": @5, @"name": @"Automated Scheduling"}
                        ];
            
            course = @{@"uid": @1,
                       @"name": @"Computer Science",
                       @"students": students
//                       @"students": @[@1, @2, @3, @4]
                       };
            
            [modules mk_each:^(id item) {
                [Module createOrUpdateWithData:item];
            }];
            
            [Course createOrUpdateWithData:course];
        });
        
        it(@"should create a course precisely", ^{
            id sut = [Course objectWithID:[course objectForKey:@"uid"]];
            [[[sut name] should] equal:[course objectForKey:@"name"]];
            [[[sut students] should] haveCountOf:[students count]];
        });
        
        it(@"should create all modules precisely", ^{
            [[@([Module count]) should] equal:@5];
            
            [modules mk_each:^(id item) {
                id sut = [Module objectWithID:[item objectForKey:@"uid"]];
                [[sut shouldNot] beNil];
                [[[sut name] should] equal:[item objectForKey:@"name"]];
            }];
        });
        
        it(@"should create all students precisely", ^{
            [[@([students count]) should] equal:@4];
            
            [students mk_each:^(id item) {
                id sut = [Student objectWithID:[item objectForKey:@"uid"]];
                [[sut shouldNot] beNil];
                [[[sut age] should] equal:[item objectForKey:@"age"]];
                [[[sut firstName] should] equal:[item objectForKey:@"firstName"]];
                [[[sut lastName] should] equal:[item objectForKey:@"lastName"]];
            }];
        });
        
        it(@"should assign modules to students", ^{
            [students mk_each:^(id student) {
                [[[student objectForKey:@"modules"] allObjects] mk_each:^(id moduleID) {
                    id sut = [Module objectWithID:moduleID];
                    [[[sut uid] should] equal:moduleID];
                }];
            }];
        });
    });
    
});

SPEC_END
