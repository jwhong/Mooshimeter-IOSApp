/*
 BLETIOADProfile.h
 TIOADExample

 Created by Ole Andreas Torvmark on 11/22/12.
 Copyright (c) 2013 Texas Instruments. All rights reserved.

 */

#import "OADProgressViewController.h"
#import "MooshimeterDevice.h"
#import "oad.h"

@class BLETIOADProgressViewController;

typedef void (^FirmwareUpdateFinishCallback)(NSError *error);

@interface OADProfile : NSObject <UIActionSheetDelegate,UIAlertViewDelegate,CBPeripheralDelegate> {
    @public
    img_hdr_t imageHeader;
    
    // Add by Jianying Shi.
    FirmwareUpdateFinishCallback    aCompletionBlock;
}

@property (strong,nonatomic) NSData *imageData;

@property int nBlocks;
@property int nBytes;
@property int iBlocks;
@property int iBytes;
@property BOOL canceled;
@property BOOL inProgramming;
@property BOOL start;
@property (nonatomic,retain) NSTimer *imageDetectTimer;
@property UINavigationController *navCtrl;

@property (strong,nonatomic) BLETIOADProgressViewController *progressView;

@property (strong,nonatomic) dispatch_semaphore_t pacer_sem;

-(instancetype) init:(NSString*) filename;

// Add by Jianying Shi.
// Download new Firmware
-(void) setCompletionBlock : (FirmwareUpdateFinishCallback) aCallback;

-(void) startUpload;

-(void) completionDialog;

@end
