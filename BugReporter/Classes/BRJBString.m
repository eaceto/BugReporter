//
//  BRJBString.m
//  Pods
//
//  Created by Kimi on 12/26/16.
//
//

#import "BRJBString.h"
#import "Base64.h"

@implementation BRJBString

#define XOR_KEY_HALF_1 @"iR+mimNnlOo9jw=="
#define XOR_KEY_HALF_2 @"/nDK7BEG+cRU4A=="

+(NSString*)str:(NSString*)str {
    NSData *p0 = [NSData dataWithBase64EncodedString:XOR_KEY_HALF_1];
    NSData *p1 = [NSData dataWithBase64EncodedString:XOR_KEY_HALF_2];
    
    NSUInteger numberOfBytes = [p0 length];
    Byte xorParts0[numberOfBytes];
    [p0 getBytes:xorParts0 range:NSMakeRange(0, numberOfBytes)];
    
    Byte xorParts1[numberOfBytes];
    [p1 getBytes:xorParts1 range:NSMakeRange(0, numberOfBytes)];
    
    Byte xorKey[numberOfBytes];
    for (int i = 0; i < numberOfBytes; i++) {
        xorKey[i] = (Byte) (xorParts0[i] ^ xorParts1[i]);
    }
    
    NSData *d = [NSData dataWithBase64EncodedString:str];
    return [BRJBString xor:d withKey:xorKey ofLength:numberOfBytes];
    
    return str;
}

+ (NSString*)xor:(NSData*)a withKey:(Byte[])key ofLength:(NSUInteger) len {
    Byte input[a.length];
    [a getBytes:input range:NSMakeRange(0, a.length)];
    
    Byte o[a.length + 1];
    int i = 0;
    for (; i < a.length; i++) {
        o[i] = (Byte) (input[i] ^ key[i % len]);
    }
    o[i] = 0;
    NSString* string = [NSString stringWithUTF8String: o];
    return string;
}

@end
