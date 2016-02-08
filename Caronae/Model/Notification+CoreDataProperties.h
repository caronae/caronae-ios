//
//  Notification+CoreDataProperties.h
//  Caronae
//
//  Created by Mario Cecchi on 06/02/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Notification.h"

NS_ASSUME_NONNULL_BEGIN

@interface Notification (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *rideID;

@end

NS_ASSUME_NONNULL_END
