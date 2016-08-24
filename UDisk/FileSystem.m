//
//  FileSystem.m
//  UDisk
//
//  Created by shiki on 16/8/9.
//  Copyright © 2016年 两仪式. All rights reserved.
//

#import "FileSystem.h"
#import "FileIO.h"
int count = 0;

@implementation FileSystem
/**
 *  删除data中多余的csw包以及数据
 *
 *  @param data 目标data
 */
-(void )clearsTRTodata:(NSData *)data{
    
    NSRange ra = [data.description rangeOfString:@"55534253"];
    NSString *saaa = [data.description substringWithRange:NSMakeRange(0, ra.location-1)];
    NSString *sa1 = [saaa stringByReplacingOccurrencesOfString:@" " withString:@""];

    self.sa2 = [sa1 substringFromIndex:1];
}
/**
 *  判断是否是fat32系统
 *
 *  @return 判断
 */
-(Boolean )isFAT32{
    
    Boolean isfat32 = false;
    
    Byte p[[_sa2 length]];
    for (int i = 0; i<[_sa2 length]; i+=2) {
        NSString *sa3 = [_sa2 substringWithRange:NSMakeRange(i, 2)];
        uint64_t mac = strtoul([sa3 UTF8String], 0, 16);
        
        p[i] = mac;
    }
    Byte pa[5] = {p[164],p[166],p[168],p[170],p[172]};
    NSData *dataa = [NSData dataWithBytes:&pa length:5];
    NSString *saa = [[NSString alloc]initWithData:dataa encoding:NSASCIIStringEncoding];
    if ([saa isEqualToString:@"FAT32"]) {
        isfat32=true;
    }
    return isfat32;
    
}
/**
 *  判断是否是fat16
 *
 *  @return
 */
-(Boolean )isFAT16{
    
    Boolean isfat16 = FALSE;
    Byte p[[_sa2 length]];
    for (int i = 0; i<[_sa2 length]; i+=2) {
        NSString *sa3 = [_sa2 substringWithRange:NSMakeRange(i, 2)];
        uint64_t mac = strtoul([sa3 UTF8String], 0, 16);
        
        p[i] = mac;
    }
    Byte pa[5] = {p[108],p[110],p[112],p[114],p[116]};
    NSData *dataa = [NSData dataWithBytes:&pa length:5];
    NSString *saa = [[NSString alloc]initWithData:dataa encoding:NSASCIIStringEncoding];
    if ([saa rangeOfString:@"FAT16"].location!=NSNotFound) {
        isfat16 = true;
    }
    return isfat16;
    
}
/**
 *  根据data解析fat数据
 *
 *  @param data 参数data
 */
-(void)translateFAT32datafordata:(NSData *)data{
    uint64_t * p  = [self clearString:data.description andlength:1024];
    uint64_t p9 = p[11];
    uint64_t p10 = p[12];
    SD_para.BytesPerSector = p10 * 256 + p9;
    //每扇区字节数
    uint64_t p1 = p[36];
    uint64_t p2 = p[37]*256;
    uint64_t p3 = p[38]*65536;
    uint64_t p4 = p[39]*16777216;
    SD_para.SectorsPerFat = p1+p2+p3+p4;//每个fat表占用的扇区数
    SD_para.FatTableNums = p[16];//fat表个数
    uint64_t p13 = p[14] ;
    uint64_t p14 = p[15]*256 ;
    _sectorpercu = p[13];
    
    SD_para.ReserveSectors = p13+p14;//保留扇区数
    // 数据区起始扇区号 = 保留扇区数 + 每个FAT表大小扇区数 × FAT表个数
    SD_offset.Cluster = SD_para.ReserveSectors + SD_para.SectorsPerFat * SD_para.FatTableNums;
    
    
}

/**
 *  将数据装入byte数组
 *
 *  @param dataString 清除后的字符串
 *  @param length     装入的长度
 *
 *  @return 存储后的数组
 */
