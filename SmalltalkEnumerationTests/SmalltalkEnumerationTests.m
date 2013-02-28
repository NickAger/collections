//
//  SmalltalkEnumerationTests.m
//  SmalltalkEnumerationTests
//
//  Created by Olga Zinchenko on 28/02/2013.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSArray+SmalltalkEnumeration.h"

@interface SmalltalkEnumerationTests : SenTestCase

@end

@implementation SmalltalkEnumerationTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testCollect
{
    NSArray *integerSequence = @[@1, @2, @3, @4, @5];
    NSArray *integerSequenceTimesTwo = [integerSequence collect:^NSNumber *(NSNumber *number) {
        return @([number intValue] * 2);
    }];
    
    STAssertEquals(integerSequence.count, integerSequenceTimesTwo.count,  @"both arrays should have the same length");

    
    STAssertEquals([integerSequenceTimesTwo[0] intValue], 2,  @"1 should have transformed to 2");
    STAssertEquals([integerSequenceTimesTwo[1] intValue], 4,  @"2 should have transformed to 4");
    STAssertEquals([integerSequenceTimesTwo[2] intValue], 6,  @"3 should have transformed to 6");
    STAssertEquals([integerSequenceTimesTwo[3] intValue], 8,  @"4 should have transformed to 8");
    STAssertEquals([integerSequenceTimesTwo[4] intValue], 10,  @"5 should have transformed to 10");
}

@end
