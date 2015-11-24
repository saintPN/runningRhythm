//
//  Location+CoreDataProperties.h
//  runningRhythm
//
//  Created by saintPN on 15/11/14.
//  Copyright © 2015年 saintPN. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Location.h"

NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) RUN *run;

@end

NS_ASSUME_NONNULL_END
