# iOS u盘文件系统示范

1、我不负责实现iAP2协议，协议层在我的外设上是底层实现的。
2、文件读写的scsi函数在fileio里，我只做读取列表没有写入。
3、文件系统的逻辑都在filesystem里，可以自行参考，fat32、16都有。
