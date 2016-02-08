#import <XCTest/XCTest.h>
#import "User.h"

@interface UserTests : XCTestCase

@end

@implementation UserTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitFromJSON {
    NSDictionary *dictionary = @{
        @"id": @(1),
        @"car_color": @"Pretofg ",
        @"car_plate": @"KXD-4180",
        @"remember_token": [NSNull null],
        @"phone_number": @"21998781890",
        @"created_at": @"2015-11-23 15:44:29",
        @"car_model": @"Hyundai i30",
        @"profile": @"Perfil padrão",
        @"profile_pic_url": @"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xtp1/v/t1.0-1/p200x200/12122821_10153262973118178_266576737123138808_n.jpg?oh=72108d1ac98a59f7078bd63f5f98d233&oe=56FD09E3&__gda__=1463145729_70c1ca76425b46a79f4a4163c9751562",
        @"car_owner": @(YES),
        @"deleted_at": [NSNull null],
        @"location": @"Jardim Guanabara",
        @"face_id": @"10153370886868178",
        @"updated_at": @"2016-01-18 00:01:46",
        @"course": @"Ciência da Computação",
        @"face_token": @"CAANQZBSLv4a0BAMk63CzRXEFlJYFGbDfvxEV37xkaAXsicHKO9IZA3gbMX95MqW1WMZByiEAf8z1lOVjfMDjItuyk75S8rUO8Fxdd4wewPXZB2nfoXmOrZClUCVzijDSz478CIBlpXnnm62MhnKtPFgvYZA0UuxOg1tyRQbnkEs5JE7g8oUin2z4ObE9l30HSozd5ZBW9ykJ85ZCu1bbhNyihayhdemZA04mZBA0hdG52fMooUHUgv7EJp",
        @"email": @"macecchi@gmail.com",
        @"name": @"Mário Cecchi"
    };
    
    NSError *error;
    User *user = [MTLJSONAdapter modelOfClass:User.class fromJSONDictionary:dictionary error:&error];

    XCTAssertNil(error);
    
    XCTAssertEqualObjects(dictionary[@"id"], user.userID);
    XCTAssertEqualObjects(dictionary[@"name"], user.name);
    XCTAssertEqualObjects(dictionary[@"profile"], user.profile);
    XCTAssertEqualObjects(dictionary[@"course"], user.course);
    XCTAssertEqualObjects(dictionary[@"email"], user.email);
    XCTAssertEqualObjects(dictionary[@"phone_number"], user.phoneNumber);
    XCTAssertEqualObjects(dictionary[@"location"], user.location);
    XCTAssertEqual([dictionary[@"car_owner"] boolValue], user.carOwner);
    XCTAssertEqualObjects(dictionary[@"car_model"], user.carModel);
    XCTAssertEqualObjects(dictionary[@"car_plate"], user.carPlate);
    XCTAssertEqualObjects(dictionary[@"car_color"], user.carColor);
    XCTAssertEqualObjects(dictionary[@"profile_pic_url"], user.profilePictureURL);
    XCTAssertEqualObjects(dictionary[@"face_id"], user.facebookID);
    
    NSString *createdAtString = [[User dateFormatter] stringFromDate:user.createdAt];
    XCTAssertEqualObjects(dictionary[@"created_at"], createdAtString);
}


@end
