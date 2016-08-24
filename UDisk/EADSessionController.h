//
//  EADSessionController.h
//  OCSendTest
//
//  Created by mwang on 2/19/16.
//  Copyright © 2016 nuvoton. All rights reserved.
//

#ifndef EADSessionController_h
#define EADSessionController_h



#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

extern NSString *EADSessionDataReceivedNotification;

// NOTE: EADSessionController is not threadsafe, calling methods from different threads will lead to unpredictable results
@interface EADSessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate> {
    EAAccessory *_accessory;
    NSString *_protocolString;
    
    NSMutableData *_writeData;
    NSMutableData *_readData;
}

+ (EADSessionController *)sharedController;

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;

- (BOOL)openSession;
- (void)closeSession;

- (void)writeData:(NSData *)data;

- (NSUInteger)readBytesAvailable;
- (NSData *)readData:(NSUInteger)bytesToRead;
@property(nonatomic,strong)    EASession *_session;

@property (nonatomic, readonly) EAAccessory *accessory;
@property (nonatomic, readonly) NSString *protocolString;

@end


#endif /* EADSessionController_h */
