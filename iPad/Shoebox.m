//
//  Shoebox.m
//  coffeetable
//
//  Created by Eric Oesterle
//  Copyright 2015 uiGarage. All rights reserved.
//

/**
 *
 *  The Shoebox object manages Stacks of Pics.
 *
 *  The Shoebox is serialized to a plist, and similarly, on opening the app,
 *  reconstituted to an NSMutableDictionary.
 *
 **/

#import "Shoebox.h"

@implementation Shoebox

@synthesize shoeboxDict, loaded, currentStackID;

#pragma mark -
#pragma mark Opening the Shoebox

- (id) init {
	if (self = [super init]){
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *shoeboxFile = [documentsDirectory stringByAppendingPathComponent:@"shoebox.bplist"];

		// load shoebox if file exists
		if ([[NSFileManager defaultManager] fileExistsAtPath:shoeboxFile]){
			shoeboxDict = [NSKeyedUnarchiver unarchiveObjectWithFile:shoeboxFile];
		} else {
			shoeboxDict = [[NSMutableDictionary alloc] init];

			// must create stacks dictionary
			NSMutableDictionary *stacksDict = [[NSMutableDictionary alloc] init];
			[shoeboxDict setObject:stacksDict forKey:@"stacks"];

      stacksDict = nil;

			// should add at least one, new blank stack (later), and make it the current stack
			self.currentStackID = 0;
		}

		[self save];

		self.loaded = YES;
	}
	return self;
}


#pragma mark -
#pragma mark Saving/Restoring State; Unique Sequence Numbers

- (void) save {
	NSFileManager *fm = [NSFileManager defaultManager];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];

	// Ensure that we have directories for both Pictures and Stack Thumbnails
	NSString *pixDir = [documentsDirectory stringByAppendingPathComponent:@"pix"];
	if (![fm fileExistsAtPath:pixDir]){
		[fm createDirectoryAtPath:pixDir withIntermediateDirectories:NO attributes:nil error:NULL];
	}

	NSString *stackThumbsDir = [documentsDirectory stringByAppendingPathComponent:@"stackThumbs"];
	if (![fm fileExistsAtPath:stackThumbsDir]){
		[fm createDirectoryAtPath:stackThumbsDir withIntermediateDirectories:NO attributes:nil error:NULL];
	}

	// NSLog(@"shoebox: %@",shoeboxDict);

	NSString *shoeboxFile = [documentsDirectory stringByAppendingPathComponent:@"shoebox.bplist"];

	BOOL didSaveShoebox = [NSKeyedArchiver archiveRootObject:shoeboxDict toFile:shoeboxFile];

	NSLog(@"Shoebox didSaveShoebox: %i",didSaveShoebox);
}


- (NSUInteger) nextPicID{
	NSNumber *nextPicIDNumber = [shoeboxDict objectForKey:@"nextPicIDNumber"];
	if (nextPicIDNumber == nil) {
		nextPicIDNumber = [NSNumber numberWithInteger:0];
	}

	NSUInteger nextInteger = [nextPicIDNumber integerValue];

	NSUInteger nextNextInteger = nextInteger + 1;

	[shoeboxDict setObject:[NSNumber numberWithInteger:nextNextInteger] forKey:@"nextPicIDNumber"];

	[self save];

	return nextInteger;
}

// gets the next stack ID, and increments it to generate a new one
- (NSUInteger) nextStackID {
	NSNumber *nextStackIDNumber = [shoeboxDict objectForKey:@"nextStackIDNumber"];
	if (nextStackIDNumber == nil) {
		nextStackIDNumber = [NSNumber numberWithInteger:0];
	}

	NSUInteger nextID = [nextStackIDNumber integerValue];

	NSUInteger nextNextNum = nextID + 1;

	[shoeboxDict setObject:[NSNumber numberWithInteger:nextNextNum] forKey:@"nextStackIDNumber"];

	NSLog(@"nextStackID called: %u",nextID);

	[self save];

	return nextID;
}

// gets the next stack ID, without incrementing it
- (NSUInteger) maxStackID {
	NSNumber *nextStackIDNumber = [shoeboxDict objectForKey:@"nextStackIDNumber"];
	if (nextStackIDNumber == nil) {
		nextStackIDNumber = [NSNumber numberWithInteger:0];
	}

	NSUInteger nextID = [nextStackIDNumber integerValue];

	return nextID;
}

