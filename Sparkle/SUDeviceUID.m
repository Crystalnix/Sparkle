//
//  SUDeviceUID.m
//  Sparkle
//
//  Created by Michael Rublev on 09/02/16.
//  Copyright © 2016 ViaSat. All rights reserved.
//

#import "SUDeviceUID.h"

@implementation SUDeviceUID

+ (NSString *)uniqueIdentifierString {
    return [[self class] hostHardwareUUIDNumber];
}

+ (NSString *)hostHardwareUUIDNumber {
    
    io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    CFStringRef hardwareUUIDAsCFString = NULL;
    
    if (service) {
        hardwareUUIDAsCFString = IORegistryEntryCreateCFProperty(service,
                                                                 CFSTR(kIOPlatformUUIDKey),
                                                                 kCFAllocatorDefault, 0);
        IOObjectRelease(service);
    }
    
    NSString *hardwareUUIDAsNSString = nil;
    if (hardwareUUIDAsCFString != NULL) {
        hardwareUUIDAsNSString = (__bridge NSString *)hardwareUUIDAsCFString;
        CFRelease(hardwareUUIDAsCFString);
    }
    
    return hardwareUUIDAsNSString;
}

@end
