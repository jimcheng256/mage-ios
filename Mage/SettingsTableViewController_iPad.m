//
//  SettingsTableViewController_iPad.m
//  MAGE
//
//

#import "SettingsTableViewController_iPad.h"
#import "LocationService.h"
#import "User.h"
#import "MageServer.h"
#import "EventChooserController.h"
#import "Event.h"

@interface SettingsTableViewController_iPad () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *locationServicesStatus;
@property (weak, nonatomic) IBOutlet UILabel *dataFetchStatus;
@property (weak, nonatomic) IBOutlet UILabel *imageUploadSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *baseServerUrl;
@property (weak, nonatomic) IBOutlet UILabel *user;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (nonatomic, assign) BOOL showDisclaimer;

@end

@implementation SettingsTableViewController_iPad

- (void) viewDidLoad {
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.showDisclaimer = [defaults objectForKey:@"showDisclaimer"] != nil && [[defaults objectForKey:@"showDisclaimer"] boolValue];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Select the first row in the first section by default
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    
    self.versionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];

    User *user = [User fetchCurrentUserInManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    self.user.text = user.name;
    
    [self setLocationServicesLabel];
    
    Event *e = [Event getCurrentEvent];
    self.eventNameLabel.text = e.name;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.baseServerUrl.text = [[MageServer baseURL] absoluteString];
    
    if ([[defaults objectForKey:@"dataFetchEnabled"] boolValue]) {
        [self.dataFetchStatus setText:@"On"];
    } else {
        [self.dataFetchStatus setText:@"Off"];
    }
    
    [self setPreferenceDisplayLabel:_imageUploadSizeLabel forPreference:@"imageUploadSizes"];
}

- (void) setLocationServicesLabel {
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse || authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
        if ([defaults boolForKey:kReportLocationKey]) {
            [self.locationServicesStatus setText:@"On"];
        } else {
            [self.locationServicesStatus setText:@"Off"];
        }
    } else {
        [self.locationServicesStatus setText:@"Disabled"];
    }
}

- (void) setPreferenceDisplayLabel : (UILabel*) label forPreference: (NSString*) prefValuesKey {
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    NSDictionary *frequencyDictionary = [defaults dictionaryForKey:prefValuesKey];
    NSArray *labels = [frequencyDictionary valueForKey:@"labels"];
    NSArray *values = [frequencyDictionary valueForKey:@"values"];
    
    NSNumber *frequency = [defaults valueForKey:[frequencyDictionary valueForKey:@"preferenceKey"]];
    
    for (int i = 0; i < values.count; i++) {
        if ([frequency integerValue] == [[values objectAtIndex:i] integerValue]) {
            [label setText:[labels objectAtIndex:i]];
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.settingSelectionDelegate selectedSetting:@"locationServicesSettings"];
        } else if (indexPath.row == 1) {
            [self.settingSelectionDelegate selectedSetting:@"dataFetchingSettings"];
        }
   } else if (indexPath.section == 3) {
       if (indexPath.row == 0) {
           [self.settingSelectionDelegate selectedSetting:@"disclaimerSettings"];
       } else if (indexPath.row == 1) {
           [self.settingSelectionDelegate selectedSetting:@"attributionsSettings"];
       }
   }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"unwindToEventChooserSegue"]) {
        EventChooserController *viewController = [segue destinationViewController];
        [viewController setForcePick:YES];
    }
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self setLocationServicesLabel];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 3 && [indexPath row] == 0) {
        cell.hidden = !self.showDisclaimer;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 3 && [indexPath row] == 0 && !self.showDisclaimer) {
        return 0;
    }
    
    return UITableViewAutomaticDimension;
}

@end
