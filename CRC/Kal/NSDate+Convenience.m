//
//  NSDate+Convenience.m
//

@implementation NSDate (Convenience)

- (NSInteger)year {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear fromDate:self];
    return [components year];
}


- (NSInteger)month {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitMonth fromDate:self];
    return [components month];
}

- (NSInteger)day {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitDay fromDate:self];
    return [components day];
}

- (NSInteger)hour {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitHour fromDate:self];
    return [components hour];
}

- (NSDate *)offsetDay:(NSInteger)numDays {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    [gregorian setFirstWeekday:2]; //monday is first day
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:numDays];
    //[offsetComponents setHour:1];
    //[offsetComponents setMinute:30];
    
    return [gregorian dateByAddingComponents:offsetComponents
                                      toDate:self options:0];
}

- (NSDate *)offsetMonth:(NSInteger)numMonths {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //    [gregorian setFirstWeekday:2]; //monday is first day
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:numMonths];
    //[offsetComponents setHour:1];
    //[offsetComponents setMinute:30];
    
    return [gregorian dateByAddingComponents:offsetComponents
                                      toDate:self options:0];
}

- (BOOL)isToday
{
    return [[NSDate dateStartOfDay:self] isEqualToDate:[NSDate dateStartOfDay:[NSDate date]]];
}

+ (NSDate *)dateForDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = day;
    components.month = month;
    components.year = year;
    return [gregorian dateFromComponents:components];
}

+ (NSDate *)dateStartOfDay:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *components =
            [gregorian               components:(NSCalendarUnitYear | NSCalendarUnitMonth |
                    NSCalendarUnitDay) fromDate:date];
    return [gregorian dateFromComponents:components];
}

- (NSString *)weekString {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    switch (dateComponents.weekday) {
        case 1: {
            return NSLocalizedString(@"sunday", @"");
        }
            break;
            
        case 2: {
            return NSLocalizedString(@"monday", @"");
        }
            break;
            
        case 3: {
            return NSLocalizedString(@"tuesday", @"");
        }
            break;
            
        case 4: {
            return NSLocalizedString(@"wednesday", @"");
        }
            break;
            
        case 5: {
            return NSLocalizedString(@"thursday", @"");
        }
            break;
            
        case 6: {
            return NSLocalizedString(@"friday", @"");
        }
            break;
            
        case 7: {
            return NSLocalizedString(@"saturday", @"");
        }
            break;
            
        default:
            break;
    }
    
    return @"";
}

- (NSString *)monthString {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMonth fromDate:self];
    switch (dateComponents.month) {
        case 1: {
            return NSLocalizedString(@"January", @"");
        }
            break;
            
        case 2: {
            return NSLocalizedString(@"February", @"");
        }
            break;
            
        case 3: {
            return NSLocalizedString(@"March", @"");
        }
            break;
            
        case 4: {
            return NSLocalizedString(@"April", @"");
        }
            break;
            
        case 5: {
            return NSLocalizedString(@"May", @"");
        }
            break;
            
        case 6: {
            return NSLocalizedString(@"June", @"");
        }
            break;
            
        case 7: {
            return NSLocalizedString(@"July", @"");
        }
            break;
            
        case 8: {
            return NSLocalizedString(@"August", @"");
        }
            break;
            
        case 9: {
            return NSLocalizedString(@"September", @"");
        }
            break;
            
        case 10: {
            return NSLocalizedString(@"October", @"");
        }
            break;
            
        case 11: {
            return NSLocalizedString(@"November", @"");
        }
            break;
            
        case 12: {
            return NSLocalizedString(@"December", @"");
        }
            break;
            
        default:
            break;
    }
    
    return @"";
}

+ (NSInteger)dayBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSCalendar *calendar = [[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:startDate toDate:endDate options:0];
    //    int months = [comps month];
    NSInteger days = [comps day];
    return days;
}

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format {
    if (!format)
        format = @"yyyy-MM-dd";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format {
    if (!format)
        format = @"yyyy-MM-dd";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}


+ (NSDate *)dateFromString:(NSString *)dateString {
    return [self dateFromStringBySpecifyTime:dateString hour:0 minute:0 second:0];
}

+ (NSDate *)dateFromStringBySpecifyTime:(NSString *)dateString hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    NSArray *arrayDayTime = [dateString componentsSeparatedByString:@" "];
    NSArray *arrayDay = [arrayDayTime[0] componentsSeparatedByString:@"-"];

    NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *tmpDateComponents = [calendar components:flags fromDate:[NSDate date]];
    tmpDateComponents.year = [arrayDay[0] intValue];
    tmpDateComponents.month = [arrayDay[1] intValue];
    tmpDateComponents.day = [arrayDay[2] intValue];
    if ([arrayDayTime count] > 1) {
        NSArray *arrayTime = [arrayDayTime[1] componentsSeparatedByString:@":"];
        tmpDateComponents.hour = [arrayTime[0] intValue];
        tmpDateComponents.minute = [arrayTime[1] intValue];
        tmpDateComponents.second = [arrayTime[2] intValue];
    }
    else {
        tmpDateComponents.hour = hour;
        tmpDateComponents.minute = minute;
        tmpDateComponents.second = second;
    }
    return [calendar dateFromComponents:tmpDateComponents];
}

+ (NSDateComponents *)nowDateComponents {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:flags fromDate:[NSDate date]];
}

+ (NSDateComponents *)dateComponentsFromNow:(NSInteger)days {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:flags fromDate:[[NSDate date] dateByAddingTimeInterval:days * 24 * 60 * 60]];
}


@end
