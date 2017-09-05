//
//  ServiceController.m
//  TSBlueToothDemo
//
//  Created by Dylan Chen on 2017/9/5.
//  Copyright © 2017年 Dylan Chen. All rights reserved.
//

#import "ServiceController.h"

@interface ServiceController ()<CBPeripheralDelegate>

@end

@implementation ServiceController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configSubViews];
    
    [self layoutSubViews];
    // Do any additional setup after loading the view.
}

- (void)configSubViews
{
    self.title = self.hardWarePerpher.name;
    [self.hardWarePerpher setDelegate:self];
}

- (void)layoutSubViews
{
    
}

#pragma mark - CBPeripheralDelegate
//扫描到服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error)
    {
        NSLog(@"扫描外设服务出错：%@-> %@", peripheral.name, [error localizedDescription]);
        return;
    }
    NSLog(@"扫描到外设服务：%@ -> %@",peripheral.name,peripheral.services);
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
    NSLog(@"开始扫描外设服务的特征 %@...",peripheral.name);
    
}

//扫描到特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error)
    {
        NSLog(@"扫描外设的特征失败！%@->%@-> %@",peripheral.name,service.UUID, [error localizedDescription]);
        return;
    }
    
    NSLog(@"扫描到外设服务特征有：%@->%@->%@",peripheral.name,service.UUID,service.characteristics);
    //获取Characteristic的值
    for (CBCharacteristic *characteristic in service.characteristics){
        
        //这里外设需要订阅特征的通知，否则无法收到外设发送过来的数据
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        
        //这里以小米手环为例，当我们定义好每个特征是干什么用的，我们需要读取这个特征的值,当特征值更新了会调用
        //- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error方法
        //需要说明的是UUID是硬件定义好给你，如果硬件也是个新手，那你可以先打印出所有的UUID,找出有用的
        //步数
        if ([characteristic.UUID.UUIDString isEqualToString:@"FF06"])
        {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        //电池电量
        else if ([characteristic.UUID.UUIDString isEqualToString:@"FF0C"])
        {
            [peripheral readValueForCharacteristic:characteristic];
        }
        
        else if ([characteristic.UUID.UUIDString isEqualToString:@"2A06"])
        {
            //震动
           // theSakeCC = characteristic;
        }
        
    }
}

//扫描到具体的值->通讯主要的获取数据的方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"扫描外设的特征失败！%@-> %@",peripheral.name, [error localizedDescription]);
        return;
    }
    NSLog(@"%@ %@",characteristic.UUID.UUIDString,characteristic.value);
    if ([characteristic.UUID.UUIDString isEqualToString:@"FF06"]) {
        Byte *steBytes = (Byte *)characteristic.value.bytes;
        int steps = bytesValueToInt(steBytes);
        NSLog(@"步数: %d",steps);
    }
    else if ([characteristic.UUID.UUIDString isEqualToString: @"FF0C"])
    {
        Byte *bufferBytes = (Byte *)characteristic.value.bytes;
        int buterys = bytesValueToInt(bufferBytes)&0xff;
        NSLog(@"电池：%d%%",buterys);
        
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:@"2A06"])
    {
        Byte *infoByts = (Byte *)characteristic.value.bytes;
        //这里解析infoByts得到设备信息
    }
    
}

#pragma mark - Method
unsigned int  bytesValueToInt(Byte *bytesValue) {
    
    unsigned int  intV;
    intV = (unsigned int ) ( ((bytesValue[3] & 0xff)<<24)
                            |((bytesValue[2] & 0xff)<<16)
                            |((bytesValue[1] & 0xff)<<8)
                            |(bytesValue[0] & 0xff));
    return intV;
}


#pragma mark - dealloc
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
