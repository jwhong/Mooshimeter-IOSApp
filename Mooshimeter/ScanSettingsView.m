//
//  ScanSettingsView.m
//  Mooshimeter
//
//  Created by James Whong on 2/10/15.
//  Copyright (c) 2015 mooshim. All rights reserved.
//

#import "ScanSettingsView.h"

#import <MessageUI/MessageUI.h>

@implementation ScanSettingsView


-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = YES;
    
    // FIXME: - fixed icon size
    const CGFloat fixedIconSize = 30;
    const CGFloat fixedPadding = 10;
    const CGFloat fixedOffsetX = fixedIconSize + fixedPadding * 2;
    const CGFloat adjustedWidth = frame.size.width - fixedOffsetX;
    
    // Lay out the controls
    const NSInteger nrow = 3;
    const NSInteger ncol = 1;
    
    CGFloat h = frame.size.height/nrow;
    CGFloat w = adjustedWidth / ncol;
    
#define cg(nx,ny,nw,nh,ox,oy) CGRectMake(nx*w+ox,ny*h+oy,nw*w,nh*h)
    self.about_section  = [[UILabel  alloc]initWithFrame:cg(0,0,1,1,fixedOffsetX,0)];
    self.help_button    = [[UIButton alloc]initWithFrame:cg(0,1,1,1,fixedOffsetX,0)];
    self.mail_button    = [[UIButton alloc]initWithFrame:cg(0,2,1,1,fixedOffsetX,0)];
#undef cg
    
    // Place suitable icons
    // By Jianying Shi
    const CGFloat fixedOffsetY = (h - fixedIconSize) / 2;
    UIImageView *infoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_icon"]];
    [infoImage setFrame:CGRectMake(fixedPadding, fixedOffsetY, fixedIconSize, fixedIconSize)];
    
    UIImageView *webImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"web_icon"]];
    [webImage setFrame:CGRectMake(fixedPadding, fixedOffsetY + h, fixedIconSize, fixedIconSize)];
    UIImageView *mailImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mail_icon"]];
    [mailImage setFrame:CGRectMake(fixedPadding, fixedOffsetY + h * 2, fixedIconSize, fixedIconSize)];
    
    // Set properties
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString* about_string = [NSString stringWithFormat:@"Mooshimeter iOS App\nVersion: %@ (%@)", appVersionString, appBuildString];
    [self.about_section setText:about_string];
    [self.about_section setFont:[UIFont systemFontOfSize:20]];
    [self.about_section setTextAlignment:NSTextAlignmentCenter];
    [self.about_section setTextColor:[UIColor whiteColor]];
    self.about_section.numberOfLines = 3;
    
    [ self.help_button addTarget:self action:@selector(launchHelp) forControlEvents:UIControlEventTouchUpInside];
    [ self.help_button setTitle:@"Open Help Site" forState:UIControlStateNormal];
    [ self.help_button.titleLabel setFont:[UIFont systemFontOfSize:24]];
    [ self.help_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Added by Jianying Shi
    // 04/22/2015
    [ self.mail_button addTarget:self action:@selector(launchMail) forControlEvents:UIControlEventTouchUpInside];
    [ self.mail_button setTitle:@"Mail Support" forState:UIControlStateNormal];
    [ self.mail_button.titleLabel setFont:[UIFont systemFontOfSize:24]];
    [ self.mail_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Add as subviews
    [self addSubview:self.about_section];
    [self addSubview:self.help_button];
    [self addSubview:self.mail_button];
    
    // Add icons
    // By Jianying Shi
    [self addSubview: infoImage];
    [self addSubview: webImage];
    [self addSubview: mailImage];
    
    return self;
}

// Control Callbacks

-(void)launchHelp {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://moosh.im/support/"]];
}

// By Jianying Shi
-(void)launchMail {
    [_delegate handleSendSupporMail];
}

@end
