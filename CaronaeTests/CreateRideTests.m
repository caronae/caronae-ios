#import <XCTest/XCTest.h>
#import "CaronaeDefaults.h"
#import "CreateRideViewController.h"

@interface CreateRideTests : XCTestCase
@property (nonatomic) CreateRideViewController *vc;
@end

@implementation CreateRideTests

- (void)setUp {
    [super setUp];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _vc = [storyboard instantiateViewControllerWithIdentifier:@"CreateRide"];
    [_vc performSelectorOnMainThread:@selector(view) withObject:nil waitUntilDone:YES];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGenerateRideDictionarySingleNormal {
    NSString *dateString = @"2015-11-12 10:01:40";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    _vc.neighborhood = @"Jardim Guanabara";
    _vc.zone = @"Zona Norte";
    _vc.selectedHub = @"CT";
    _vc.reference.text = @"Praia da Bica";
    _vc.route.text = @"via Jardim";
    _vc.slotsStepper.value = 3;
    _vc.notes.text = @"Fumante";
    _vc.segmentedControl.selectedSegmentIndex = 1;
    _vc.rideDate = date;
    _vc.routineSwitch.on = NO;
    
    NSDictionary *ride = [_vc generateRideDictionaryFromView];
    XCTAssertNotNil(ride, @"Generated ride dictionary should not be nil.");
    XCTAssertEqualObjects(ride[@"myzone"], @"Zona Norte");
    XCTAssertEqualObjects(ride[@"neighborhood"], @"Jardim Guanabara");
    XCTAssertEqualObjects(ride[@"hub"], @"CT");
    XCTAssertEqualObjects(ride[@"place"], @"Praia da Bica");
    XCTAssertEqualObjects(ride[@"route"], @"via Jardim");
    XCTAssertEqualObjects(ride[@"mydate"], @"12/11/2015", @"Date or date format does not match.");
    XCTAssertEqualObjects(ride[@"mytime"], @"10:01:40", @"Time or time format does not match.");
    XCTAssertEqualObjects(ride[@"slots"], @(3));
    XCTAssertEqualObjects(ride[@"description"], @"Fumante");
    XCTAssertEqualObjects(ride[@"going"], @(NO));
    XCTAssertEqualObjects(ride[@"week_days"], NSNull.null, @"week_days should be empty because ride is not a routine.");
    XCTAssertEqualObjects(ride[@"repeats_until"], NSNull.null, @"repeats_until should be empty because ride is not a routine.");
}

- (void)testGenerateRideDictionaryRoutineNormal {
    NSString *dateString = @"2015-11-12 10:02:03";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    _vc.neighborhood = @"Ipanema";
    _vc.zone = @"Zona Sul";
    _vc.selectedHub = @"CCMN";
    _vc.reference.text = @"Farme de Amoedo";
    _vc.route.text = @"Lagoa";
    _vc.slotsStepper.value = 4;
    _vc.notes.text = @"Sei lá";
    _vc.segmentedControl.selectedSegmentIndex = 0;
    _vc.rideDate = date;
    _vc.routineSwitch.on = YES;
    _vc.weekDays = @[@"4", @"2"].mutableCopy;
    _vc.routineDurationMonths = 3;
    
    NSDictionary *ride = [_vc generateRideDictionaryFromView];
    XCTAssertNotNil(ride, @"Generated ride dictionary should not be nil.");
    XCTAssertEqualObjects(ride[@"myzone"], @"Zona Sul");
    XCTAssertEqualObjects(ride[@"neighborhood"], @"Ipanema");
    XCTAssertEqualObjects(ride[@"hub"], @"CCMN");
    XCTAssertEqualObjects(ride[@"place"], @"Farme de Amoedo");
    XCTAssertEqualObjects(ride[@"route"], @"Lagoa");
    XCTAssertEqualObjects(ride[@"mydate"], @"12/11/2015", @"Date or date format does not match.");
    XCTAssertEqualObjects(ride[@"mytime"], @"10:02:03", @"Time or time format does not match.");
    XCTAssertEqualObjects(ride[@"slots"], @(4));
    XCTAssertEqualObjects(ride[@"description"], @"Sei lá");
    XCTAssertEqualObjects(ride[@"going"], @(YES));
    XCTAssertEqualObjects(ride[@"week_days"], @"2,4", @"week_days string did not match expected format.");
    XCTAssertEqualObjects(ride[@"repeats_until"], @"12/02/2016", @"repeats_until date not calculated successfully.");
}

@end
