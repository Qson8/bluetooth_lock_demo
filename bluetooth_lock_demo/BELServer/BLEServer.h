//
//  BLEServer.h
//  蓝牙
//
//  Created by Qson on 2021/4/22.
//  Copyright © 2021 Qson. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BLEServer,BLEArgModel;
NS_ASSUME_NONNULL_BEGIN

/**
 蓝牙中心角色 蓝牙服务代理
 */
@protocol BLEServerDelegate <NSObject>
@optional

/**
 准备连接蓝牙
 */
- (void)ble_prepareConnect;
/**
 蓝牙连接成功
 */
- (void)ble_connectSucceed;

/**
 收到的通知数据
 */
- (void)ble_receivedValue:(NSString *)value;

/**
 打开蓝牙提示
 */
-(void)ble_openBluetooth;

/**
 连接蓝牙失败
 */
-(void)ble_connectFail;

@end

/**
 蓝牙中心角色 蓝牙服务管理类
*/
@interface BLEServer : NSObject
@property (nonatomic, weak) id<BLEServerDelegate>delegate;
@property (nonatomic, strong) BLEArgModel *model;

+ (instancetype)share;

//开始连接
- (void)startConnect;
//断开连接
- (void)endConnect;
- (void)open;
- (void)close;
@end


/*
 参数模型，提供必要数据
 */
@interface BLEArgModel : NSObject

/**
 写入的密钥
 */
@property (nonatomic, strong) NSString *token;

/**
 需要指定的外设名 或者部分字符匹配
 */
@property (nonatomic, strong) NSString *peripheral_name;
/**
 uuid片段数组   需要指定的外设【服务】名数组，可能是全称或部分字符
 */
@property (nonatomic, strong) NSArray <NSString *>*service_uuid_fragments;
/**
 服务中通知的特征   可能是全称或部分字符
 */
@property (nonatomic, strong) NSString *notify_characteristics_name;
/**
 服务中写数据的特征   可能是全称或部分字符
 */
@property (nonatomic, strong) NSString *characteristics_name;

/**
 结果验证的值 （一般写数组后，notifyCharteristic返回的结果）
 */
@property (nonatomic, strong) NSString *result_verify;

@end

NS_ASSUME_NONNULL_END
