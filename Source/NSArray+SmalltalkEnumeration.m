/*
 * Modified by Nick Ager based on:
 * https://github.com/mdippery/collections/blob/master/Source/NSArrayCollections.m
 * https://github.com/crafterm/MRCEnumerable/blob/master/NSArray%2BEnumerable.m
 * 
 * Copyright (C) 2011 Michael Dippery <mdippery@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/*
 * Smalltalk/Ruby collection looping constructs.
 *
 * For an introduction see: http://matthewcarriere.com/2008/06/23/using-select-reject-collect-inject-and-detect/
 * In summary:
 * - Use #select: or #reject: to create a filtered subset of an array.
 * - Use #collect: to transform the elements of an array.
 * - Use #inject:into: to accumulate, total, or concatenate array values together.
 * - Use #detect: to find an item in an array.
 */

#import "NSArray+SmalltalkEnumeration.h"

@implementation NSArray (SmalltalkEnumeration)

- (void)do:(void (^)(id obj))block
{
    [self enumerateObjectsUsingBlock:^ (id obj, NSUInteger __unused idx, BOOL __unused *stop) { block(obj); }];
}

- (void)doWithIndex:(void (^)(id obj, NSUInteger idx))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL __unused *stop) { block(obj, idx); }];
}

- (void)do:(void (^)(id obj))elementBlock separatedBy:(dispatch_block_t)separatorBlock {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL __unused *stop) {
        if (idx != 0) {
            separatorBlock();
        }
        elementBlock(obj);
    }];
}

- (NSArray *)collect:(id (^)(id obj))block
{
    NSMutableArray * results = [NSMutableArray arrayWithCapacity:[self count]];
    [self do:^(id obj) { [results addObject:block(obj)]; }];
    return results;
}


- (NSArray *)collectWithIndex:(id (^)(id obj, NSUInteger idx))block
{
    NSMutableArray * results = [NSMutableArray arrayWithCapacity:[self count]];
    [self doWithIndex:^(id obj, NSUInteger idx) { [results addObject:block(obj, idx)]; }];
    return results;
}

- (id)detect:(BOOL (^)(id obj))block
{
    return [self detect:block ifNone:^id{ return nil;}];
}

- (id)detect:(BOOL (^)(id obj))block ifNone:(id (^)(void))none
{
    for (id object in self) {
        if (block(object)) return object;
    }
    
    return none();
}

- (NSNumber *)detectIndex:(BOOL (^)(id obj))block
{
    NSNumber __block *foundIndex = nil;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (block(obj)) {
            *stop = YES;
            foundIndex = [NSNumber numberWithUnsignedInteger:idx];
        }
    }];
    return foundIndex;
}

- (id)inject:(id)initial into:(id (^)(id accumulator, id obj))block
{
    id accumulator = initial;

    for (id object in self) {
        accumulator = block(accumulator, object);
    }

    return accumulator;
}

- (NSArray *)reject:(BOOL (^)(id obj))block
{
    return [self inject:[NSMutableArray array] into:^(id m, id obj) {
        if (!block(obj)) {
            [m addObject:obj];
        } 
        return m;
    }];
}

- (NSArray *)rejectWithIndex:(BOOL (^)(id obj, NSUInteger idx))block
{
    NSMutableArray * results = [NSMutableArray array];
    [self doWithIndex:^(id obj, NSUInteger idx) {
        if (!block(obj, idx)) {
            [results addObject:obj];
        }
    }];
    return results;
}

- (NSArray *)select:(BOOL (^)(id obj))block
{
    return [self inject:[NSMutableArray array] into:^(id m, id obj) {
        if (block(obj)){
            [m addObject:obj];
        } 
        return m;
    }];
}

- (NSArray *)selectWithIndex:(BOOL (^)(id obj, NSUInteger idx))block
{
    NSMutableArray * results = [NSMutableArray array];
    [self doWithIndex:^(id obj, NSUInteger idx) {
        if (block(obj, idx)) {
            [results addObject:obj];
        }
    }];
    return results;
}

@end
