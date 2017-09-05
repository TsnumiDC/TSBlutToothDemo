//
//  ViewController.m
//  TSBlueToothDemo
//
//  Created by Dylan Chen on 2017/9/5.
//  Copyright © 2017年 Dylan Chen. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<CBCentralManagerDelegate,UITableViewDelegate,UITableViewDataSource>

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
    self.tableView.frame = CGRectMake(64, 0, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.height-64);
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
    
    [self.dataArray addObject:peripheral];
    [self.tableView reloadData];
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
    
    
    
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    NSLog(@"失去了和设备的的连接:%@",peripheral.name);
    if (error) {
        NSLog(@"失去原因是:%@",error.localizedDescription);
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
        [startBtn addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton * stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_headerView addSubview:stopBtn];
        [stopBtn setTitle:@"结束扫描" forState:UIControlStateNormal];
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
