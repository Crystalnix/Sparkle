//
//  SUDeviceUID.h
//  Sparkle
//
//  Created by Michael Rublev on 09/02/16.
//  Copyright © 2016 ViaSat. All rights reserved.
//

//  SUDeviceUID class returns unique device string that relies on a MacOSX system service,
//  which returns NSUUID like firmatted string. About This Mac > System Report > Hardware UUID

#import <Foundation/Foundation.h>

@interface SUDeviceUID : NSObject

/*
 String representation of hardware UUID of the system.
 Format as described in NSUUID class: printf(3) format "%08X-%04X-%04X-%04X-%012X"
 */
+ (NSString *)uniqueIdentifierString;

@end
