//
//  ViewController.h
//  UDisk
//
//  Created by shiki on 16/8/9.
//  Copyright © 2016年 两仪式. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EADSessionController.h"

@interface ViewController : UIViewController{
    
    EAAccessory *_selectedAccessory;
    uint32_t _totalBytesRead;
    NSMutableArray *_accessoryList;
    NSData *data;
    int readcount;
    int touchcount;
    Boolean isfat32;
    Boolean isfat16;
    int reada;
    uintmax_t resttime;
    int lesstime;
    uint32_t fielsec;
    uintmax_t  currentsize;
    int filetpe;
    uint64_t bad;
    uint64_t nextCluster;
    Byte *filena;
    
    
    
}
@property(nonatomic,strong)    EADSessionController *_eaSessionController;


@end

