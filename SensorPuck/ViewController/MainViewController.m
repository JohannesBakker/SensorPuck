//
//  MainViewController.m
//  SensorPuck
//
//  Created by RuiFeng on 4/17/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import "MainViewController.h"
#import "MFSideMenu.h"
#import "Common.h"
#import "Constant.h"
#import "DBManager.h"
#import "ChartView.h"

#define BORDER_WIDTH    (CGFloat)1
#define BORDER_HEIHGT    (CGFloat)5

@interface MainViewController () {
    BOOL isCel;
    Puck* _oldPuck;
   
    //======== Global variables used in HRM processing
    int MaxDelta;
    int Gain;
    int PrevDelta;
    int BPF_ORDER;
    int BPF_FILTER_LEN;

    NSMutableArray  *BPF_In;
    NSMutableArray  *BPF_Out;
    NSArray         *BPF_a;
    NSArray         *BPF_b;
    
    NSTimer *timer;
    BOOL isFlash;
}

@property (weak, nonatomic) IBOutlet UIView *viewNoDevice;
@property (weak, nonatomic) IBOutlet UIView *viewCurrentDevice;
@property (weak, nonatomic) IBOutlet UIView *viewGraph;
@property (weak, nonatomic) IBOutlet ChartView *viewGraphRange;
@property (weak, nonatomic) IBOutlet UILabel *labelTemp;
@property (weak, nonatomic) IBOutlet UILabel *labelHumidity;
@property (weak, nonatomic) IBOutlet UILabel *labelUVIndex;
@property (weak, nonatomic) IBOutlet UILabel *labelLight;
@property (weak, nonatomic) IBOutlet UIImageView *imgCel;
@property (weak, nonatomic) IBOutlet UIImageView *imgFah;
@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UILabel *labelBioStatus;
@property (weak, nonatomic) IBOutlet UIView *viewBattery;
@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblBatteryStatus;

@end

@implementation MainViewController

@synthesize isEnvironmentMode;
@synthesize bleManager;
@synthesize scanManager;

+(instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupMenuBarButtonItems];
    [self addTextFieldBorder];
    
    isCel = YES;
    isEnvironmentMode = YES;
    _oldPuck = [[Puck alloc] init];
    
    self.viewNoDevice.hidden = NO;
    self.viewCurrentDevice.hidden = YES;
    
    [self initVariable];
    
    isFlash = YES;
    
    bleManager = [BleManager sharedInstance];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
    
    bleManager.delegateMainView = self;
    scanManager = [[ScanManager alloc] init];
    
    [scanManager restartScan];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [scanManager stopScan];
    bleManager.delegateMainView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariable {
    BPF_ORDER = 4;
    BPF_FILTER_LEN = BPF_ORDER * 2 + 1;
    
    [self loadBPFData];
}

-(void)loadBPFData
{
    //-----BPF Initializations
    BPF_In = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
              [NSNumber numberWithInt:0],
              [NSNumber numberWithInt:0],
              [NSNumber numberWithInt:0],
              [NSNumber numberWithInt:0],
              [NSNumber numberWithInt:0],
              [NSNumber numberWithInt:0],
              [NSNumber numberWithInt:0],
              [NSNumber numberWithInt:0],nil];
    
    BPF_Out = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
               [NSNumber numberWithInt:0],
               [NSNumber numberWithInt:0],
               [NSNumber numberWithInt:0],
               [NSNumber numberWithInt:0],
               [NSNumber numberWithInt:0],
               [NSNumber numberWithInt:0],
               [NSNumber numberWithInt:0],
               [NSNumber numberWithInt:0],nil];
    
    BPF_a = @[ @1.000000000000000e+000,
               @-5.805700439644110e+000,
               @1.514036628292202e+001,
               @-2.323300817159229e+001,
               @2.298582338785502e+001,
               @-1.502165263561143e+001,
               @6.331004788861760e+000,
               @-1.573336063098673e+000,
               @1.767891944741809e-001];
    
    BPF_b = @[@5.392924554970057e-003,
              @0,
              @-2.157169821988023e-002,
              @0,
              @3.235754732982035e-002,
              @0,
              @-2.157169821988023e-002,
              @0,
              @5.392924554970057e-003];
    
    PrevDelta = 0;
    MaxDelta = 0;
    Gain = 1;
}