- (NSUInteger) currentStackID {
	NSUInteger theID = [[shoeboxDict objectForKey:@"currentStackID"] integerValue];

	// ensure stack exists
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:theID];

	if (stackDict == nil) {
		// something bad happened; we can't find the current stack
		NSLog(@"Couldn't find CURRENT stack with ID: %u",theID);

		// let's recover, by finding a neighbor
		theID = [self findNeighborToStackID:theID];
		self.currentStackID = theID;
	}

	return theID;
}

- (void) setCurrentStackID:(NSUInteger)aStackID{
	[shoeboxDict setObject:[NSNumber numberWithInteger:aStackID] forKey:@"currentStackID"];
	[self save];
}


#pragma mark -
#pragma mark CONVENIENCE METHODS

#pragma mark Shoebox Contents (Stacks)
- (NSMutableArray *) stackIDs {
	// returns an array of stackIDs, sorted numerically (which should be chronological)
	// or nil, if there are no stacks yet

	NSMutableArray *keys;

	NSDictionary *stacks = [shoeboxDict objectForKey:@"stacks"];
	if (stacks) {
		keys = [NSMutableArray arrayWithArray:[[stacks allKeys] sortedArrayUsingSelector:@selector(compare:)]];
	} else {
		keys = nil;
	}

	return keys;
}

- (NSMutableDictionary *) getStackDictWithStackID:(NSUInteger)stackID {
	NSDictionary *stacks = [shoeboxDict objectForKey:@"stacks"];
	NSMutableDictionary *aStackDict;
	if (stacks) {
		aStackDict = [stacks objectForKey:[NSNumber numberWithInteger:stackID]];
	} else {
		aStackDict = nil;
	}

	return aStackDict;
}

- (NSUInteger) makeNewStack {
	Stack *newStack = [[Stack alloc] init];

	[self addStack:newStack];
	NSUInteger newStackID = newStack.stackID;

	newStack = nil;

	return newStackID;
}

// deletes the specified stack
// returns a neighboring stack id, in case the current stack is deleted
// creates a new stack if the last stack is deleted
//
// Caller should unload any loaded stack-owned resources beforehand
- (NSUInteger) deleteStackID:(NSUInteger)deletingStackID {
	NSInteger neighborStackID;

	NSMutableDictionary* deletingStackDict = [self getStackDictWithStackID:deletingStackID];
	if (deletingStackDict){
		Stack* deletingStack = [[Stack alloc] initWithStackDict:deletingStackDict];
		[deletingStack empty];

    deletingStack = nil;
	}

	NSMutableDictionary *stacks = [shoeboxDict objectForKey:@"stacks"];
	[stacks removeObjectForKey:[NSNumber numberWithInteger:deletingStackID]];

	[self save];

	neighborStackID = [self findNeighborToStackID:deletingStackID];

	return neighborStackID;
}

- (NSUInteger)findNeighborToStackID:(NSUInteger)aStackID{
	NSInteger neighborStackID = -1;

	NSMutableDictionary *stacks = [shoeboxDict objectForKey:@"stacks"];
	NSUInteger stackCt = [stacks count];

	if (stackCt < 1) {
		// no stacks exist for some reason;
		// create a new blank one

		neighborStackID = [self makeNewStack];
	} else {
		// there's at least one other existing stack
		// let's find a neighbor
		NSMutableArray* stackIDs = [self stackIDs];
		neighborStackID = -1;
		NSNumber* testStackIDNum;

		for (testStackIDNum in stackIDs) {
			NSUInteger testStackID = [testStackIDNum integerValue];
			if (aStackID > testStackID) {
				// remember this preceding stack
				neighborStackID = testStackID;
			} else {
				// we've reached a newer stack
				if (neighborStackID > -1) {
					// a preceding stack exists, stop here
					break;
				} else {
					// no preceding stack exists; use the newer stack
					neighborStackID = testStackID;
					break;
				}
			}
		}
	}

	return neighborStackID;
}

- (void) addStack:(Stack *)aStack {
	NSMutableDictionary *stacks = [shoeboxDict objectForKey:@"stacks"];
	if (stacks){
		NSMutableDictionary *theStackDict = [aStack stackDict];
		[stacks setObject:theStackDict forKey:[theStackDict objectForKey:@"stackID"]];
	} else {
		NSLog(@"No stacks dictionary found!");
	}

	[self save];
}

