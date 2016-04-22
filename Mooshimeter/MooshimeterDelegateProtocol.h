//
// Created by James Whong on 4/12/16.
// Copyright (c) 2016 mooshim. All rights reserved.
//

#include "MooshimeterProfileTypes.h"

#import <Foundation/Foundation.h>
#import "MooshimeterControlProtocol.h"
#import "MeterReading.h"
#import "RangeDescriptor.h"
#import "InputDescriptor.h"

@protocol MooshimeterDelegateProtocol <NSObject>
-(void) onInit;
-(void) onDisconnect;
-(void) onRssiReceived:(int)rssi;
-(void) onBatteryVoltageReceived:(float)voltage;
-(void) onSampleReceived:(double)timestamp_utc c:(Channel)c val:(MeterReading*)val;
-(void) onBufferReceived:(double)timestamp_utc c:(Channel)c dt:(float)dt val:(float*)val;
-(void) onSampleRateChanged:(int)i sample_rate_hz:(int)sample_rate_hz;
-(void) onBufferDepthChanged:(int)i buffer_depth:(int)buffer_depth;
-(void) onLoggingStatusChanged:(bool)on new_state:(int)new_state message:(NSString*)message;
-(void) onRangeChange:(Channel)c new_range:(RangeDescriptor*)new_range;
-(void) onInputChange:(Channel)c descriptor:(InputDescriptor*)descriptor;
-(void) onOffsetChange:(Channel)c offset:(MeterReading*)offset;
@end