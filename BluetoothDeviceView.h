//
//  BluetoothDeviceView.h
//  BluePrint_Demo
//
//  Created by Eric周 on 15/10/17.
//  Copyright © 2015年 Eric周. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothInfo.h"
#import "SVProgressHUD.h"



@interface BluetoothDeviceView : UIViewController<UITableViewDataSource,UITableViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic,strong) CBCentralManager *centraManager; //中心
@property (nonatomic,strong) NSMutableArray *arrayBluetooth; //外设
@property (nonatomic,strong) CBPeripheral *peripheral; //设备服务
@property (nonatomic,strong) CBCharacteristic* writeCharacteristic; //服务特征
@property (nonatomic,strong) UIView *BletoohView;


@property(nonatomic,strong) UITableView *tableView;


@end