-(uint64_t*)clearString:(NSString *)dataString andlength:(int)length{
    
    uint64_t * p = malloc(length * sizeof(uint64_t));
    for (int i =0; i<self.sa2.length; i+=2) {
        NSString *sa3 = [self.sa2 substringWithRange:NSMakeRange(i, 2)];
        uint64_t mac1 = strtoul([sa3 UTF8String], 0, 16);
        p[i/2] = mac1;
    }
    
    return p;
}
/**
 *  解析fat16的数据
 *
 *  @param data mbr扇区参数data
 */
-(void)translateFAT16datafordata:(NSData *)data{
    
    uint64_t *p = [self clearString:data.description andlength:1024];
    uint64_t persectoer = p[12]*256+p[11];
    SD_para.BytesPerSector = (U16)persectoer;    //每扇区字节数
    uint64_t fatnum = p[22]+p[23]*256;
    SD_para.SectorsPerFat = (U32)fatnum;        //每个fat表占用的扇区数
    SD_para.FatTableNums = p[16];//fat表个数
    uint64_t topsector = p[14]+p[15]*256;
    SD_para.ReserveSectors = topsector;    //保留扇区数
    SD_para.SectorsPerCluster = p[13];  //每簇扇区数
    SD_offset.FAT1 = 0+SD_para.ReserveSectors;
    SD_offset.FDT = SD_offset.FAT1+ SD_para.FatTableNums* SD_para.SectorsPerFat;
    
    
}
/**
 *  清除读取根目录之后的没有数据的扇区的00然后装入数组
 *
 *  @param arg1 传过来32个扇区的数据
 *
 *  @return 清除后的数据
 */
-(Byte *)clearData:(Byte *)arg1{
    NSMutableArray * array = [[NSMutableArray alloc]init];
    count = 0;
    int zeroCount = 0;
    
    
    for (int i = 0; i<SD_para.BytesPerSector * 32; i+=32) {
        for (int j = 0; j<32; j++) {
            
            if (arg1[i+j]==0) {
                zeroCount++;
            }
            
        }
        
        if (zeroCount != 32) {
            count += 32;
            zeroCount = 0;
            Byte *newbyte = (Byte *)malloc(32 * sizeof(Byte));
            memcpy(newbyte,&arg1[i] , 32);
            
            for (int m = 0; m<32; m++) {
                NSNumber* b= [NSNumber numberWithChar:newbyte[m]];
                
                [array addObject:b];
                
            }}}
    
    _restcount = [array count];

    Byte *databy = malloc(sizeof(Byte )*[array count]);
    
    for (int i = 0; i<[array count]; i++) {
        
        NSData *datad = [array objectAtIndex:i];
        NSNumber *num = (NSNumber *)(datad);
        [num getValue:&databy[i]];
        
    }
    
    
    return databy;
    
}
/**
 *  解析长文件
 *
 *  @param dataByte 长文件数组
 *
 *  @return 是否是长文件
 */
-(BOOL)readlongfile:(Byte *)dataByte{
    BOOL flag = false;
    NSMutableString *nex = [[NSMutableString alloc]init];
    NSString * name =  [self readbyte:dataByte andoffset:1 andcount:10];
    [nex appendString:name];
    name =  [self readbyte:dataByte andoffset:14 andcount:12];
    [nex appendString:name];
    name =  [self readbyte:dataByte andoffset:28 andcount:4];
    [nex appendString:name];
    [self.fileitem insertString:nex atIndex:0];
    if (((Byte)dataByte[0]&0x40)==0x40) {
        flag = true;
    }
    return  flag;
}
/**
 *  解析fat32短文件
 *
 *  @param dataByte 短文件数组
 *
 *  @return 解析之后传给模型
 */
