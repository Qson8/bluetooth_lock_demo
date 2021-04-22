//
//  ViewController.m
//  蓝牙
//
//  Created by Qson on 2020/5/26.
//  Copyright © 2020 Qson. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "BLEServer.h"

@interface ViewController () <BLEServerDelegate>
@property (nonatomic, strong) BLEArgModel *model;
@end

@implementation ViewController

// 参数
- (BLEArgModel *)model {
    if(_model == nil) {
        BLEArgModel *model = [[BLEArgModel alloc] init];
        model.token = @"AC0105c523c9affe74a78f261483472f180b70";
        model.peripheral_name = @"XM-";
        model.service_uuid_fragments = @[@"0886",@"ffe0"];
        model.notify_characteristics_name = @"878B";
        model.characteristics_name = @"878C";
        model.result_verify = @"c8";
        _model = model;
    }
    return _model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultStyle:(SVProgressHUDStyleDark)];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = UITextAlignmentCenter;
    label.text = @"开 锁";
    [self.view addSubview:label];
    
    CGFloat w = 100;
    CGFloat h = 30;
    CGFloat x = ([UIScreen mainScreen].bounds.size.width - w) * 0.5;
    CGFloat y = 50;
    label.frame = CGRectMake(x, y, w, h);
    
    w = 100;

    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:@"开锁" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(action:) forControlEvents:(UIControlEventTouchUpInside)];
    btn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - w) * 0.5, ([UIScreen mainScreen].bounds.size.height - w) * 0.5, w, w);
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor orangeColor];
    btn.layer.cornerRadius = w * 0.5;
    

}

- (void)action:(UIButton *)btn {

    // 准备连接蓝牙
    [BLEServer share].delegate = self;
    
    [BLEServer share].model = self.model;
    [[BLEServer share] startConnect];
}


#pragma mark - BLEServer
- (void)ble_prepareConnect {
    [SVProgressHUD showWithStatus:@"连接电子锁"];
}

- (void)ble_connectFail {
    [SVProgressHUD showWithStatus:@"连接失败"];
}

- (void)ble_openBluetooth {
    [SVProgressHUD showWithStatus:@"请打开蓝牙"];
}

- (void)ble_connectSucceed {
    [SVProgressHUD showWithStatus:@"电子锁已连接"];
}

- (void)ble_receivedValue:(NSString *)value {
    if([value.lowercaseString hasSuffix:@"c8"]) {
        [SVProgressHUD showSuccessWithStatus:@"开锁成功"];
    }
}


@end
