//
//  FileItemModel.h
//  UDisk
//
//  Created by shiki on 16/8/9.
//  Copyright © 2016年 两仪式. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileItemModel : NSObject
@property(nonatomic,strong)NSString *name;
@property(nonatomic,assign)int filesector;
@property(nonatomic,assign)uintmax_t filesize;
@property(nonatomic,strong)NSString *longname;
@property(nonatomic,strong)NSString *filetype;


@end