-(FileItemModel *)read32shortfile:(Byte *)dataByte{
    FileItemModel *item = [[FileItemModel alloc]init];
    int typecount = 0;
    typecount++;
    Byte byte[32];
    memcpy(&byte, &dataByte[0], 32);
    NSData *filedata = [NSData dataWithBytes:dataByte length:8];
    int add1 = byte[20];
    int add2 = byte[21];
    int add7 = byte[26];
    int add8 = byte[27];
    int starcu = add7*1+add8*256+add2*256*256+add1*256*256*256;
    if (starcu==0) {
        item.filesector = 0;
        return item;
    }
    int add3 = byte[28];
    int add4 = byte[29]*256;
    int add5 = byte[30]*256*256;
    int add6 = byte[31]*256*256*256;
    int type1 = byte[8];
    int type2 = byte[9];
    int type3 = byte[10];
    Byte p[] = {type1,type2,type3};
    NSData *dataa = [NSData dataWithBytes:&p length:3];
    NSString *s = [[NSString alloc]initWithData:dataa encoding:NSASCIIStringEncoding];
    item.name = [[[NSString alloc]initWithData:filedata encoding:NSASCIIStringEncoding ] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
    if ([s isEqualToString:@"   "]) {
        
        s = @"Folder";
        
    }
    item.filetype = [s lowercaseString];
    item.filesize = (uintmax_t)add3+(uintmax_t)add4+(uintmax_t)add5+(uintmax_t)add6;
    item.filesector = SD_offset.Cluster+((starcu-2)*(int)_sectorpercu);
    return item;

}
/**
 *  解析fat16短文件
 *
 *  @param dataByte fat16短文件数组
 *
 *  @return 解析之后传给模型
 */
-(FileItemModel *)read16shortfile:(Byte *)dataByte{
    FileItemModel *item = [[FileItemModel alloc]init];
    
    int typecount = 0;
    
    typecount++;
    
    
    Byte byte[32];
    memcpy(&byte, &dataByte[0], 32);
    NSData *filedata = [NSData dataWithBytes:dataByte length:8];
    
    
    int add1 = byte[26];
    int add2 = byte[27]*256;
    int starcu = add1+add2;
    
    if (starcu==0) {
        
        item.filesector = 0;
        
        return item;
    }
    int add3 = byte[28];
    int add4 = byte[29]*256;
    int add5 = byte[30]*256*256;
    int add6 = byte[31]*256*256*256;
    int type1 = byte[8];
    int type2 = byte[9];
    int type3 = byte[10];
    Byte p[] = {type1,type2,type3};
    NSData *dataa = [NSData dataWithBytes:&p length:3];
    NSString *s = [[NSString alloc]initWithData:dataa encoding:NSASCIIStringEncoding];
    item.name = [[[NSString alloc]initWithData:filedata encoding:NSASCIIStringEncoding ] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
    if ([s isEqualToString:@"   "]) {
        
        s = @"Folder";
        
    }
    item.filetype = [s lowercaseString];
    item.filesize = (uintmax_t)add3+(uintmax_t)add4+(uintmax_t)add5+(uintmax_t)add6;
    item.filesector = (starcu-2)*SD_para.SectorsPerCluster+SD_offset.FDT+32;
    return item;
}

/**
 *  读取长文件数组中关键位置的数据并装入数组中解析，因为长文件的Unicode编码位置不一样
 *
 *  @param dataa  长文件数组
 *  @param offset 开始位置
 *  @param count  读取长度
 *
 *  @return 参数数组
 */
-(Byte *)readdata:(Byte *)dataa andoffset:(int)offset andcount:(int )count{
    int i = offset;
    
    Byte *p = (Byte*)malloc(count*sizeof(Byte));
    
    
    for (; i<offset+count; i++) {
        
        p[i-offset] = dataa[i];
        
        
    }
    
    return p;
}
/**
 *  删除多余的00
 *
 *  @param by    参数数组
 *  @param count 数量
 */
-(void)deleteFF:(Byte*)by andcount:(int)count{
    
    for (int i  = 0; i<count; i+=2) {
        if (by[i]==255 && by[i+1]==255) {
            
            by[i] = 00;
            by[i+1] = 32;
            
            
        }else if (by[i]==00 && by[i+1]==00){
            
            by[i] = 00;
            by[i+1] = 32;
        }}
    
}

/**
 *  读取长文件数组中关键位置的数据并装入数组中解析，因为长文件的Unicode编码位置不一样
 *
 *  @param dataa  长文件数组
 *  @param offset 开始位置
 *  @param count  读取长度
 *
 *  @return 参数数组
 */

-(NSString *)readbyte:(Byte *)databyte andoffset:(int)offset andcount:(int)count{
    NSString *name = nil;
    Byte *by;
    by = [self readdata:databyte andoffset:offset andcount:count];
    [self deleteFF:by andcount:count];
    for (int i = 0; i<count; i+=2) {
        Byte t = by[i+1];
        by[i +1 ] =by[i];
        by[i] = t;
        
    }
    NSData *item = [NSData dataWithBytes:by length:count];
    name = [[NSString alloc]initWithData:item encoding:NSUnicodeStringEncoding];
    if (name ==nil) {
        
        name = @"";
    }
    return name;
}
/**
 *  根据0扇区数据的标志位解析MBR扇区地址
 *
 *  @param data <#data description#>
 */
-(void)getMBRNumberTodata:(NSData *)data{
    uint64_t * p  = [self clearString:data.description andlength:1024];
    uint64_t p1 = p[454]+p[455]*256+p[456]*256*256+p[457]*256*256*256;
    self.fileitem = [[NSMutableString alloc]init];

    SD_offset.Logic = (U32)p1;
}
-(uint64_t)seekFreeCluster{
    uint64_t freeCluster = 0;
    if (_restcount%512==0) {
        
        int clust = ceil(_restcount/512/2);
        freeCluster = SD_offset.Cluster+clust;
        
    }else{
        
        int clust = ceil(_restcount/512/2)+1;
        freeCluster = SD_offset.Cluster+clust;
        

    }
    
    return  freeCluster;
    
}
/**
 *  找到根目录的最后一个地址
 *
 *  @return <#return value description#>
 */
-(uint64_t)seekAllFreeCluster{
    uint64_t freeCluster = 0;
    
    return  freeCluster;
}
/**
 *  文件系统解析方法
 */
-(void)getFileDir{
    self.finalArray = [[NSMutableArray alloc]init];
    self.countArr = [[NSMutableArray alloc]init];
    Byte bya[32 * 512];
    for (int i =0; i<self.sa2.length; i+=2) {
        NSString *sa3 = [self.sa2 substringWithRange:NSMakeRange(i, 2)];
        uint64_t mac1 = strtoul([sa3 UTF8String], 0, 16);
        bya[i/2] = mac1;
    }
    
    Byte *newbyte = [self clearData:bya];
    
    BOOL isreadlongfile = false;
    NSString *str = nil;
    for (int i =0; i<count; i+=32) {
        Byte byte[32];
        memcpy(&byte, &newbyte[i], 32);
        if (byte[11]==0x0f) {
            //longfile
            BOOL  b =    [self readlongfile:byte];
            str = [NSMutableString stringWithString:self.fileitem];
            if (b) {
                isreadlongfile = true;
            }
        }else{
            if (byte[0]==0xE5||byte[0]==0x00) {
                [self.fileitem deleteCharactersInRange:NSMakeRange(0, self.fileitem.length)];
                continue;
            }
            
            //shortfile
          
            _mode = [self read32shortfile:byte];

            if ((byte[11]&0x02)==0x02) {
                
                NSString *t  =     [_mode.name stringByAppendingString:@".invisible"];
                
                _mode.name = t;
                
            }
            
            if (isreadlongfile) {
                [self.fileitem deleteCharactersInRange:NSMakeRange(0, self.fileitem.length)];
                isreadlongfile  = false;
                str =   [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                _mode.longname = str;
                str = @"";
            }
            if (_mode.longname==nil) {
                
                _mode.longname = @"empty";
                
            }
            if ([_mode.name rangeOfString:@"invisible"].location==NSNotFound&&[_mode.longname isEqualToString:@"."]==false&&[_mode.name isEqualToString:@"."]==false&&[_mode.name isEqualToString:@".."]==false&&[_mode.longname isEqualToString:@".."]==false
                &&[_mode.name isEqualToString:@"."]==false) {
                
                [self.finalArray addObject:_mode];
                [self.countArr addObject:_mode.name];
            }}}
    
    
}
@end
