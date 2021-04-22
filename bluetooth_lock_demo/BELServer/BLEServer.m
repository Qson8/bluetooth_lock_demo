//
//  BLEServer.m
//  蓝牙
//
//  Created by Qson on 2021/4/22.
//  Copyright © 2021 Qson. All rights reserved.
//

#import "BLEServer.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "NSString+Asci.h"
#import "NSData+Switch.h"

@interface BLEServer () <CBCentralManagerDelegate,CBPeripheralDelegate>
// 中心
@property (nonatomic, strong) CBCentralManager *centralManager;
// 外设
@property (nonatomic,strong) CBPeripheral *peripheral;
// 通知特征(读数据用)
@property (nonatomic,strong) CBCharacteristic *notifyCharteristic;
// 特征(写数据)
@property (nonatomic, strong) CBCharacteristic *characteristic;
@end

@implementation BLEServer {
    //【*必须*】用于保存被发现设备
    NSMutableArray *_discoverPeripherals;
}

/**
 开始连接蓝牙
 */
- (void)startConnect {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ble_prepareConnect)]) {
        [self.delegate ble_prepareConnect];
    }
    
    //初始化中心端,开始蓝牙模块
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.centralManager.delegate = self;
    
    //【*必须*】持有发现的设备,如果不持有设备会导致CBPeripheralDelegate方法不能正确回调
    _discoverPeripherals = [NSMutableArray array];
}


//断开连接
- (void)endConnect {
    [self.centralManager cancelPeripheralConnection:self.peripheral];
    _centralManager = nil;
}

#pragma mark - CBCentralManagerDelegate
// 状态更新后触发
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOff:{
            NSLog(@"蓝牙关闭");
            //检测到蓝牙没打开需要通知代理控制器去执行相关提示操作
            if (self.delegate && [self.delegate respondsToSelector:@selector(ble_openBluetooth)])
            {
                [self.delegate ble_openBluetooth];
            };
        }
            break;
        case CBManagerStatePoweredOn:
            break;
        case CBManagerStateResetting:
            break;
        case CBManagerStateUnauthorized:
            break;
        case CBManagerStateUnknown:
            break;
        case CBManagerStateUnsupported:
            break;
        default:
            break;
    }
    
    // 开始扫描外设
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@NO};
    [central scanForPeripheralsWithServices:nil options:options];
}

// 扫描到外部设备后触发的代理方法//多次调用的
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI {
    NSString *msg = [NSString stringWithFormat:@"信号强度: %@, 外设: %@", RSSI, peripheral];
    NSLog(@"%@",msg);

    if ([peripheral.name.lowercaseString containsString:_model.peripheral_name.lowercaseString]) {
        //【*必须*】如果比放入数组，可能出现问题，已验证
        [_discoverPeripherals addObject:peripheral];
        
        //连接外部设备
        [central connectPeripheral:peripheral options:nil];
        
        //停止搜索
        [central stopScan];
    }
}

