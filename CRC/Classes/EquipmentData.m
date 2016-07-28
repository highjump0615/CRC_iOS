//
//  EquipmentData.m
//  CRC
//
//  Created by Jinhui Lee on 12/2/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import "EquipmentData.h"

static EquipmentData* g_sharedData = nil;

@interface EquipmentData ()

@property (strong, nonatomic)   NSMutableArray* equipmentArray;
@property (strong, nonatomic)   NSMutableArray* sortedArray;
@property (strong, nonatomic)   NSMutableArray* cartArray;

@end

@implementation EquipmentData

#pragma mark - static method

+ (EquipmentData*)sharedData
{
    if(g_sharedData == nil)
    {
        g_sharedData = [[EquipmentData alloc] init];
        
    }
    return g_sharedData;
}

+ (NSString*)infoOfEquipment:(NSMutableDictionary*)dic
{
    if (dic) {
        return [dic objectForKey:kEquipmentInfomationKey];
    }
    return nil;
}

+ (NSString*)costOfEquipment:(NSMutableDictionary*)dic
{
    if (dic) {
        return [dic objectForKey:kEquipmentCostKey];
    }
    return nil;
}

+ (NSUInteger)equipmentCartCount:(NSMutableDictionary*)dic
{
    if (dic) {
        return [[dic objectForKey:kEquipmentCountKey] integerValue];
    }
    return 1;
}

+ (NSString*)imagePathOfEquipment:(NSMutableDictionary*)dic
{
    if (dic) {
        return [dic objectForKey:kEquipmentImageURLKey];
    }
    return nil;
}

#pragma mark - initialize..

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.equipmentArray = nil;
        self.cartArray      = nil;

        self.sortedArray    = nil;
    }
    return self;
}

- (void)loadCart
{
    NSArray* cartArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kEquipmentCartKey];
    
    if(!self.cartArray)
        self.cartArray = [[NSMutableArray alloc] init];
    else
        [self.cartArray removeAllObjects];
 
    for(NSMutableDictionary* dic in cartArray)
    {
        for(NSMutableDictionary* equip in self.equipmentArray)
        {
            if([self isEqualWithFirst:dic withSecond:equip])
                [self.cartArray addObject:[[NSMutableDictionary alloc] initWithDictionary:dic]];
        }
    }
    
    [self updateCarts];
}

- (void)initWithData:(NSArray*)data
{
    [self reset];

    NSArray* keys = @[kEquipmentIDKey ,kEquipmentInfomationKey, kEquipmentCostKey, kEquipmentImageURLKey, kEquipmentKindKey, kEquipmentCountKey];
    NSInteger index = 0, i;

    for(NSArray* equip in data)
    {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        
        for(NSString* key in keys)
            [dic setObject:@"" forKey:key];

        [dic setObject:[NSString stringWithFormat:@"%04ld", (long)index] forKey:kEquipmentIDKey];

        index++;
        i=1;
        
        for(NSString* obj in equip)
            [dic setObject:obj forKey:keys[i++]];
        
        [self.equipmentArray addObject:dic];
    }
    
    self.sortedArray = [[NSMutableArray alloc] initWithArray:self.equipmentArray];
    
    [self loadCart];
}

- (void)reset
{
    if(self.equipmentArray)
    {
        [self.equipmentArray    removeAllObjects];
        [self.cartArray         removeAllObjects];
    }
    else
    {
        self.equipmentArray = [[NSMutableArray alloc] init];
        self.cartArray      = [[NSMutableArray alloc] init];
    }
    
    self.sortedArray = nil;
}

#pragma mark - uitlity

- (BOOL)isEqualWithFirst:(NSMutableDictionary*)first withSecond:(NSMutableDictionary*)second
{
    NSArray* keys = @[kEquipmentIDKey ,kEquipmentInfomationKey, kEquipmentCostKey, kEquipmentImageURLKey, kEquipmentKindKey];
    
    for (NSString* key in keys)
    {
        if(![[first objectForKey:key] isEqualToString:[second objectForKey:key]])
            return NO;
    }
    return YES;
}

#pragma mark - property

- (NSUInteger)count
{
    return self.sortedArray.count;
}

- (NSUInteger)cartCount;
{
    return self.cartArray.count;
}

- (NSMutableDictionary*)equipmentDataWithIndex:(NSUInteger)index
{
    if(self.sortedArray.count == 0 || index > self.sortedArray.count-1)
        return nil;
    
    NSMutableDictionary* dic = [self.sortedArray objectAtIndex:index];
    
    return dic;
}

- (NSMutableDictionary*)cartDataWithIndex:(NSUInteger)index
{
    if(self.cartArray.count == 0 || index > self.cartArray.count-1)
        return nil;
    
    NSMutableDictionary* dic = [self.cartArray objectAtIndex:index];
    
    return dic;
}

- (NSMutableDictionary*)cartWithSortIndex:(NSUInteger)index
{
    if(self.sortedArray.count == 0 || index > self.sortedArray.count-1)
        return nil;
    
    NSMutableDictionary* dic = self.sortedArray[index];
    
    for(NSMutableDictionary* cart in self.cartArray)
    {
        if([self isEqualWithFirst:cart withSecond:dic])
            return cart;
    }
    
    return nil;
}

