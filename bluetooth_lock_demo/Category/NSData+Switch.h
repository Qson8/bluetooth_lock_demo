//
//  NSData+Switch.h
//  蓝牙
//
//  Created by Qson on 2021/4/20.
//  Copyright © 2021 Qson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Switch)
/**
 NSData 转  十六进制string
 
 @return NSString类型的十六进制string
 */
- (NSString *)convertDataToHexStr;




/**
 NSData 转 十进制 字符串(常规字符串)
 
 @return NSString类型的字符串
 */
- (NSString *)dataToString;

@end

NS_ASSUME_NONNULL_END
