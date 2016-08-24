//
//  ViewController.m
//  UDisk
//
//  Created by shiki on 16/8/9.
//  Copyright © 2016年 两仪式. All rights reserved.
//

#import "ViewController.h"
#import "FileSystem.h"
#import "Filelist.h"
#import "FileIO.h"
extern struct CBW           cbwCmd;
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *table;
@property(nonatomic,strong)NSMutableArray *backArray;
@property(nonatomic,strong)FileSystem *system;
@property(nonatomic,strong)NSArray *supportMediaFiletype;
@property(nonatomic,strong)NSArray *supportDocumentFiletype;
@property(nonatomic,strong)NSArray *supportImageFileType;
@property(nonatomic,strong)NSMutableArray *finalArray;
@property(nonatomic,strong)NSString *currentname;
@property(nonatomic,strong)NSString *_currenttype;
@property(nonatomic,strong)NSURL *finalurl;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceived:) name:EADSessionDataReceivedNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    self.table = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.system = [[FileSystem alloc]init];
    [self.view addSubview:self.table];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.table registerNib:[UINib nibWithNibName:@"Filelist" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"123"];
    self._eaSessionController = [EADSessionController sharedController];
    self.supportImageFileType = @[@"jpg",@"png",@"bmp",@"jpeg",@"gif"];
    self.supportMediaFiletype = @[@"mp3",@"wav",@"flv",@"mp4",@"flac"];
    self.supportDocumentFiletype = @[@"doc",@"xls",@"pdf",@"ppt",@"pages",@"keynots",@"numbers",@"docx"];
    
}
#pragma mark - EADelegate
- (void)_accessoryDidConnect:(NSNotification *)notification{
    
    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    
    [self._eaSessionController setupControllerForAccessory:connectedAccessory withProtocolString:[connectedAccessory.protocolStrings objectAtIndex:0]];
    [self._eaSessionController openSession] ;
    if (self._eaSessionController._session!=nil) {
        readcount++;
        read_10(0, 1);
        [self._eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
    }
    
}
- (void)_accessoryDidDisconnect:(NSNotification *)notification
{
    [self.backArray removeAllObjects];
    readcount = 0;
    [self.system.finalArray removeAllObjects];
    [self.system.countArr removeAllObjects];
    [self.table reloadData];
}

- (void)_sessionDataReceived:(NSNotification *)notification{
    EADSessionController *sessionController = (EADSessionController *)[notification object];
    NSInteger bytesAvailable = 0;
    while ((bytesAvailable = [sessionController readBytesAvailable]) > 0) {
        data = [sessionController readData:bytesAvailable];
        if (data) {
            _totalBytesRead += bytesAvailable;
            
        }
        
    }
    switch (readcount) {
        case 1:{
            [self.system clearsTRTodata:data];
            readcount++;
            [self.system getMBRNumberTodata:data];
            read_10(SD_offset.Logic, 1);
            [__eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
            break;
        }
            
        case 2:{
            [self.system clearsTRTodata:data];
            readcount++;
            [self.system translateFAT32datafordata:data];
            read_10(SD_offset.Cluster+SD_offset.Logic, 32);
            [self._eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
            NSNumber *mem = [NSNumber numberWithUnsignedInt:SD_offset.Cluster+SD_offset.Logic];
            [self.backArray insertObject:mem atIndex:touchcount];
            self.system.filesystemType = @"fat32";
            break;
        }
        case 3:{
            [self.system clearsTRTodata:data];
            [self.system getFileDir];
            self.finalArray = self.system.finalArray;
            nextCluster = [self.system seekFreeCluster];
//            [self sendFiledata];
            readcount = 8;
            read_10((uint32_t)nextCluster+1+8192, 1);
            NSLog(@"%llu",nextCluster+1);
            [self._eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
            [self.table reloadData];
            break;
        }
        case 4:{
            
            [self.system clearsTRTodata:data];
            [self.finalArray removeAllObjects];
            [self.system.countArr removeAllObjects];
            [self.system getFileDir];
            [self.table reloadData];
            break;
        }
        case 5:{
            [self.system clearsTRTodata:data];
            [self.finalArray removeAllObjects];
            [self.system.countArr removeAllObjects];
            [self.system getFileDir];
            [self.table reloadData];
            break;
        }
        case 6:{
            
            [self.system clearsTRTodata:data];
            Byte file[SD_para.BytesPerSector];
            for (int i = 0; i<2*SD_para.BytesPerSector; i+=2) {
                NSString *sa3 = [self.system.sa2 substringWithRange:NSMakeRange(i, 2)];
                uint64_t mac = strtoul([sa3 UTF8String], 0, 16);
                file[i/2] = mac;
            }
            [self read10KtoFile:file];
            memset(file, 0, sizeof(file));
            [self sendread10];
            break;

            break;}
        case 7:{
//            NSString *p  = [data.description substringWithRange:NSMakeRange(data.description.length-2, 1)];
//            if ([p isEqualToString:@"0"]) {
//                readcount = 8;
//                write10((uint32_t)nextCluster+1+SD_offset.Logic+SD_offset.Logic, 1);
//                [self._eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
//                Byte p[512];
//                memset(p, 24, 512);
//                [self._eaSessionController writeData:[NSData dataWithBytes:p length:512]];
//                NSLog(@"执行");
//                break;
//            }
            break;
        }
        case 8:{
            NSLog(@"%@",data.description);

        }case 9:{
        }
            
        default:
            break;
       }


}
#pragma mark - 写入文件接口
-(void )sendFiledata{
    readcount = 7;
    write10((uint32_t)nextCluster+1+8192, 1);
    [self._eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
    NSLog(@"%@",[NSData dataWithBytes:&cbwCmd length:32]);
    
    Byte p[512] = {0x34,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x74,0x78,0x74};

    [self._eaSessionController writeData:[NSData dataWithBytes:p length:512]];

}

#pragma mark - 文件读取
-(void)sendread10{
    readcount = 6;
    read_10(fielsec+reada+SD_offset.Logic, 1);
    [self._eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
    reada++;
}

-(void)getFileName{
    
   
}

-(void)read10KtoFile:(Byte *)file{
    
    
}


#pragma mark - TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _system.countArr.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Filelist *cell = [tableView dequeueReusableCellWithIdentifier:@"123"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    if (cell==nil) {
        cell = [[Filelist alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"123"];
    }
    Boolean p  =[[self.finalArray[indexPath.row]filetype]isEqualToString:@"folder"];
    cell.filenamelabel.text  = [self.finalArray[indexPath.row]longname];
    
    if ([cell.filenamelabel.text isEqualToString:@"empty"]) {
        
        NSString *p = [self.finalArray[indexPath.row]name];
        NSString *p1 = [self.finalArray[indexPath.row]filetype];
        cell.filenamelabel.text = [p stringByAppendingString:[NSString stringWithFormat:@".%@",p1]];
    }
    if (p==true)
    {
        cell.filetypeimg.image = [UIImage imageNamed:@"filesystem_icon_folder"];
        cell.filenamelabel.text  = [self.finalArray[indexPath.row]longname];
        if ([cell.filenamelabel.text isEqualToString:@"empty"]) {
            
            NSString *p = [self.finalArray[indexPath.row]name];
            cell.filenamelabel.text = p;
        }
        
    }else{
        
        NSString *tyepList = [self.finalArray[indexPath.row] filetype];
        Boolean media = [self.supportMediaFiletype containsObject:tyepList];
        Boolean doc = [self.supportDocumentFiletype containsObject:tyepList];
        Boolean image = [self.supportImageFileType containsObject:tyepList];
        
        if (media==true) {
            
            cell.filetypeimg.image = [UIImage imageNamed:@"filesystem_icon_music"];
            
        }else if (doc==true){
            cell.filetypeimg.image = [UIImage imageNamed:@"filesystem_icon_text"];
            
        }else if(image==true){
            cell.filetypeimg.image = [UIImage imageNamed:@"filesystem_icon_photo"];
        }else{
            cell.filetypeimg.image = [UIImage imageNamed:@"filesystem_icon_default"];
        }}
          return cell;
    
    
}



#pragma mark -  阅读上一级目录
-(void)ReadlastDir{
    
    readcount = 5;
    NSNumber * p = self.backArray[touchcount-1];
    int p1 = p.intValue;
    read_10(p1, 32);
    [self.backArray removeLastObject];
    [self._eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
    touchcount--;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * p =[self.finalArray[indexPath.row] filetype];
    Boolean b  = [p isEqualToString:@"folder"];
    _currentname = [self.finalArray[indexPath.row]longname];
    if ([_currentname isEqualToString:@"empty"
         ]) {
        _currentname = [self.finalArray[indexPath.row]name];
    }
    
    if (b==true) {
        touchcount++;
        
        readcount = 4;
        NSString *name=  [self.finalArray[indexPath.row]longname];
        if ([name isEqualToString:@"empty"]) {
            name = [self.finalArray[indexPath.row]name];
            
        }
        fielsec = [self.finalArray[indexPath.row]filesector];
        read_10(fielsec+SD_offset.Logic, 32);
        NSNumber *next = [NSNumber numberWithUnsignedInt:fielsec+SD_offset.Logic];
        [self.backArray insertObject:next atIndex:touchcount];
        [self._eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
        
    }else{
        fielsec = [self.finalArray[indexPath.row]filesector];
        uintmax_t p1 = [self.finalArray[indexPath.row]filesize];
        currentsize = p1;
        __currenttype = p;
        NSString *tyepList = [self.finalArray[indexPath.row] filetype];
        Boolean media = [self.supportMediaFiletype containsObject:tyepList];
        Boolean doc = [self.supportDocumentFiletype containsObject:tyepList];
        Boolean image = [self.supportImageFileType containsObject:tyepList];
        
        if (media==true) {
            filetpe = 1;
            
        }else if (doc==true){
            
            filetpe = 2;
            
        }else if(image==true){
            filetpe = 3;
            
            
        }else if([tyepList isEqualToString:@"txt"]){
            
            filetpe = 4;
        }
           readcount = 6;
        uintmax_t p3 = p1/256;
            if (currentsize%256!=0) {
                resttime = p3+1;
                lesstime = currentsize%256;
                read_10(SD_offset.Logic+fielsec, 1);
                [self._eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
                reada++;
            }else{
                resttime = p3;
                lesstime = 0;
                read_10(SD_offset.Logic+fielsec, 1);
                [self._eaSessionController writeData:[NSData dataWithBytes:&cbwCmd length:32]];
                reada++;
            
}}}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