-(double)BPF_FilterProcess:(int)raw_value
{
    double retVal = 0.0f;
    //BPF: [BPF_b,BPF_a] = butter(4,[60 300]/60/Fs*2);
    /*
     The filter is a "Direct Form II Transposed" implementation of the standard difference equation:
     a(1)*y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb)
     - a(2)*y(n-1) - ... - a(na+1)*y(n-na)
     */
    
    /* Shift the BPF in/out data buffers and add the new input sample */
    for ( int i=BPF_FILTER_LEN-1; i>0; i-- )
    {
        [BPF_In replaceObjectAtIndex:i withObject:[BPF_In objectAtIndex:i-1]];
        [BPF_Out replaceObjectAtIndex:i withObject:[BPF_Out objectAtIndex:i-1]];
    }
    
    /* Add the new input sample */
    [BPF_In replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:raw_value]];
    [BPF_Out replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:0]];
    
    
    /* a(1)=1, y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb+1)*x(n-nb) */
    for ( int j = 0; j < BPF_FILTER_LEN; j++ )
    {
        double bpfb = [[BPF_b objectAtIndex:j] doubleValue];
        double bpfin = [[BPF_In objectAtIndex:j] doubleValue];
        double bpfout = [[BPF_Out objectAtIndex:0] doubleValue];
        bpfout +=bpfb*bpfin;
        [BPF_Out replaceObjectAtIndex:0 withObject:[NSNumber numberWithDouble:bpfout]];
    }
    
    /* y =y(n)- a(2)*y(n-1) - ... - a(na+1)*y(n-na) */
    for ( int j = 1; j < BPF_FILTER_LEN; j++ )
    {
        double bpfout = [[BPF_Out objectAtIndex:0] doubleValue];
        double bpfa = [[BPF_a objectAtIndex:j] doubleValue];
        double bpfoutj = [[BPF_Out objectAtIndex:j] doubleValue];
        bpfout-=bpfa*bpfoutj;
        [BPF_Out replaceObjectAtIndex:0 withObject:[NSNumber numberWithDouble:bpfout]];
    }
    
    retVal = [[BPF_Out objectAtIndex:0] doubleValue]+0.5;
    
    return retVal;
}

#pragma mark -
#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
}

- (void)addTextFieldBorder {
    [[Common sharedInstance] addBottomBorderWithColor:self.textName color:[UIColor grayColor] andWidth:BORDER_WIDTH];
    [[Common sharedInstance] addLeftBorderWithColorAndHeight:self.textName color:[UIColor grayColor] andWidth:BORDER_WIDTH andHeight:BORDER_HEIHGT];
    [[Common sharedInstance] addRightBorderWithColorAndHeight:self.textName color:[UIColor grayColor] andWidth:BORDER_WIDTH andHeight:BORDER_HEIHGT];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"icon_menu"] forState:UIControlStateNormal];
    [button setTintColor:[UIColor grayColor]];
    [button addTarget:self action:@selector(onLeftSideMenuClicked:)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 7, 32, 20)];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 180, 20)];
    [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
    [label setText:@"Silicon Labs Sensor Puck"];
    [label setTextColor:[UIColor redColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [button addSubview:label];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return barButton;
}

#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)onLeftSideMenuClicked:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (IBAction)onInformationClicked:(id)sender {
    [self performSegueWithIdentifier:@"gotoInfo" sender:self];
}

- (IBAction)onTempClicked:(id)sender {
    if (isCel) {
        isCel = NO;
        [self.imgCel setImage:[UIImage imageNamed:@"btn_celsius_normal"]];
        [self.imgFah setImage:[UIImage imageNamed:@"btn_fahrenheit_pressed"]];
    } else {
        isCel = YES;
        [self.imgCel setImage:[UIImage imageNamed:@"btn_celsius_pressed"]];
        [self.imgFah setImage:[UIImage imageNamed:@"btn_fahrenheit_normal"]];
    }
}
- (IBAction)onNameEditClick:(id)sender {
    [self.textName becomeFirstResponder];
}

- (void)onReadSensorData:(Puck *)puck {
    if (puck._measurementMode == ENVIRONMENTAL_MODE) {
        self.viewGraph.hidden = YES;
        [puck._HRMSample removeAllObjects];
        [self.viewGraphRange clearGraph];
    } else if (puck._measurementMode == BIOMETRIC_MODE) {
        self.viewGraph.hidden = NO;
    }
    
    if (puck._measurementMode == ENVIRONMENTAL_MODE) {
        if (isCel)
            self.labelTemp.text = [NSString stringWithFormat:@"%.1f °C", puck._temperature];
        else
            self.labelTemp.text = [NSString stringWithFormat:@"%.1f °F", (puck._temperature * 9) /5 + 32];
        self.labelHumidity.text = [NSString stringWithFormat:@"%.1f %%", puck._humidity];
        self.labelLight.text = [NSString stringWithFormat:@"%d lux", puck._ambientLight];
        self.labelUVIndex.text = [NSString stringWithFormat:@"%d", puck._uvIndex];
        if (puck._baterry > 2.7) {
            self.viewInfo.hidden = NO;
            self.viewBattery.hidden = YES;
            if (timer != nil) {
                [timer invalidate];
                timer = nil;
            }
        }
        else {
            self.viewInfo.hidden = YES;
            self.viewBattery.hidden = NO;
            if (timer == nil) {
                isFlash = YES;
                timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(onBatteryFlash) userInfo:nil repeats:YES];
            }
        }
        if ([_oldPuck._address isEqualToString:puck._address] == NO) {
            self.textName.text = puck._name;
            _oldPuck = puck;
        }
    }
    
    if (puck._measurementMode == BIOMETRIC_MODE) {
        switch (puck._HRMState) {
            case HRM_STATE_IDLE:
                self.labelBioStatus.text = @"Idle";
                break;
            case HRM_STATE_NOSIGNAL:
                self.labelBioStatus.text = @"No Signal";
                break;
            case HRM_STATE_ACQUIRING:
                self.labelBioStatus.text = @"Acquiring";
                break;
            case HRM_STATE_ACTIVE:
                self.labelBioStatus.text = [NSString stringWithFormat:@"%d bpm", puck._HRMRate];
                break;
            case HRM_STATE_INVALID:
                self.labelBioStatus.text = @"Re-position Finger";
                break;
            case HRM_STATE_ERROR:
                self.labelBioStatus.text = @"Error";
                break;
            default:
                self.labelBioStatus.text = @"Idle";
                break;
        }
        
        if (puck._lostAdv > 0) {
            int lostSample = puck._lostAdv * HRM_SAMPLE_COUNT;
            
            NSMutableArray *filler = [NSMutableArray array];
            int nStep = 0;
            if ( (puck._HRMSample == nil) || [puck._HRMSample count] == 0)
                nStep = 0;
            else {
                nStep = ([[puck._HRMSample objectAtIndex:0] intValue] - puck._HRMPrevSample) / (lostSample + 1);
            }
            int sample = puck._HRMPrevSample + nStep;
            for ( int i = 0; i < lostSample; sample += nStep, i++) {
                [filler addObject:[NSNumber numberWithInt:sample]];
            }
            
            [self.viewGraphRange setGraphData:[self displaySamples:puck points:filler]];
            [self.viewGraphRange setNeedsDisplay];
        }
        
        [self.viewGraphRange setGraphData:[self displaySamples:puck points:puck._HRMSample]];
        [self.viewGraphRange setNeedsDisplay];
    }
}

