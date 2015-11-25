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
    
    _vc.origin.text = @"Jardim Guanabara";
    _vc.reference.text = @"Praia da Bica";
    _vc.route.text = @"via Jardim";
    // TODO: test center
    _vc.slotsStepper.value = 3;
    _vc.notes.text = @"Fumante";
    _vc.segmentedControl.selectedSegmentIndex = 1;
    _vc.rideDate = date;
    _vc.routineSwitch.on = NO;
    
    NSDictionary *ride = [_vc generateRideDictionaryFromView];
    XCTAssertNotNil(ride, @"Generated ride dictionary should not be nil.");
    XCTAssertEqualObjects(ride[@"myzone"], @"Norte");
    XCTAssertEqualObjects(ride[@"neighborhood"], @"Jardim Guanabara");
    XCTAssertEqualObjects(ride[@"place"], @"Praia da Bica");
    XCTAssertEqualObjects(ride[@"route"], @"via Jardim");
    XCTAssertEqualObjects(ride[@"mydate"], @"12/11/2015", @"Date or date format does not match.");
    XCTAssertEqualObjects(ride[@"mytime"], @"10:01", @"Time or time format does not match.");
    XCTAssertEqualObjects(ride[@"slots"], @(3));
    XCTAssertEqualObjects(ride[@"description"], @"Fumante");
    XCTAssertEqualObjects(ride[@"going"], @(NO));
    XCTAssertEqualObjects(ride[@"week_days"], @"", @"week_days should be empty because ride is not a routine.");
    XCTAssertEqualObjects(ride[@"repeats_until"], @"", @"repeats_until should be empty because ride is not a routine.");
    XCTAssertNotEqualObjects(ride[@"hub"], @"", @"hub should not be empty.");
}

- (void)testGenerateRideDictionaryRoutineNormal {
    NSString *dateString = @"2015-11-12 10:01:40";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    _vc.origin.text = @"Jardim Guanabara";
    _vc.reference.text = @"Praia da Bica";
    _vc.route.text = @"via Jardim";
    // TODO: test center
    _vc.slotsStepper.value = 4;
    _vc.notes.text = @"Fumante";
    _vc.segmentedControl.selectedSegmentIndex = 0;
    _vc.rideDate = date;
    _vc.routineSwitch.on = YES;
    _vc.weekDays = [NSMutableArray arrayWithObjects:@"4", @"2", nil];
    _vc.routineDurationMonths = 3;
    
    NSDictionary *ride = [_vc generateRideDictionaryFromView];
    XCTAssertNotNil(ride, @"Generated ride dictionary should not be nil.");
    XCTAssertEqualObjects(ride[@"myzone"], @"Norte");
    XCTAssertEqualObjects(ride[@"neighborhood"], @"Jardim Guanabara");
    XCTAssertEqualObjects(ride[@"place"], @"Praia da Bica");
    XCTAssertEqualObjects(ride[@"route"], @"via Jardim");
    XCTAssertEqualObjects(ride[@"mydate"], @"12/11/2015", @"Date or date format does not match.");
    XCTAssertEqualObjects(ride[@"mytime"], @"10:01", @"Time or time format does not match.");
    XCTAssertEqualObjects(ride[@"slots"], @(4));
    XCTAssertEqualObjects(ride[@"description"], @"Fumante");
    XCTAssertEqualObjects(ride[@"going"], @(YES));
    XCTAssertEqualObjects(ride[@"week_days"], @"2,4", @"week_days string did not match expected format.");
    XCTAssertEqualObjects(ride[@"repeats_until"], @"12/02/2016", @"repeats_until date not calculated successfully.");
    XCTAssertNotEqualObjects(ride[@"hub"], @"", @"hub should not be empty.");
}

- (void)testParseCreatedRidesNormal {
    NSError *error;
    NSArray *responseObject = @[@{ @"id": @(4203) }];
    
    NSArray *createdRides = [CreateRideViewController parseCreateRidesFromResponse:responseObject withError:&error];
    XCTAssertNil(error, @"Error object should be nil.");
    XCTAssertEqualObjects(responseObject, createdRides, @"Original response object and created rides object do not match.");
}

- (void)testParseCreatedRidesUnexpectedReponse {
    NSError *error;
    NSDictionary *responseObject = @{ @"id": @(4203) };
    
    NSArray *createdRides = [CreateRideViewController parseCreateRidesFromResponse:responseObject withError:&error];
    XCTAssertNotNil(error, @"Error object should exist because the response was invalid.");
    XCTAssertEqual(error.code, CaronaeErrorInvalidResponse, @"Error should have returned code for invalid server response.");
    XCTAssertNil(createdRides, @"Created rides object should be nil because response was invalid.");
}

- (void)testParseCreatedRidesNoRidesCreated {
    NSError *error;
    NSArray *responseObject = @[];
    
    NSArray *createdRides = [CreateRideViewController parseCreateRidesFromResponse:responseObject withError:&error];
    XCTAssertNotNil(error, @"Error object should exist because the response was empty.");
    XCTAssertEqual(error.code, CaronaeErrorNoRidesCreated, @"Error should have returned code for no rides created.");
    XCTAssertNil(createdRides, @"Created rides object should be nil because response was invalid.");
}

@end
