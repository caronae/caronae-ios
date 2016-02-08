#import "User.h"

static NSDateFormatter *dateFormatter;

@implementation User

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"userID": @"id",
             @"profile": @"profile",
             @"course": @"course",
             @"email": @"email",
             @"phoneNumber": @"phone_number",
             @"location": @"location",
             @"carOwner": @"car_owner",
             @"carModel": @"car_model",
             @"carPlate": @"car_plate",
             @"carColor": @"car_color",
             @"profilePictureURL": @"profile_pic_url",
             @"facebookID": @"face_id",
             @"createdAt": @"created_at"
             };
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [[User dateFormatter] dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [[User dateFormatter] stringFromDate:date];
    }];
}

+ (NSDateFormatter *)dateFormatter {
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return dateFormatter;
}

- (NSString *)firstName {
    return [self.name componentsSeparatedByString:@" "].firstObject;
}

/*    
 "id": 1,
 "car_color": "Pretofg ",
 "car_plate": "KXD-4180",
 "remember_token": null,
 "phone_number": "21998781890",
 "created_at": "2015-11-23 15:44:29",
 "car_model": "Hyundai i30",
 "profile": "Perfil padrão",
 "profile_pic_url": "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xtp1/v/t1.0-1/p200x200/12122821_10153262973118178_266576737123138808_n.jpg?oh=72108d1ac98a59f7078bd63f5f98d233&oe=56FD09E3&__gda__=1463145729_70c1ca76425b46a79f4a4163c9751562",
 "car_owner": true,
 "deleted_at": null,
 "location": "Jardim Guanabara",
 "face_id": "10153370886868178",
 "updated_at": "2016-01-18 00:01:46",
 "course": "Ciência da Computação",
 "face_token": "CAANQZBSLv4a0BAMk63CzRXEFlJYFGbDfvxEV37xkaAXsicHKO9IZA3gbMX95MqW1WMZByiEAf8z1lOVjfMDjItuyk75S8rUO8Fxdd4wewPXZB2nfoXmOrZClUCVzijDSz478CIBlpXnnm62MhnKtPFgvYZA0UuxOg1tyRQbnkEs5JE7g8oUin2z4ObE9l30HSozd5ZBW9ykJ85ZCu1bbhNyihayhdemZA04mZBA0hdG52fMooUHUgv7EJp",
 "email": "macecchi@gmail.com",
 "name": "Mário Cecchi"*/

@end
