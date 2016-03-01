#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface User : MTLModel <MTLJSONSerializing>

+ (NSDateFormatter *)dateFormatter;

@property (nonatomic, copy) NSNumber *userID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *profile;
@property (nonatomic, copy) NSString *course;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign) BOOL carOwner;
@property (nonatomic, copy) NSString *carModel;
@property (nonatomic, copy) NSString *carPlate;
@property (nonatomic, copy) NSString *carColor;
@property (nonatomic, copy) NSString *profilePictureURL;
@property (nonatomic, copy) NSString *facebookID;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, assign) int numRides;
@property (nonatomic, assign) int numDrives;

@property (readonly, nonatomic, copy) NSString *firstName;


@property (readonly, nonatomic, assign) BOOL isProfileIncomplete;

@end