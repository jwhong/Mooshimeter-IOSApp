//
//  ReachabilityManager.h
//  Mooshimeter
//
//  Created by Admin on 6/2/15.
//  Copyright (c) 2015 mooshim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vendor/Reachability/Reachability.h"

@interface ReachabilityManager : NSObject

+(ReachabilityManager*)sharedInstance;

-(BOOL)connectedToInternet;
-(void)addConnectionStatusChangeHandler:(void(^)(BOOL connectedToInternet))block withIdentifier:(NSString*)identifier;
-(void)removeConnectionStatusChangeHandlerWithIdentifier:(NSString*)identifier;

@end
