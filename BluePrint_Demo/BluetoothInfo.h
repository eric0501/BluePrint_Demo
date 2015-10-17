//
//  BluetoothInfo.h
//  蓝牙打印
//
//  Created by Eric周 on 15/10/16.
//  Copyright © 2015年 Eric周. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothInfo : NSObject

@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (nonatomic, strong) NSNumber *rssi;

@end
