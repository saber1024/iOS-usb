//
//  FileIO.h
//  UDisk
//
//  Created by shiki on 16/8/9.
//  Copyright © 2016年 两仪式. All rights reserved.
//

#ifndef FileIO_h
#define FileIO_h
#define U16 uint16_t
#define U8  uint8_t
#define U32 uint32_t
#include <stdio.h>
struct CBW{
    
    uint32_t  dCBWSignature;
    uint32_t  dCBWTag;
    uint32_t  dCBWDataTransferLength;
    uint8_t   bmCBWFlags;
    uint8_t   bCBWLUN;
    uint8_t   bCBWCBLength;
    uint8_t   u8OPCode;
    uint8_t   u8LUN;
    uint8_t   au8Data[14];
    
};
struct FAT_PARA
{
    U16 BytesPerSector;          //每个扇区多少字节
    U8  SectorsPerCluster;         //每个簇有多少个扇区
    U16 ReserveSectors;          //保留扇区数
    U8  FatTableNums;           //有多少个FAT表
    U16 RootDirRegNums;      //根目录允许的登记项数目
    U16 SectorsPerFat;                //每个FAT表有多少个扇区
    U32 SectorNums;               //总的扇区数   
    U8   FileType[7];              //文件系统类型
};
/**
 *  FAT OFFSET
 */
struct FAT_OFFSET
{
    U32 Logic;  //引导扇（逻辑扇区0）对物理0扇区里的偏移地址
    U32 FAT1;
    U32 FAT2;
    U32 FDT;
    U32 Cluster;  //数据簇的偏移地址
};
extern struct FAT_PARA      SD_para;   //声明两个结构体变量
extern struct FAT_OFFSET    SD_offset;
extern struct CBW           cbwCmd;

void write10(uint32_t logicalBlockAddress, uint32_t blockNum);
void read_10(uint32_t logicalBlockAddress, uint32_t blockNum);

#endif /* FileIO_h */
