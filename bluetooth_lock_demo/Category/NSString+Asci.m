//
//  NSString+Asci.m
//  蓝牙
//
//  Created by Qson on 2021/4/20.
//  Copyright © 2021 Qson. All rights reserved.
//

#import "NSString+Asci.h"

@implementation NSString (Asci)

//字符串转成ascii字符串
+(NSString *)stringToAsci:(NSString *)string {
    NSMutableString *mustring = [[NSMutableString alloc]init];
    const char *ch = [string cStringUsingEncoding:NSASCIIStringEncoding];
    for (int i = 0; i < strlen(ch); i++) {
        [mustring appendString:[NSString stringWithFormat:@"%x",ch[i]]];
    }
    return mustring;
}

// ascii字符串转成data
+ (NSData*)hexToBytes:(NSString *)dataStr {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= dataStr.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [dataStr substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
        
    }
    return data;
}

// ascii字符串转成字符串
+ (NSString *)bytesTostring:(NSString *)dataStr {
    NSData *ssidData = [self hexToBytes:dataStr];
    NSString *value = [[NSString alloc] initWithData:ssidData encoding:NSUTF8StringEncoding];
    return value;
}

@end
