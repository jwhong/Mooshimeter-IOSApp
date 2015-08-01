//
//  ReachabilityManager.m
//  Mooshimeter
//
//  Created by Admin on 6/2/15.
//  Copyright (c) 2015 mooshim. All rights reserved.
//

#import "ReachabilityManager.h"

@interface ReachabilityManager()
{
    
}

@property Reachability* reachability;
@property BOOL isConnectedToInternet;
@property BOOL isWaiting;
@property NSMutableDictionary* blockDictionary;
@property NSMutableArray* blockKeysArray;

@end

@implementation ReachabilityManager

+(ReachabilityManager*)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return (ReachabilityManager*)sharedInstance;
}

-(id) init
{
    self = [super init];
    if (self)
    {
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnectionStatusChange) name:kReachabilityChangedNotification object:nil];
        self.blockDictionary = [[NSMutableDictionary alloc] init];
        self.blockKeysArray = [[NSMutableArray alloc] init];
        
        if([self.reachability currentReachabilityStatus] == NotReachable)
        {
            self.isConnectedToInternet = false;
        }
        else
        {
            self.isConnectedToInternet = true;
        }
        
        self.isWaiting = false;
        
    }
    return self;
}

-(BOOL)connectedToInternet
{
    return self.isConnectedToInternet;
}

-(void)addConnectionStatusChangeHandler:(void(^)(BOOL connectedToInternet))block withIdentifier:(NSString*)identifier
{
    if(![self.blockKeysArray containsObject:identifier])
    {
        [self.blockKeysArray addObject:identifier];
        self.blockDictionary[identifier] = block;
    }
}

-(void)removeConnectionStatusChangeHandlerWithIdentifier:(NSString*)identifier
{
    if([self.blockKeysArray containsObject:identifier])
    {
        [self.blockKeysArray removeObject:identifier];
    }
}

-(void)onConnectionStatusChange
{
    if(self.isWaiting == false)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(afterRapidAlternating) userInfo:nil repeats:NO];
    }
}

-(void)afterRapidAlternating
{
    if([self.reachability currentReachabilityStatus] == NotReachable)
    {
        if(self.isConnectedToInternet == true)
        {
            self.isConnectedToInternet = false;
            for(NSString* key in self.blockKeysArray)
            {
                ((void(^)(BOOL))self.blockDictionary[key])(self.isConnectedToInternet);
            }
        }
    }
    else
    {
        if(self.isConnectedToInternet == false)
        {
            self.isConnectedToInternet = true;
            for(NSString* key in self.blockKeysArray)
            {
                ((void(^)(BOOL))self.blockDictionary[key])(self.isConnectedToInternet);
            }
        }
    }
}

@end
