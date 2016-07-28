//
//  EquipmentData.h
//  CRC
//
//  Created by Jinhui Lee on 12/2/14.
//  Copyright (c) 2014 Jinhui Lee. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EquipmentData : NSObject

+ (EquipmentData*)sharedData;

+ (NSString*)infoOfEquipment:(NSMutableDictionary*)dic;
+ (NSString*)costOfEquipment:(NSMutableDictionary*)dic;

+ (NSUInteger)equipmentCartCount:(NSMutableDictionary*)dic;

+ (NSString*)imagePathOfEquipment:(NSMutableDictionary*)dic;

- (void)initWithData:(NSArray*)data;

- (NSUInteger)count;
- (NSUInteger)cartCount;

- (NSMutableDictionary*)equipmentDataWithIndex:(NSUInteger)index;
- (NSMutableDictionary*)cartDataWithIndex:(NSUInteger)index;

- (NSMutableDictionary*)cartWithSortIndex:(NSUInteger)index;

- (BOOL)addToCartWithIndex:(NSUInteger)index;

- (BOOL)clearCart;
- (BOOL)RemoveFromCart:(NSMutableDictionary*)dic;

- (BOOL)changeCartWithIndex:(NSUInteger)index withCount:(NSUInteger)count;

- (void)resetSort:(BOOL)search;
- (BOOL)searchWithFilter:(NSArray*)filters;
- (BOOL)searchWithString:(NSString*)searchString;

@end
