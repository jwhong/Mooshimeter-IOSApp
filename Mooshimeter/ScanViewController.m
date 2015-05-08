/**************************
Mooshimeter iOS App - interface to Mooshimeter wireless multimeter
Copyright (C) 2015  James Whong

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***************************/

#import "ScanViewController.h"
#import "meterViewController.h"

#import "Vendor/KxMenu/KxMenu.h"
#import "Vendor/LDProgressView/LDProgressView.h"

// Bar chart
// Jianying Shi. 05/02/2015
#import "Vendor/MPPlot/MPPlot.h"
#import "Vendor/MPPlot/MPGraphView.h"
#import "Vendor/MPPlot/MPBarsGraphView.h"

#import <sys/utsname.h>
#include <sys/types.h>
#include <sys/sysctl.h>

// Uncomment if you want a simulated meter to appear in the scan list
#define SIMULATED_METER

#define kRSSIView_Tag       1000
#define kContextMenu_Tag    2000

#define Round(a)            (NSInteger) (a + 0.5)

@interface ScanViewController () {
    NSMutableArray *_objects;
    
    KxMenu* settingsMenu;
}
@end

@implementation ScanViewController

-(instancetype)initWithDelegate:(id)d {
    self=[super init];
    self.delegate = d;
    self.peripherals = nil;
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)reloadData {
    NSLog(@"Reload requested");
    LGCentralManager* c = [LGCentralManager sharedInstance];
    self.peripherals = [c.peripherals copy];
    [self.tableView reloadData];
    
    // Auto - connect logics.
    // Jianying Shi
    
#if 0
    NSString* savedUUID = [[NSUserDefaults standardUserDefaults] objectForKey : @"autoUUID"];
    if( savedUUID != nil && savedUUID.length > 0 )
    {
        for( NSInteger i = 0; i < self.peripherals.count; i ++ )
        {
            LGPeripheral* p = self.peripherals[i];
            if( [[p UUIDString] isEqualToString : savedUUID] == YES )
            {
                [self.delegate handleScanViewSelect:p];
                break;
            }
        }
    }
#endif
    
}

// by Jianying Shi.
// Hanlder of Menu Setting
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[ScanTableViewCell class] forCellReuseIdentifier:@"Cell"];

    // Added by Jianying Shi
    // 04/19/2015

    // -- Scan Mooshimeter button
    UIBarButtonItem* nav_scan_btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reloadicon"] style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(handleScanViewRefreshRequest)];
    
    if( self.navigationItem != nil )
        self.navigationItem.leftBarButtonItem = nav_scan_btn;
    
    // Long-press table-view handler
    UILongPressGestureRecognizer *longpressScanSetting = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressScanSetting:)];
    
    longpressScanSetting.minimumPressDuration = 2.0;
    longpressScanSetting.delegate = self;
    
    [self.tableView addGestureRecognizer:longpressScanSetting];
}

#pragma mark - View lifecycle
-(void)viewDidAppear:(BOOL)animated
{
    // [self setTitle:@"Swipe down to scan"]
    // [self setTitle:@"Tap Scan Button"];
    
    if(g_meter) {
        // If we've appeared, disconnect whatever we were talking to.
        [g_meter disconnect:nil];
    }
    // Start a new scan for meters
    [self.delegate handleScanViewRefreshRequest];
}

