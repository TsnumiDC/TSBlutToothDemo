//
//  ServiceController.m
//  TSBlueToothDemo
//
//  Created by Dylan Chen on 2017/9/5.
//  Copyright © 2017年 Dylan Chen. All rights reserved.
//

#import "ServiceController.h"
#define CELL_IDE @"cellideadfadf"
#import "TSDeviceCell.h"

@interface ServiceController ()<CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BOOL _isShake;
}
@property (strong, nonatomic)UITableView * tableView;

@end

@implementation ServiceController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configSubViews];
    
    [self layoutSubViews];
    // Do any additional setup after loading the view.
}

- (void)configSubViews{
    
    self.title = self.hardWarePerpher.name;
    self.hardWarePerpher.delegate = self;
    [self.hardWarePerpher discoverServices:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.hardWarePerpher serv
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    _isShake = NO;
}

- (void)layoutSubViews{
    
    self.tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
}

#pragma mark - CBPeripheralDelegate
//扫描到服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error){
        NSLog(@"扫描外设服务出错：%@-> %@", peripheral.name, [error localizedDescription]);
        return;
    }
    NSLog(@"扫描到外设服务：%@ -> %@",peripheral.name,peripheral.services);
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
        //添加到数组
        //[self.serviceArray addObject:service];
        [self.tableView reloadData];
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
    [self.tableView reloadData];
}

//扫描到具体的值->通讯主要的获取数据的方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"扫描外设的特征失败！%@-> %@",peripheral.name, [error localizedDescription]);
        return;
    }
    
    //添加到数组
    
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
        NSString * string = [[NSString alloc]initWithBytes:infoByts length:0 encoding:NSUTF8StringEncoding];
        NSLog(@"设备信息: %@",string);
        //这里解析infoByts得到设备信息
    }
    
    [self.tableView reloadData];
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

#pragma mark - UITableViewDelegate/UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TSDeviceCell * cell = [TSDeviceCell cellWithTableView:tableView];

    CBService * service = self.hardWarePerpher.services[indexPath.section];
    CBCharacteristic * cha = service.characteristics[indexPath.row];
    
    cell.titleLabel.text = cha.UUID.UUIDString?cha.UUID.UUIDString:@"";
    
    //Byte *steBytes = (Byte *)cha.value.bytes?(Byte *)cha.value.bytes:0;
    
    NSString * string = [[NSString alloc]initWithData:cha.value?cha.value:[NSData new] encoding:NSUTF8StringEncoding];
    NSLog(@"字符串值: %@",string);
    
   // int steps = 0;

//    @try {
//       // steps = bytesValueToInt(steBytes);
//    } @catch (NSException *exception) {} @finally {}
    

    cell.detailLabel.text = [NSString stringWithFormat:@"值: %@",string];
    
    
    
    //做转换
    if ([cha.UUID.UUIDString isEqualToString:@"FF06"]) {
        
        if(cha.value)
        {
            Byte *steBytes = (Byte *)cha.value.bytes;
            int steps = bytesValueToInt(steBytes);
            cell.titleLabel.text = [NSString stringWithFormat:@"%@ (步数)",cha.UUID.UUIDString];
            cell.detailLabel.text = [NSString stringWithFormat:@"值: %d",steps];
        }
        

    }
    else if ([cha.UUID.UUIDString isEqualToString: @"FF0C"]){

        if(cha.value){
            Byte *bufferBytes = (Byte *)cha.value.bytes;
            int buterys = bytesValueToInt(bufferBytes)&0xff;
            cell.titleLabel.text = [NSString stringWithFormat:@"%@ (电池)",cha.UUID.UUIDString];
            cell.detailLabel.text = [NSString stringWithFormat:@"值: %d",buterys];
        }
    }
    else if ([cha.UUID.UUIDString isEqualToString:@"2A06"]){
        
        Byte *infoByts = (Byte *)cha.value.bytes;
        NSString * string = [[NSString alloc]initWithBytes:infoByts length:0 encoding:NSUTF8StringEncoding];
        NSLog(@"震动: %@",string);
        //这里解析infoByts得到设备信息
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ (震动:)",cha.UUID.UUIDString];
        cell.detailLabel.text = [NSString stringWithFormat:@"值: %@",string];
    }

    
    //
//    cell.detailTextLabel.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    CBService * service = self.hardWarePerpher.services[section];
    return service.characteristics.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    CBService * service = self.hardWarePerpher.services[section];
    NSString * name = service.UUID.UUIDString;
    return [NSString stringWithFormat:@"服务%ld -> UUID: %@",section,name];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.hardWarePerpher.services.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //震动
    CBService * service = self.hardWarePerpher.services[indexPath.section];
    CBCharacteristic * character = service.characteristics[indexPath.row];
    if ([character.UUID.UUIDString isEqualToString:@"2A06"]) {
        
        if (!_isShake) {
            Byte zd[1] = {2};//1 轻微震动 2 强烈震动
            NSData *theData = [NSData dataWithBytes:zd length:1];
            [self.hardWarePerpher writeValue:theData forCharacteristic:character type:CBCharacteristicWriteWithoutResponse];
        }else{
            Byte zd[1] = {0};
            NSData *theData = [NSData dataWithBytes:zd length:1];
            [self.hardWarePerpher writeValue:theData forCharacteristic:character type:CBCharacteristicWriteWithoutResponse];
        }
        _isShake = !_isShake;

    }
    
//    for (CBService * service in self.hardWarePerpher.services) {
//        for (CBCharacteristic * character in service.characteristics) {
//            if ([character.UUID.UUIDString isEqualToString:@"2A06"]) {
//                
//                Byte zd[1] = {2};
//                NSData *theData = [NSData dataWithBytes:zd length:1];
//                [self.hardWarePerpher writeValue:theData forCharacteristic:character type:CBCharacteristicWriteWithoutResponse];
//
//            }
//        }
//    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

#pragma mark - Lazy

- (UITableView *)tableView{
    
    if (_tableView == nil) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
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
