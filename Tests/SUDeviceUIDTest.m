//
//  SUUUIDTest.m
//  Sparkle
//
//  Created by Michael Rublev on 09/02/16.
//  Copyright © 2016 ViaSat. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SUDeviceUID.h"

@interface SUDeviceUIDTest : XCTestCase

@end

@implementation SUDeviceUIDTest

- (void)testValueIsTheSame {
    NSString *firstGet = nil, *secondGet = nil;
    
    firstGet = [SUDeviceUID uniqueIdentifierString];
    {
        secondGet = [SUDeviceUID uniqueIdentifierString];
    }
    
    XCTAssertNotNil(firstGet);
    XCTAssertNotNil(secondGet);
    XCTAssertTrue([firstGet isEqualToString:secondGet]);
}

- (void)testFormat {
    NSString *value = [SUDeviceUID uniqueIdentifierString];
    NSArray *components = [value componentsSeparatedByString:@"-"];
    
    XCTAssertTrue(value.length > 0);
    XCTAssertTrue(components.count == 5);
    XCTAssertTrue(((NSString *)components[0]).length == 8);
    XCTAssertTrue(((NSString *)components[1]).length == 4);
    XCTAssertTrue(((NSString *)components[2]).length == 4);
    XCTAssertTrue(((NSString *)components[3]).length == 4);
    XCTAssertTrue(((NSString *)components[4]).length == 12);
}

@end
