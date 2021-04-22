//
//  NSString+Asci.h
//  蓝牙
//
//  Created by Qson on 2021/4/20.
//  Copyright © 2021 Qson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Asci)

//字符串转成ascii字符串
+(NSString *)stringToAsci:(NSString *)string;
// ascii字符串转成data
+ (NSData*)hexToBytes:(NSString *)dataStr;
// ascii字符串转成字符串
+ (NSString *)bytesTostring:(NSString *)dataStr;
@end

NS_ASSUME_NONNULL_END
