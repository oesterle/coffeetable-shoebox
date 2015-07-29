//
//  Stack.h
//  coffeetable
//
//  Created by Eric Oesterle.
//  Copyright 2015 uiGarage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pic.h"

@interface Stack : NSObject {
	NSMutableDictionary *stackDict;

	// ivars only needed by older versions of 32-bit ObjC2 used in iPhone simulator
	NSUInteger stackID;
	NSString* caption;
	UIImage* thumbImage;
	NSData* thumbJPEGData;
	BOOL needsRender;
	NSString* backgroundImageName;
}

#pragma mark -
#pragma mark Finding where a Stack's thumbnail image is stored

+ (NSString *)makeThumbFileNameFromStackID:(NSUInteger)aStackID;
+ (NSString *)makeThumbFilePathFromStackID:(NSUInteger)aStackID;

#pragma mark -
#pragma mark Creating a Stack

// assumes everything is started up, and shared shoebox is available;
// *** doesn't yet work on startup; use initWithNewStackID instead!!
// - (id) init;

- (id) initWithNewStackID:(NSUInteger)newStackID;
- (id) initWithStackDict:(NSMutableDictionary *)aStackDict;
#pragma mark - init; //(overridden)

#pragma mark -
#pragma mark Deleting a Stack's contents

- (void) empty;

#pragma mark -
#pragma mark Adding/Moving/Deleting Pics

- (void) addPic:(Pic *)aPic;
- (void) deletePicID:(NSUInteger)picID;
- (void) bringToFrontPicID:(NSUInteger)picID;

#pragma mark -
#pragma mark Getting Stack Contents (Pics)

- (NSMutableArray *) getPics;
- (Pic *) getPicWithPicID:(NSUInteger)picID;

#pragma mark -
#pragma mark Stack Data Structure

@property (nonatomic, retain) NSMutableDictionary *stackDict;

#pragma mark -
#pragma mark Getting/Setting Stack Info

@property (nonatomic, strong) UIImage* thumbImage;
@property (nonatomic, strong) NSData* thumbJPEGData;
@property BOOL needsRender;
@property NSUInteger stackID;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *backgroundImageName;

@end