- (NSMutableDictionary*)cartWithDic:(NSMutableDictionary*)dic
{
    for(NSMutableDictionary* cart in self.cartArray)
    {
        if([self isEqualWithFirst:cart withSecond:dic])
            return cart;
    }
    
    return nil;
}

- (BOOL)addToCartWithIndex:(NSUInteger)index
{
    NSMutableDictionary* dic = self.sortedArray[index];
    
    if([self.cartArray indexOfObject:dic] == NSNotFound)
    {
        [dic setValue:[NSNumber numberWithInteger:1] forKey:kEquipmentCountKey];
        
        [self.cartArray addObject:dic];
        
        [self updateCarts];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)clearCart
{
    for(NSMutableDictionary* dic in self.cartArray)
    {
        [dic setValue:[NSNumber numberWithInteger:0] forKey:kEquipmentCountKey];
    }

    [self.cartArray removeAllObjects];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEquipmentCartKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:kEquipmentUpdateCartNotification object:[NSNumber numberWithInteger:0]];

    return YES;
}

- (BOOL)RemoveFromCart:(NSMutableDictionary*)dic
{
    if(dic == nil)
        return NO;
    
    dic = [self cartWithDic:dic];
    
    if(dic == nil)
        return NO;
    
    [dic setValue:[NSNumber numberWithInteger:0] forKey:kEquipmentCountKey];
    
    [self.cartArray removeObject:dic];
    
    [self updateCarts];
    
    return YES;
}

- (BOOL)changeCartWithIndex:(NSUInteger)index withCount:(NSUInteger)count
{
    if(index > self.cartArray.count-1 || self.cartArray.count == 0)
        return NO;

    NSMutableDictionary* dic = self.cartArray[index];

    [dic setValue:[NSNumber numberWithInteger:count] forKey:kEquipmentCountKey];
    
    if(count == 0)
    {
        [self.cartArray removeObject:dic];
    }

    [self updateCarts];
    
    return YES;
}

- (void)updateCarts
{
    NSUInteger totalCount = 0;
    for(NSMutableDictionary* dic in self.cartArray)
    {
        totalCount += [[dic objectForKey:kEquipmentCountKey] integerValue];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.cartArray forKey:kEquipmentCartKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kEquipmentUpdateCartNotification object:[NSNumber numberWithInteger:totalCount]];
}

#pragma mark - search

- (void)resetSort:(BOOL)search
{
    if(search)
        self.sortedArray = [[NSMutableArray alloc] init];
    else
        self.sortedArray = [[NSMutableArray alloc] initWithArray:self.equipmentArray];
}

- (BOOL)searchWithFilter:(NSArray*)filters
{
    if(filters.count == 0)
    {
        self.sortedArray = [[NSMutableArray alloc] initWithArray:self.equipmentArray];
        return YES;
    }
    else
    {
        self.sortedArray = [[NSMutableArray alloc] init];
        
        BOOL        matchKind   = YES;
        NSString    *kindString = nil;
        for(NSMutableDictionary* dic in self.equipmentArray)
        {
            matchKind   = YES;
            kindString  = [[dic objectForKey:kEquipmentKindKey] lowercaseString];

            for(NSString* strKey in filters)
            {
                if(![kindString containsString:strKey])
                {
                    matchKind = NO;
                    break;
                }
            }
            
            if(matchKind)
                [self.sortedArray addObject:dic];
        }
    }
    return YES;
}


- (BOOL)searchWithString:(NSString*)searchString
{
    if(searchString.length == 0)
    {
        self.sortedArray = [[NSMutableArray alloc] init];
    }
    else
    {
        NSMutableArray  * searchArray   = [[NSMutableArray alloc] init];
        NSArray         * array         = [[searchString lowercaseString] componentsSeparatedByString:@" "];
        
        for(NSString* strKey in array)
        {
            NSString* str = [strKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if(strKey.length > 0)
                [searchArray addObject:str];
        }
        
        if(searchArray.count == 0)
            return NO;
        
        self.sortedArray = nil;
        self.sortedArray = [[NSMutableArray alloc] init];

        BOOL        matchInfo   = YES;
        BOOL        matchKind   = YES;
        NSString    *infoString = nil;
        NSString    *kindString = nil;
        for(NSMutableDictionary* dic in self.equipmentArray)
        {
            matchInfo   = YES;
            infoString  = [[dic objectForKey:kEquipmentInfomationKey] lowercaseString];
            for(NSString* strKey in searchArray)
            {
                if(![infoString containsString:strKey])
                {
                    matchInfo = NO;
                    break;
                }
            }

            matchKind   = YES;
            kindString  = [[dic objectForKey:kEquipmentKindKey] lowercaseString];
            for(NSString* strKey in searchArray)
            {
                if(![kindString containsString:strKey])
                {
                    matchKind = NO;
                    break;
                }
            }

            if(matchInfo || matchKind)
                [self.sortedArray addObject:dic];
        }
    }
    
    return YES;
}


@end