- (BOOL) needRenderForStackID:(NSUInteger)stackID{
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	Stack *stack = [[Stack alloc] initWithStackDict:stackDict];
	BOOL doesNeedRender = stack.needsRender;

  stack = nil;

	return doesNeedRender;
}

- (void) setThumbImage:(UIImage *)thumbImage forStackID:(NSUInteger)stackID {
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	Stack* stack = [[Stack alloc] initWithStackDict:stackDict];
	stack.thumbImage = thumbImage;

  stack = nil;
}

- (NSString *) backgroundImageNameForStackID:(NSUInteger)stackID {
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	Stack* stack = [[Stack alloc] initWithStackDict:stackDict];
	NSString* bgName = stack.backgroundImageName;

  stack = nil;

	return bgName;
}

#pragma mark Stack Metadata

- (NSString *) captionForStackID:(NSUInteger)stackID {
	NSString *caption;

	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	if (stackDict) {
		Stack *stack = [[Stack alloc] initWithStackDict:stackDict];

		caption = stack.caption;

    stack = nil;
	} else {
		caption = nil;
	}

	return caption;
}

- (void) setCaption:(NSString *)newCaption forStackID:(NSUInteger)stackID {
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	if (stackDict) {
		Stack *stack = [[Stack alloc] initWithStackDict:stackDict];
		stack.caption = newCaption;

		[self save];

    stack = nil;
	} else {
		NSLog(@"Shoebox setCaption didn't find stack id %u",stackID);
	}
}

#pragma mark Stack Contents (Pics)

- (NSMutableArray *) getPicsFromStackID:(NSUInteger)stackID {
	NSMutableArray *pics = nil;
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	if (stackDict) {
		Stack *stack = [[Stack alloc] initWithStackDict:stackDict];
		pics = [stack getPics];

    stack = nil;
	}

	return pics;
}

- (NSUInteger) countPicsInStackID:(NSUInteger)stackID {
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	NSUInteger theCount = 0;
	if (stackDict){
		theCount = [[stackDict objectForKey:@"pics"] count];
	}
	return theCount;
}

#pragma mark Adding/Removing Pics

- (void) addPic:(Pic *)pic toStackID:(NSUInteger)stackID {
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	if (stackDict) {
		Stack *stack = [[Stack alloc] initWithStackDict:stackDict];

		[stack addPic:pic];

		[self save];

    stack = nil;
	} else {
		NSLog(@"Shoebox addPic didn't find stack id %u",stackID);
	}
}

- (void) deletePicID:(NSUInteger)picID fromStackID:(NSUInteger)stackID {
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	if (stackDict) {
		Stack *stack = [[Stack alloc] initWithStackDict:stackDict];

		[stack deletePicID:picID];
		stack = nil;

		[self save];
	} else {
		NSLog(@"Shoebox deletePicID didn't find stack id %u",stackID);
	}

}

#pragma mark Updating Pics

- (void) bringToFrontPicID:(NSUInteger)picID inStackID:(NSUInteger)stackID {
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	if (stackDict){
		Stack *stack = [[Stack alloc] initWithStackDict:stackDict];
		[stack bringToFrontPicID:picID];
		[self save];

    stack = nil;
	}
}

// OK, this also assumes minor knowledge of Pic
- (void) saveTransform:(CGAffineTransform)transform forPicID:(NSUInteger)picID inStackID:(NSUInteger)stackID {
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	if (stackDict){
		Stack *stack = [[Stack alloc] initWithStackDict:stackDict];

		Pic *pic = [stack getPicWithPicID:picID];
		pic.transform = transform;

		[self save];

		// we might not have to do as much here, if we add a similar convenience method in
		// the stack:
		//    [stack saveTransform:(CGAffineTransform)transform forPicID:(NSUInteger)picID];
		// we've made a change that the stack doesn't know about; stack needs rendering
		stack.needsRender = YES;

    stack = nil;
	}
}

- (void) setBackgroundImageName:(NSString *)bgName forStackID:(NSUInteger)stackID {
	NSMutableDictionary *stackDict = [self getStackDictWithStackID:stackID];
	Stack* stack = [[Stack alloc] initWithStackDict:stackDict];
	stack.backgroundImageName = bgName;

	[self save];

  stack = nil;
}



@end