/** 连接到Peripherals-失败 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接失败%@",error.localizedDescription);
    
    [_discoverPeripherals removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(ble_connectFail)]) {
        [self.delegate ble_connectFail];
    }
}

// 当中心端连接上外设时触发
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"连接上外设");
    [central stopScan];
    if ([self.delegate respondsToSelector:@selector(ble_connectSucceed)]) {
        [self.delegate ble_connectSucceed];
    }
    
    _peripheral = peripheral;
    peripheral.delegate = self;
    // 发现服务
    [peripheral discoverServices:nil];
}

// 如果连接上的两个设备突然断开了，程序里面会自动回调下面的方法
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [_discoverPeripherals removeAllObjects];
    NSLog(@"已经断开蓝牙连接");
}

#pragma mark - CBPeripheralDelegate
// 外设端发现了服务时触发
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services)  {
        // 过滤目标服务
        for (NSString *ser_uuid in _model.service_uuid_fragments) {
            if([service.UUID.UUIDString.lowercaseString containsString:ser_uuid.lowercaseString]) {
                // 对指定服务进行【发现特征】 操作
                [peripheral discoverCharacteristics:nil forService:service];
                break;
            }
        }
    }
}

// 发现到服务特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
   NSLog(@"%@",service.characteristics);
    for (CBCharacteristic *characteristic in service.characteristics) {
        // 过滤特征 找到【notify特征】和【写数据特征】
        if([characteristic.UUID.UUIDString.lowercaseString isEqualToString:_model.characteristics_name.lowercaseString]) {
            self.characteristic = characteristic;
        }
        
        if([characteristic.UUID.UUIDString.lowercaseString isEqualToString:_model.notify_characteristics_name.lowercaseString]) {
            self.notifyCharteristic = characteristic;
            
            // 该方法是设置通知或指示，会回调代理方法didUpdateValueForCharacteristic，在代理方法中拿到通知的内容
            // 类似 [_peripheral setNotifyValue:YES forCharacteristic:_notifyCharteristic];
//            [peripheral readValueForCharacteristic:characteristic];
            
            // 注：实现下面方法才能读取到notifyCharteristic回调方法
            [peripheral discoverDescriptorsForCharacteristic:characteristic];
        }
        
    }

    // 写数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self writeData];
    });
}

// 收到数据,会掉该方法通知代理接受数据，并解析数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    // 数据解析成的十六进制字符串
    NSString *hexStr = [characteristic.value convertDataToHexStr];
    
    NSLog(@"characteristic uuid:%@  value:%@ 解析后的十六进制字符串:%@",characteristic.UUID,characteristic.value,hexStr);
    if ([self.delegate respondsToSelector:@selector(ble_receivedValue:)]) {
        [self.delegate ble_receivedValue:hexStr];
    }
}

//  写数据后回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic  error:(NSError *)error {
    if (error) {
        NSLog(@"Error writing characteristic value: %@",
              [error localizedDescription]);
        return;
    }
    NSLog(@"写入%@成功",characteristic);
}

#pragma mark - 业务逻辑
/**
 打开蓝牙
 */
- (void)open {
    NSData *data = [@"&1&1&1&1" dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:0x04];
     [self.peripheral setNotifyValue:YES forCharacteristic:self.notifyCharteristic];
}

/**
 关闭蓝牙
 */
- (void)close {
    NSData *data = [@"&&&2&" dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:0x04];
     [self.peripheral setNotifyValue:YES forCharacteristic:self.notifyCharteristic];
}

- (void)writeData {
    NSData *date = [NSString hexToBytes:_model.token];
    
    [self sendMsgWithSubPackage:date peripheral:_peripheral characteristic:_characteristic];
    NSLog(@"写入data:%@",date);
}

static int BLE_SEND_MAX_LEN = 20;
//分包发送蓝牙数据
- (void)sendMsgWithSubPackage:(NSData*)msgData peripheral:(CBPeripheral*)peripheral characteristic:(CBCharacteristic*)character {
    for (int i = 0; i < [msgData length]; i += BLE_SEND_MAX_LEN) {
        // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
        if ((i + BLE_SEND_MAX_LEN) < [msgData length]) {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, BLE_SEND_MAX_LEN];
            NSData *subData = [msgData subdataWithRange:NSRangeFromString(rangeStr)];
            NSLog(@"%@",subData);
            
            [_peripheral writeValue:subData forCharacteristic:_characteristic type:0x04];
            // notify特性的值设置通知或指示。有通知会回调代理方法didUpdateValueForCharacteristic，在代理方法中拿到通知的内容
            [_peripheral setNotifyValue:YES forCharacteristic:_notifyCharteristic];
            
            //根据接收模块的处理能力做相应延时
            usleep(20 * 1000);
        }
        else {
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, (int)([msgData length] - i)];
            NSData *subData = [msgData subdataWithRange:NSRangeFromString(rangeStr)];
            
            [_peripheral writeValue:subData forCharacteristic:_characteristic type:0x04];
            // notify特性的值设置通知或指示。有通知会回调代理方法didUpdateValueForCharacteristic，在代理方法中拿到通知的内容
            [_peripheral setNotifyValue:YES forCharacteristic:_notifyCharteristic];
            
            usleep(20 * 1000);
        }
    }
}

#pragma mark - 初始化
// 类方法 返回实例
+ (instancetype)manager {
    BLEServer *obj = [[self alloc] init];
    return obj;
}

#pragma mark - 单例
+ (instancetype)share {
    static BLEServer *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self manager];
    });
    
    return _sharedManager;
}
@end


#pragma mark - BLEArgModel
@implementation BLEArgModel

@end
