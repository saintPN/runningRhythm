//
//  RUN+CoreDataProperties.h
//  runningRhythm
//
//  Created by saintPN on 15/10/21.
//  Copyright © 2015年 saintPN. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "RUN.h"

NS_ASSUME_NONNULL_BEGIN

@interface RUN (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSDate *date;

@end

NS_ASSUME_NONNULL_END