- (void)onBatteryFlash {
    if (isFlash) {
        isFlash = NO;
        self.lblBatteryStatus.textColor = [UIColor whiteColor];
    }
    else {
        isFlash = YES;
        self.lblBatteryStatus.textColor = [UIColor clearColor];
    }
}

- (NSMutableArray *) displaySamples:(Puck *)puck points:(NSMutableArray *)array {
    int Delta;
    int AbsDelta;
    
    NSMutableArray *oldPoints = [self.viewGraphRange getOldPoints];
    for (int i = 0; i < array.count; i++) {
        int sample = [[array objectAtIndex:i] intValue];
        
        if ( oldPoints.count > GRAPH_DOMAIN_SIZE )
            [oldPoints removeObjectAtIndex:0];
        
        if ( puck._HRMState == HRM_STATE_ACTIVE )
        {
            /* Get the delta from the band pass filter */
            Delta = [self BPF_FilterProcess:sample];
            
            /* Find the absolute value of the delta */
            if ( Delta > 0 )
                AbsDelta =  Delta;
            else
                AbsDelta = -Delta;
            
            /* Find the maximum delta for the cycle */
            if ( AbsDelta > MaxDelta )
                MaxDelta = AbsDelta;
            
            /* Adjust the gain once per cycle when crossing the x axis */
            if ( (PrevDelta < 0) && (Delta > 0) )
            {
                if ( MaxDelta > 2000 )
                    Gain = 4;               /* Burst:             >2000 */
                else if ( MaxDelta > 1000 )
                    Gain = 10;              /* High:       1000 to 2000 */
                else if ( MaxDelta > 200 )
                    Gain = 20;              /* Normal-high: 200 to 1000 */
                else if ( MaxDelta > 20 )
                    Gain = 100;             /* Normal-low:   20 to 200  */
                else
                    Gain = 500;             /* Low:                 <20 */
                /* Gain = 10000 / MaxDelta; */
                
                MaxDelta = 0;
            }
            
            /* Note the previous delta */
            PrevDelta = Delta;
            
            /* Add the amplified delta to the end of the line */
            [oldPoints addObject:[NSNumber numberWithInt:(Delta*Gain)+(GRAPH_RANGE_SIZE/2)]];
        }
        else
            [oldPoints addObject:[NSNumber numberWithInt:GRAPH_RANGE_SIZE/2]];
    }
    
    return oldPoints;
}

- (void)getPucks:(NSMutableArray *)pucks {
    if (pucks == nil || pucks.count == 0){
        self.viewNoDevice.hidden = NO;
        self.viewCurrentDevice.hidden = YES;
    } else {
        self.viewNoDevice.hidden = YES;
        self.viewCurrentDevice.hidden = NO;
    }
}

#pragma textField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.textName) {
        Puck *currentPuck = [[BleManager sharedInstance] getCurrentPuck];
        if (currentPuck != nil) {
            NSString *newName = self.textName.text;
            if (newName) {
                if (newName.length == 0) {
                    newName = [currentPuck getPuckDefaultName];
                    self.textName.text = newName;
                }
                [[DBManager sharedInstance] saveAddress:currentPuck._address newAddress:newName];
                [[BleManager sharedInstance] updatePuckName:newName];
            }
        }
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
