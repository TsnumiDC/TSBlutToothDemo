//
//  ViewController.m
//  TSBlueToothDemo
//
//  Created by Dylan Chen on 2017/9/5.
//  Copyright © 2017年 Dylan Chen. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ServiceController.h"

@interface ViewController ()<CBCentralManagerDelegate,UITableViewDelegate,UITableViewDataSource,CBPeripheralDelegate>

@property (strong,nonatomic)CBCentralManager * blueToothManager;
@property (strong,nonatomic)CBPeripheral * thePerpher;

@property (strong, nonatomic)UITableView * tableView;
@property (strong, nonatomic)UIView * headerView;
@property (strong, nonatomic)NSMutableArray * dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configSubView];
    
    [self layoutSubView];
}

- (void)configSubView{
    
    [self.view addSubview:self.tableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)layoutSubView{
    self.tableView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height-64);
}

#pragma mark - Action
- (void)startAction{
    //开始
    [self.blueToothManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopAction{
    //结束
    [self.blueToothManager stopScan];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"扫描连接外设：%@ %@",peripheral.name,RSSI);
    
    if (!peripheral.name || peripheral.name.length == 0) {
        return;
    }
    
    BOOL isShow = NO;
    for (CBPeripheral * per in self.dataArray ) {
        if ([per.name isEqualToString: peripheral.name]) {
            
            [self.dataArray replaceObjectAtIndex:[self.dataArray indexOfObject:per] withObject:peripheral];
            [self.tableView reloadData];
            isShow = YES;
            break;
        }
    }

    if (!isShow) {
        [self.dataArray addObject:peripheral];
        [self.tableView reloadData];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    NSLog(@"链接蓝牙失败:%@",peripheral.name);
    if (error) {
        NSLog(@"失败原因是:%@",error.localizedDescription);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //连接成功
    NSLog(@"链接设备成功:%@",peripheral.name);
    
    ServiceController * service = [ServiceController new];
    service.hardWarePerpher = peripheral;
    self.thePerpher = peripheral;
//    [peripheral setDelegate:self];
    
    [self.navigationController pushViewController:service animated:YES];
//    service.blueToothManager
    [self stopAction];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    NSLog(@"失去了和设备的的连接:%@",peripheral.name);
    [self.navigationController popToRootViewControllerAnimated:YES];
    if (error) {
    
        NSLog(@"失去原因是:%@,%ld",error.localizedDescription,error.code);
    }
    
}

//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict
//{
//    //恢复链接
//    NSLog(@"连接设别成功:%@",peripheral.name);
//
//}

//检测蓝牙的开启状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            //如果是关闭,系统会提示打开,我们不用管
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
            //打开的
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            break;
        default:
            break;
    }
}


//扫描到服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error){
        NSLog(@"扫描外设服务出错：%@-> %@", peripheral.name, [error localizedDescription]);
        return;
    }
    NSLog(@"扫描到外设服务：%@ -> %@",peripheral.name,peripheral.services);
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
    NSLog(@"开始扫描外设服务的特征 %@...",peripheral.name);
    
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"abcCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abcCell"];
    }
    CBPeripheral * peripheral = self.dataArray[indexPath.row];
    cell.textLabel.text = peripheral.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral * peripheral = self.dataArray[indexPath.row];
    
    self.thePerpher = peripheral;
    //进行连接
    [self.blueToothManager connectPeripheral:peripheral options:nil];

}
#pragma mark - Lazy
- (CBCentralManager *)blueToothManager{
    
    if (_blueToothManager == nil) {
        _blueToothManager =  [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    return _blueToothManager;
}

- (UITableView *)tableView{
    
    if (_tableView == nil) {
        _tableView = [UITableView new];
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"abcCell"];
    }
    return _tableView;
}

- (UIView *)headerView{
    
    if (_headerView == nil) {
        _headerView = [UIView new];
        _headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150);
        _headerView.backgroundColor = [UIColor yellowColor];
        
        UIButton * startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [startBtn setTitle:@"开始扫描" forState:UIControlStateNormal];
        [_headerView addSubview:startBtn];
        startBtn.backgroundColor = [UIColor orangeColor];
        [startBtn addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton * stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_headerView addSubview:stopBtn];
        [stopBtn setTitle:@"结束扫描" forState:UIControlStateNormal];
        stopBtn.backgroundColor = [UIColor blueColor];
        [stopBtn addTarget:self action:@selector(stopAction) forControlEvents:UIControlEventTouchUpInside];
        
        startBtn.frame = CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width/2, 80);
        stopBtn.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width/2, 30, [UIScreen mainScreen].bounds.size.width/2, 80);
    }
    return _headerView;
}

- (NSMutableArray *)dataArray{
    
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - dealloc
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}















@end
