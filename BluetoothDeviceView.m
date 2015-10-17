//
//  BluetoothDeviceView.m
//  BluePrint_Demo
//
//  Created by Eric周 on 15/10/17.
//  Copyright © 2015年 Eric周. All rights reserved.
//

#define kServiceUUID @"FFE0"
#define kCharacteristicUUID @"FFE1"

#import "BluetoothDeviceView.h"

@interface BluetoothDeviceView (){
    NSTimer *connectTimer;
    UIButton *Print;

}

@end

@implementation BluetoothDeviceView
@synthesize tableView = _tableView;
//界面退出
//-(void)viewWillDisappear:(BOOL)animated{
//    [self.centraManager cancelPeripheralConnection:self.peripheral];
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"连接蓝牙";
    //1建立中心角色
    
    self.centraManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.arrayBluetooth = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.BletoohView = [[UIView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width-0, self.view.bounds.size.height-300)];
    [self.view addSubview:self.BletoohView];
    
    
    Print = [[UIButton alloc]initWithFrame:CGRectMake(0, self.BletoohView.bounds.size.height +110, self.view.bounds.size.width, 50)];
    Print.backgroundColor = [UIColor redColor];
    [Print setTitle:@"打印" forState:UIControlStateNormal];
    [Print addTarget:self action:@selector(connectTimeout:) forControlEvents:UIControlEventTouchUpInside];
    Print.hidden = YES;
    [self.view addSubview:Print];
    
    [self initTableView];


}
-(void)initTableView{
    _tableView = [[UITableView alloc]initWithFrame:self.BletoohView.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.BletoohView addSubview:_tableView];
}
//蓝牙状态delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            [self.centraManager scanForPeripheralsWithServices:nil options:nil];
            NSLog(@"start  Peripherals");
            
            break;
            
        default:
            NSLog(@"CentrManager did change state");
            break;
    }
}
//连接外设(connect)  发现设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    //如果周围的蓝牙有多个，则这个方法会被调用多次，你可以通过tableView或其他的控件把这些周围的蓝牙的信息打印出来
    [SVProgressHUD showInfoWithStatus:@"准备连接设备"];

    NSString *str = [NSString stringWithFormat:@"Did discover peripheral. peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.name, advertisementData];
    NSLog(@"设备信息:%@",str);
    
    
    BluetoothInfo *discoveredBlueInfo = [[BluetoothInfo alloc]init];
    discoveredBlueInfo.discoveredPeripheral = peripheral;
    discoveredBlueInfo.rssi = RSSI;
    
    [self saveBluetooth:discoveredBlueInfo];
    

    
}
//保存设备信息
-(BOOL)saveBluetooth:(BluetoothInfo *)discoverBlueInfo{
    for (BluetoothInfo *info in self.arrayBluetooth) {
        if ([info.discoveredPeripheral.identifier.UUIDString isEqualToString:discoverBlueInfo.discoveredPeripheral.identifier.UUIDString]) {
            return NO;
        }
    }
    
    NSLog(@"\nDiscover New Devices!\n");
    NSLog(@"discoverBlueInfo\n UUID：%@\n RSSI:%@\n\n",discoverBlueInfo.discoveredPeripheral.identifier.UUIDString,discoverBlueInfo.rssi);
    [self.arrayBluetooth addObject:discoverBlueInfo];
    [_tableView reloadData];
    return YES;
}
//连接指定的设备(单独连接自己打印机的UUID)
-(BOOL)connectWithUUID:(CBPeripheral *)peripheral{
    NSLog(@"connect start");
    [self.centraManager connectPeripheral:peripheral
                                  options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    
    
    
    return (YES);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.arrayBluetooth.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"cell"];
    // Step 2: If there are no cells to reuse, create a new one
    if(cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    // Add a detail view accessory
    BluetoothInfo *blueInfo=[self.arrayBluetooth objectAtIndex:indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@ %@",blueInfo.discoveredPeripheral.name,blueInfo.rssi];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"UUID:%@",blueInfo.discoveredPeripheral.identifier.UUIDString];
    // Step 3: Set the cell text
    
    // Step 4: Return the cell
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BluetoothInfo *blueInfo=[self.arrayBluetooth objectAtIndex:indexPath.row];

        //扫描完成后,连一个蓝牙(peripheral)
            [self.centraManager stopScan];
            [SVProgressHUD showInfoWithStatus:@"连接外设"];

            [self.centraManager connectPeripheral:blueInfo.discoveredPeripheral options:nil];
            NSLog(@"连接外设:%@",blueInfo.discoveredPeripheral.description);
            self.peripheral = blueInfo.discoveredPeripheral;

    
 
}

#pragma  -mark -     连接之后 ------------------------------------------------------
//4扫描外设中的服务和特征(discover)
//当连接上某个蓝牙之后，CBCentralManager会通知代理处理

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [SVProgressHUD showInfoWithStatus:@"连接成功"];

    [self.centraManager stopScan];
    NSLog(@"Did connect to peripheral: %@", peripheral);
    //因为在后面我们要从外设蓝牙那边再获取一些信息，并与之通讯，这些过程会有一些事件可能要处理，所以要给这个外设设置代理，比如
    [peripheral setDelegate:self];
    //查询蓝牙服务
    [peripheral discoverServices:nil];
    Print.hidden = NO;
    
    
}
//返回的蓝牙服务通知通过代理实现//搜索服务的Delegate 若发现服务，然后搜索其内的特征服务

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    if (error)
    {
        NSLog(@"无服务 DiscoverServices : %@", [error localizedDescription]);
        return;
    }
    for (CBService* service in peripheral.services){
        //查询服务所带的特征值(我自己打印机的FFE0服务)
        NSLog(@"Service found with UUID: %@", service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) {
            NSLog(@"发现服务>>>服务UUID found with UUID : %@ 描述 des:%@", service.UUID,service.UUID.description);
            
            [peripheral discoverCharacteristics:nil forService:service];
        }
        
    }
    
}
//========================================================================================
//4.搜索特征的Delegate 若发现特征，则看看这个“通道是发送的还是接收”，接收就read，发送就把这个writeCharacteristic记录下
//注意：不是所有的特性值都是可读的（readable）。通过访问 CBCharacteristicPropertyRead 可以知道特性值是否可读。如果一个特性的值不可读，使用 peripheral:didUpdateValueForCharacteristic:error:就会返回一个错误。
//Subscribing to a Characteristic’s Value(订制一个特性值) 尽管通过 readValueForCharacteristic:方法能够得到特性值，但是对于一个变化的特性值就不是很 有效了。大多数的特性值是变化的，比如一个心率监测应用，如果需要得到特性值，就需要 通过预定的方法获得。当预定了一个特性值，当值改变时，就会收到设备发出的通知。
//返回的蓝牙特征值通知通过代理实现
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"didDiscoverCharacteristicsForService error : %@", [error localizedDescription]);
        return;
    }
    for (CBCharacteristic * characteristic in service.characteristics) {
        NSLog(@"\n>>>\t特征UUID FOUND(in 服务UUID:%@): 数据%@ (data:%@)",service.UUID.description,characteristic.UUID,characteristic.UUID.data);
        
        //假如你和硬件商量好了，某个UUID时写，某个读的，那就不用判断啦
        
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]]){
            NSLog(@"监听特征:%@",characteristic);//监听特征
            self.peripheral = peripheral;
            self.writeCharacteristic = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.writeCharacteristic];
//            ////开一个定时器打印输出
//            connectTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(connectTimeout:) userInfo:peripheral repeats:NO];
        }
    }
    
}
//文本打印
-(void)connectTimeout:(id)sender{
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *string  = @"//////////////////////////////////\n测试打印       18612699953\n换行打印       what,s your name ?\n再次换行\n你愁啥?\n瞅你咋地?\nO(∩_∩)O~\n\n///////////////////////////////////\n\n\n\n\n\n\n\n";
    
    NSData *data = [string dataUsingEncoding:gbkEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
}
//(发送数据)这时还会触发一个代理事件
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error)
    {
        NSLog(@"发送数据特征值%@时发生错误:%@", characteristic.UUID, [error localizedDescription]);
        return;
    }
}
//处理蓝牙发过来的数据(单打印,这块无用)
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error)
    {
        NSLog(@"更新特征值%@时发生错误:%@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    // 收到数据
    NSLog(@"%@",[self hexadecimalString:characteristic.value]);
}

#pragma mark - NSData and NSString

//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}
//将传入的NSString类型转换成NSData并返回
- (NSData*)dataWithHexstring:(NSString *)hexstring{
    NSData* aData;
    return aData = [hexstring dataUsingEncoding: NSASCIIStringEncoding];
}


@end
