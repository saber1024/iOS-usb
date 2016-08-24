//
//  FileSystem.h
//  UDisk
//
//  Created by shiki on 16/8/9.
//  Copyright © 2016年 两仪式. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileItemModel.h"

@interface FileSystem : NSObject{

    NSString *FinalStr;
}

-(void )clearsTRTodata:(NSData *)data;
-(Boolean )isFAT32;
-(Boolean )isFAT16;
-(void)translateFAT32datafordata:(NSData *)data;
-(void)translateFAT16datafordata:(NSData *)data;
-(void)getFileDir;
-(Byte *)clearData:(Byte *)arg1;
-(BOOL)readlongfile:(Byte *)dataByte;
-(FileItemModel *)read32shortfile:(Byte *)dataByte;
-(FileItemModel *)read16shortfile:(Byte *)dataByte;
-(Byte *)readdata:(Byte *)dataa andoffset:(int)offset andcount:(int )count;
-(void)deleteFF:(Byte*)by andcount:(int)count;
-(NSString *)readbyte:(Byte *)databyte andoffset:(int)offset andcount:(int)count;
-(void)getMBRNumberTodata:(NSData *)data;
-(uint64_t )seekFreeCluster;
-(uint64_t )seekAllFreeCluster;
@property(nonatomic,strong)NSString *sa2;
@property(nonatomic,assign)uint64_t  sectorpercu;
@property(nonatomic,strong)NSMutableString *fileitem; //final string
@property(nonatomic,strong)NSData *data;
@property(nonatomic,strong)FileItemModel *mode;
@property(nonatomic,strong)NSString *filesystemType;
@property(nonatomic,strong)NSMutableArray *finalArray;
@property(nonatomic,strong)NSMutableArray *countArr;
@property(nonatomic,assign)unsigned long restcount;

@end
