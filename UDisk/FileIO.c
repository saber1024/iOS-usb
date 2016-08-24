//
//  FileIO.c
//  UDisk
//
//  Created by shiki on 16/8/9.
//  Copyright © 2016年 两仪式. All rights reserved.
//

#include "FileIO.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct FAT_PARA      SD_para;   //声明两个结构体变量
struct FAT_OFFSET    SD_offset;
struct CBW           cbwCmd;

void read_10(uint32_t logicalBlockAddress, uint32_t blockNum)

{
    uint32_t tmp;
    uint8_t *p = cbwCmd.au8Data;
    cbwCmd.dCBWSignature = 0x43425355;//
    cbwCmd.dCBWTag = arc4random();//dCBWTag
    cbwCmd.dCBWDataTransferLength = blockNum * 512;//
    cbwCmd.bmCBWFlags =  0x80;//device to host
    cbwCmd.bCBWLUN = 0x00;
    cbwCmd.bCBWCBLength = 0x0A;//read10 command 10 bytes
    cbwCmd.u8OPCode = 0x28;//opcode
    cbwCmd.u8LUN = 0x00;//para1
    memset(p, 0, 14);
    tmp = logicalBlockAddress;
    *((uint8_t *)(p+0)) = *((uint8_t *)&tmp+3);
    *((uint8_t *)(p+1)) = *((uint8_t *)&tmp+2);
    *((uint8_t *)(p+2)) = *((uint8_t *)&tmp+1);
    *((uint8_t *)(p+3)) = *((uint8_t *)&tmp+0);
    tmp = blockNum;
    *((uint8_t *)(p+5)) = *((uint8_t *)&tmp+1);
    *((uint8_t *)(p+6)) = *((uint8_t *)&tmp+0);
    
}
void write10(uint32_t logicalBlockAddress,uint32_t blockNum){
    uint32_t tmp;
    uint8_t *p = cbwCmd.au8Data;
    cbwCmd.dCBWSignature = 0x43425355;//dCBWSignature 55 53 42 43 cbw包验证戳
    cbwCmd.dCBWTag = arc4random();//CBw包TAG
    cbwCmd.dCBWDataTransferLength = blockNum * 512;//cbw包接收指令长度
    cbwCmd.bmCBWFlags = 0x00;//cbw标识主机到device
    cbwCmd.bCBWLUN = 0x00;//逻辑驱动器数量
    cbwCmd.bCBWCBLength = 0x0A;//scsi写指令长度10个字节
    cbwCmd.u8OPCode = 0x2a;//scsi写指令操作码
    cbwCmd.u8LUN = 0x00;//指令逻辑驱动器下标
    memset(p, 0, 14);
    tmp = logicalBlockAddress;
    *((uint8_t *)(p+0)) = *((uint8_t *)&tmp+3);//扇区MSB
    *((uint8_t *)(p+1)) = *((uint8_t *)&tmp+2);//扇区MSB
    *((uint8_t *)(p+2)) = *((uint8_t *)&tmp+1);//扇区LSB
    *((uint8_t *)(p+3)) = *((uint8_t *)&tmp+0);//扇区LSB
    tmp = blockNum;
    *((uint8_t *)(p+5)) = *((uint8_t *)&tmp+1);//扇区数MSB
    *((uint8_t *)(p+6)) = *((uint8_t *)&tmp+0);//扇区数LSB
}
