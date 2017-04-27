//  BRJBDetect.m extends OneSignal Implementation
//
//  Copyright (c) 2014 Doan Truong Thi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

// Renamed DTTJailbreakDetection.m to TSJBDetect.m to avoid conflicts with other libraries.

#import <UIKit/UIKit.h>
#import "BRJBString.h"
#import "BRJBDetect.h"

@implementation BRJBDetect


+ (BOOL)isEmulator {
    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice.model rangeOfString:[BRJBString str:BR_JBSTR_SIMULATOR]].location == NSNotFound) {
#if (TARGET_IPHONE_SIMULATOR)
        return true;
#else
        return false;
#endif
    }
    return true;
}

+ (NSString*)jailbrakeMethod {
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    char* r = [[BRJBString str:BR_JBSTR_R] cStringUsingEncoding:NSUTF8StringEncoding];
    
    FILE *file = fopen([[BRJBString str:BR_JBSTR__APPLICATIONS_CYDIA_APP] cStringUsingEncoding:NSUTF8StringEncoding], r);
    if (file) {
        fclose(file);
        return [BRJBString str:BR_JBSTR_CYDIA_APP];
    }
    file = fopen([[BRJBString str:BR_JBSTR__LIBRARY_MOBILESUBSTRATE_MOBILESUBSTRATE_DYLIB] cStringUsingEncoding:NSUTF8StringEncoding], r);
    if (file) {
        fclose(file);
        return [BRJBString str:BR_JBSTR_MOBILESUBSTRATE_DYLIB];
    }
    
    file = fopen([[BRJBString str:BR_JBSTR__BIN_BASH] cStringUsingEncoding:NSUTF8StringEncoding], r);
    if (file) {
        fclose(file);
        return [BRJBString str:BR_JBSTR_BASH];
    }
    file = fopen([[BRJBString str:BR_JBSTR_SSHD] cStringUsingEncoding:NSUTF8StringEncoding], r);
    if (file) {
        fclose(file);
        return [BRJBString str:BR_JBSTR_SSHD];
    }
    file = fopen([[BRJBString str:BR_JBSTR_APT] cStringUsingEncoding:NSUTF8StringEncoding], r);
    if (file) {
        fclose(file);
        return [BRJBString str:BR_JBSTR_APT];
    }
    file = fopen([[BRJBString str:BR_JBSTR_SSH] cStringUsingEncoding:NSUTF8StringEncoding], r);
    if (file) {
        fclose(file);
        return [BRJBString str:BR_JBSTR_SSH];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[BRJBString str:BR_JBSTR__APPLICATIONS_CYDIA_APP]])
        return [BRJBString str:BR_JBSTR_CYDIA_APP];
    else if ([fileManager fileExistsAtPath:[BRJBString str:BR_JBSTR__LIBRARY_MOBILESUBSTRATE_MOBILESUBSTRATE_DYLIB]])
        return [BRJBString str:BR_JBSTR_MOBILESUBSTRATE_DYLIB];
    else if ([fileManager fileExistsAtPath:[BRJBString str:BR_JBSTR__BIN_BASH]])
        return [BRJBString str:BR_JBSTR_BASH];
    else if ([fileManager fileExistsAtPath:[BRJBString str:BR_JBSTR__USR_SBIN_SSHD]])
        return [BRJBString str:BR_JBSTR_SSHD];
    else if ([fileManager fileExistsAtPath:[BRJBString str:BR_JBSTR__ETC_APT]])
        return [BRJBString str:BR_JBSTR_APT];
    else if ([fileManager fileExistsAtPath:[BRJBString str:BR_JBSTR__USR_BIN_SSH]])
        return [BRJBString str:BR_JBSTR_SSH];
    
    // Omit logic below since they show warnings in the device log on iOS 9 devices.
    if (NSFoundationVersionNumber > 1144.17) // NSFoundationVersionNumber_iOS_8_4
        return nil;
    
    // Check if the app can access outside of its sandbox
    NSError *error = nil;
    [BR_JBSTR_APPLE writeToFile:[BRJBString str:BR_JBSTR__PRIVATE_JAILBREAK_TXT] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error)
        return [BRJBString str:BR_JBSTR_UNPROTECTED_SANDBOX];
    else
        [fileManager removeItemAtPath:[BRJBString str:BR_JBSTR__PRIVATE_JAILBREAK_TXT] error:nil];
    
    // Check if the app can open a Cydia's URL scheme
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[BRJBString str:BR_JBSTR_CYDIA_PACKAGE_COM_EXAMPLE_PACKAGE]]])
        return [BRJBString str:BR_JBSTR_CYDIA_APP];
    
#endif
    
    return nil;
}


+ (BOOL)isJailbroken {
    return [BRJBDetect jailbrakeMethod] != nil;
}


@end