-(BOOL)shouldAutorotate { return NO; }

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Long-press menu
- (void) longpressScanSetting :(UILongPressGestureRecognizer *)gestureRecognizer
{
    // Check if menu is currently showing.
    UIView* existMenu = [self.view viewWithTag:kContextMenu_Tag];
    if( existMenu != nil )
        return;
    
    if (!settingsMenu) {
        
        settingsMenu = [KxMenu new];
        settingsMenu.menuItems = self.createSettingsMenuItems;
        settingsMenu.blurredBackground = NO;
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            settingsMenu.blurredBackground = YES;
        }
        
        settingsMenu.tintColor = [UIColor darkGrayColor];//[[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        settingsMenu.tintColor1 = [UIColor lightGrayColor];
        
        settingsMenu.selectedColor  = [UIColor colorWithRed:0.9f green:0 blue:0 alpha:1.f];
        settingsMenu.selectedColor1 = [UIColor colorWithRed:0.8f green:0 blue:0 alpha:1.f];
    }
    
    // Check tapped table view cell
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        // Display setting menu
        CGRect boundRect = CGRectMake(p.x, p.y, 5, 5);
        boundRect.origin.y += 64;
        
        [settingsMenu setTag : indexPath.row + kContextMenu_Tag];
        [settingsMenu showMenuInView:self.tableView
                            fromRect:boundRect];
        
        // Display auto-connect checked state
        ScanTableViewCell* c = (ScanTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        LGPeripheral* peripheral = c.p;
        
        NSMutableArray* savedUUIDs = [[NSUserDefaults standardUserDefaults] objectForKey : @"autoUUIDs"];
        NSString* deviceUUID = [peripheral UUIDString];
        
        KxMenuItem* checkItem = settingsMenu.menuItems[2];
      
        if( savedUUIDs != nil && savedUUIDs.count > 0 )
        {
            for(int i = 0; i < savedUUIDs.count; i ++) {
                if( [[savedUUIDs objectAtIndex:i] isEqualToString:deviceUUID] )
                {
                    checkItem.image = [UIImage imageNamed:@"checkicon"];
                    break;
                }
            }
        }
        else {
            checkItem.image = nil;
        }
    } else {
        NSLog(@"gestureRecognizer.state = %d", gestureRecognizer.state);
    }
}


- (NSArray*) createSettingsMenuItems {
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Setting"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"Firmware Update"
                     image:nil
                    target:self
                    action:@selector(firmwareUpdatePressed:)],
      
      [KxMenuItem menuItem:@"Auto Connect"
                     image:[UIImage imageNamed:@"checkicon"]
                    target:self
                    action:@selector(autoConnectPressed:)],
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    return menuItems;
}

#pragma mark - Menu Item Press Handler

