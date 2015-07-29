//
//  Shoebox.h
//  coffeetable
//
//  Created by Eric Oesterle.
//  Copyright 2015 uiGarage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTSession.h"
#import "Stack.h"
#import "Pic.h"


@interface Shoebox : NSObject {
	NSMutableDictionary *shoeboxDict;
	BOOL loaded;

	// need this for older versions of iOS simulator, at the moment
	NSUInteger currentStackID;
}

@property (nonatomic, strong) NSMutableDictionary *shoeboxDict;
@property BOOL loaded;

#pragma mark -
#pragma mark Opening the (singleton) Shoebox
#pragma mark - (id) init; // (overridden)

#pragma mark -
#pragma mark Saving/Restoring State; Unique Sequence Numbers

- (void) save;
- (NSUInteger) nextPicID;
- (NSUInteger) nextStackID;
- (NSUInteger) maxStackID;

@property NSUInteger currentStackID;

#pragma mark -
#pragma mark CONVENIENCE METHODS
// convenience methods
// these assume some knowledge of Stack and Pic internals
// they all save their results to the file system


#pragma mark Shoebox Contents (Stacks)

- (NSMutableArray *) stackIDs;
- (NSMutableDictionary *) getStackDictWithStackID:(NSUInteger)stackID;
- (NSUInteger) makeNewStack;
- (NSUInteger) deleteStackID:(NSUInteger)deletingStackID;
- (NSUInteger) findNeighborToStackID:(NSUInteger)aStackID;
- (void) addStack:(Stack *)aStack;
- (BOOL) needRenderForStackID:(NSUInteger)stackID;
- (void) setThumbImage:(UIImage *)thumbImage forStackID:(NSUInteger)stackID;
- (NSString *) backgroundImageNameForStackID:(NSUInteger)stackID;

#pragma mark Stack Metadata

- (NSString *) captionForStackID:(NSUInteger)stackID;
- (void) setCaption:(NSString *)newCaption forStackID:(NSUInteger)stackID;

#pragma mark Stack Contents (Pics)

- (NSMutableArray *) getPicsFromStackID:(NSUInteger)stackID;
- (NSUInteger) countPicsInStackID:(NSUInteger)stackID;

#pragma mark Adding/Removing Pics

- (void) addPic:(Pic *)pic toStackID:(NSUInteger)stackID;
- (void) deletePicID:(NSUInteger)picID fromStackID:(NSUInteger)stackID;

#pragma mark Updating Pics

- (void) bringToFrontPicID:(NSUInteger)picID inStackID:(NSUInteger)stackID;
- (void) saveTransform:(CGAffineTransform)transform forPicID:(NSUInteger)picID inStackID:(NSUInteger)stackID;
- (void) setBackgroundImageName:(NSString *)bgName forStackID:(NSUInteger)stackID;

@end
