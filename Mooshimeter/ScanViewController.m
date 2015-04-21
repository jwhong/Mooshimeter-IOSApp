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

// Uncomment if you want a simulated meter to appear in the scan list
#define SIMULATED_METER

#define kRSSIView_Tag       1000
#define kContextMenu_Tag    2000

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
    NSString* savedUUID = [[NSUserDefaults standardUserDefaults] objectForKey : @"autoUUID"];
    if( savedUUID != nil && savedUUID.length > 0 )
    {
        for( NSInteger i = 0; i < self.peripherals.count; i ++ )
        {
            LGPeripheral* p = self.peripherals[i];
            if( [[p UUIDString] isEqualToString:savedUUID] == YES )
            {
                [self.delegate handleScanViewSelect:p];
                break;
            }
        }
    }
}

// by Jianying Shi.
// Hanlder of Menu Setting
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[ScanTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
#if 0
    NSLog(@"Creating refresh handler...");
    UIRefreshControl *rescan_control = [[UIRefreshControl alloc] init];
    [rescan_control addTarget:self.delegate action:@selector(handleScanViewRefreshRequest) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rescan_control;
#endif
    
    // Added by Jianying Shi
    // 04/19/2015
    
    // -- Scan Mooshimeter button
    // UIBarButtonItem* nav_scan_btn = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self.delegate action:@selector(handleScanViewRefreshRequest)];
    UIBarButtonItem* nav_scan_btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reloadicon"] style:UIBarButtonItemStyleBordered target:self.delegate action:@selector(handleScanViewRefreshRequest)];
    
#if 0
    // -- Scan settings button
    UIButton *menu_button = [UIButton buttonWithType:UIButtonTypeSystem];
    menu_button.frame = CGRectMake(0.0, 0.0, 44, 30);
    // [setting_button setTitle:@"Setting" forState : UIControlStateNormal];
    [menu_button setImage:[UIImage imageNamed:@"menuicon"] forState:UIControlStateNormal];
    
    UILongPressGestureRecognizer *longpressScanSetting = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressScanSetting:)];
    [menu_button addGestureRecognizer:longpressScanSetting];
    
    UIBarButtonItem* nav_menu_button = [[UIBarButtonItem alloc] initWithCustomView:menu_button];
    
    NSArray* navButtonArray = [[NSArray alloc] initWithObjects:nav_scan_btn, nav_menu_button, nil];
    
    if( self.navigationItem != nil )
        self.navigationItem.leftBarButtonItems = navButtonArray;
#endif
    
    if( self.navigationItem != nil )
        self.navigationItem.leftBarButtonItem = nav_scan_btn;
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

-(void)settings_button_press {
    if(!self.settings_view) {
        CGRect frame = self.view.frame;
        frame.origin.x += .05*frame.size.width;
        frame.origin.y += (frame.size.height - 250)/2;
        frame.size.width  *= 0.9;
        frame.size.height =  250;
        ScanSettingsView* g = [[ScanSettingsView alloc] initWithFrame:frame];
        [g setBackgroundColor:[UIColor whiteColor]];
        [g setAlpha:0.9];
        self.settings_view = g;
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
    // By Jianying Shi. 04/19/2015
    // Detect if progress view has already created.
    LDProgressView* viewForCell = (LDProgressView*) [cell viewWithTag:indexPath.row + kRSSIView_Tag];
    if( viewForCell == nil ) // Already create
    {
        CGRect cellBounds = [cell frame];
        CGRect progressRect = CGRectMake(cellBounds.size.width * 0.70f, cellBounds.size.height / 2 - 5, cellBounds.size.width * 0.25f, 10);
        LDProgressView* rssi_view = [[LDProgressView alloc] initWithFrame:progressRect]; //[[LDProgressView alloc] initWithProgressViewStyle : UIProgressViewStyleDefault];
        [rssi_view setTag:indexPath.row + kRSSIView_Tag];
        rssi_view.showText = @NO;
        rssi_view.borderRadius = @5;
        rssi_view.type = LDProgressSolid;
        [cell addSubview:rssi_view];
        
        viewForCell = rssi_view;
    }
    // Set signal strength as percent.
    // Assuming RSSI Value range -100 ~ 0
    float percentage = (p.RSSI + 100) / 100.f;
    viewForCell.progress = percentage;
    
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

@end