- (void) firmwareUpdatePressed : (id) sender
{
#if 0 // MARK
    
    NSLog(@"Firmware Update");
    
    // By Jianying Shi. 05/02/2015
    // First of all, connect to peripheral
    
    // Get selected table view cell
    NSInteger tag = settingsMenu.tag;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    
    ScanTableViewCell* c = (ScanTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [self.delegate handleScanViewSelect:c.p];

    // Then upldate
    // [self.delegate updateFirmwareIfNeeded];
#endif
}

- (void) autoConnectPressed : (id) sender
{
    NSLog(@"Auto connect");
    
    NSString* deviceUUID = [g_meter.p UUIDString];
    if( deviceUUID )
    {
        // Save current device UUID to user defaults
        NSMutableArray* savedUUIDs = (NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"autoUUIDs"];
        if( savedUUIDs != nil ) // already has saved id
            [savedUUIDs addObject:deviceUUID];
        else {
            savedUUIDs = [[NSMutableArray alloc] initWithObjects:deviceUUID, nil];
        }
            
        [[NSUserDefaults standardUserDefaults] setObject:savedUUIDs forKey:@"autoUUIDs"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

-(void)settings_button_press {
    if(!self.settings_view) {
        CGFloat fixedHeight = 250;
        CGRect frame = self.view.frame;
        frame.origin.x += .05*frame.size.width;
        frame.origin.y += (frame.size.height - fixedHeight)/2;
        frame.size.width  *= 0.9;
        frame.size.height =  fixedHeight;
        ScanSettingsView* g = [[ScanSettingsView alloc] initWithFrame:frame];
        [g setBackgroundColor:[UIColor darkGrayColor]];
        [g setAlpha:0.9];
        
        // Make round rect of settings view
        g.layer.cornerRadius = 25;
        g.layer.masksToBounds = YES;
        
        self.settings_view = g;
        self.settings_view.delegate = self;
    }
    if([self.view.subviews containsObject:self.settings_view]) {
        [self.settings_view removeFromSuperview];
    } else {
        [self.view addSubview:self.settings_view];
    }
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"RowCount");
#ifdef SIMULATED_METER
    return self.peripherals.count+1;
#else
    return self.peripherals.count;
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LGPeripheral* p;
    NSLog(@"Cell %d",(int)indexPath.row);
    if(indexPath.row >= self.peripherals.count) {
        p = nil;
    } else {
        p = [self.peripherals objectAtIndex:indexPath.row];
    }
    
    ScanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Add progress view to show signal strength
    // Updated by Jianying Shi. 05/02/2015
    // Detect if progress view has already created.
    MPBarsGraphView* chartView = (MPBarsGraphView*) [cell viewWithTag:indexPath.row + kRSSIView_Tag];
    if( chartView == nil ) { // Not yet created
        
        CGRect cellBounds = [cell frame];
        CGRect chartRect = CGRectMake(cellBounds.size.width - 80, 10, 30, cellBounds.size.height - 20);
        
        chartView = [MPPlot plotWithType : MPPlotTypeBars frame : chartRect];
        chartView.valueRanges = MPMakeGraphValuesRange(0, 100);
        chartView.values = [[NSArray alloc] initWithObjects:@0, @0, @0, @0, @0, nil];
        chartView.graphColor = [UIColor colorWithRed:0.120 green:0.806 blue:0.157 alpha:1.000];
        
        [chartView setTag:indexPath.row + kRSSIView_Tag];
        
        [cell addSubview : chartView];
    }
    
    // Set signal strength as percent.
    // Assuming RSSI Value range -100 ~ 0
    CGFloat percentage = (p.RSSI + 100);
    
    NSInteger step = Round(percentage / 20.0); // 20.f = Tick
    NSMutableArray* valueArray = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < 5; i ++) {
        
        if( i < step )
            [valueArray addObject:@((i+1) * 20)];
        else
            [valueArray addObject:@0];
    }
    
    chartView.values = [NSArray arrayWithArray:valueArray];
    
    [cell setPeripheral:p];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {return NO;}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"You clicked a meter");
    ScanTableViewCell* c = (ScanTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [self.delegate handleScanViewSelect:c.p];
}

#pragma mark - ScanSettingViewDelegate

- (NSString *)platformRawString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSString *)platformNiceString {
    NSString *platform = [self platformRawString];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (4G,2)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (4G,3)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

- (void) handleSendSupporMail
{
    
    if( [MFMailComposeViewController canSendMail] )
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Support Request"];
        
        // Compose Message Body
        NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
        NSString *devLabel = [self platformRawString];
        
        NSString* hardwareVersion = [NSString stringWithFormat:@"iOS version : %@ v%@\n", devLabel, iOSVersion];
        NSString* bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString* appVersionString = [NSString stringWithFormat:@"Mooshimeter iOS App Version = %@\n", bundleVersion];
        NSString* mailBody = [hardwareVersion stringByAppendingString:appVersionString];
        
        [mail setMessageBody:mailBody isHTML:NO];
        [mail setToRecipients:@[@"hello@moosh.im"]];
        
        [self presentViewController:mail animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Support Mail" message:@"This device can not send mail." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Support Mail" message:@"Mail sent." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"You sent the email.");
        }
            break;
        case MFMailComposeResultSaved:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Support Mail" message:@"Saved a draft of this email." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"You saved a draft of this email");
        }
            break;
        case MFMailComposeResultCancelled:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Support Mail" message:@"Cancelled sending this email." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"You cancelled sending this email.");
        }
            break;
        case MFMailComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Support Mail" message:@"An error occurred when trying to compose this email." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
        }
            break;
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Support Mail" message:@"An error occurred when trying to compose this email." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            NSLog(@"An error occurred when trying to compose this email");
        }
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
