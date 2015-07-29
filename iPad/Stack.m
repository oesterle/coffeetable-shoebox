//
//  Stack.m
//  coffeetable
//
//  Created by Eric Oesterle.
//  Copyright 2015 uiGarage. All rights reserved.
//

#import "Stack.h"
#import "coffeetableAppDelegateiPad.h"
#import "Shoebox.h"
#import "NSMutableArray+ArrayMoving.h"

@implementation Stack

@synthesize stackDict, stackID, caption, thumbImage, thumbJPEGData, backgroundImageName;

#pragma mark -
#pragma mark Creating a Stack

// Create a new, empty Stack
// note that the returned Stack needs to be added to the Shoebox
- (id) init {
	if (self = [super init]){
		self.stackDict = [[NSMutableDictionary alloc] init];
		NSMutableArray *pics = [[NSMutableArray alloc] init];
        [stackDict setObject:pics forKey:@"pics"];
        
        pics = nil;
		
		coffeetableAppDelegateiPad *del = [[UIApplication sharedApplication] delegate];
		Shoebox *shoebox = del.shoebox;
		if (shoebox) {
			self.stackID = [shoebox nextStackID];
		}
		self.backgroundImageName = @"CoffeeTable";
	}
	
	return self;
}

- (id) initWithNewStackID:(NSUInteger)newStackID {
	if (self = [self init]) {
		self.stackID = newStackID;
	}
	return self;
}

// Instantiate an existing Stack
- (id) initWithStackDict:(NSMutableDictionary *)aStackDict{
	if (self = [super init]) {
		self.stackDict = aStackDict;
	}
	return self;
}


#pragma mark -
#pragma mark Deleting a Stack

- (void) empty {
	NSInteger i, ct;
	NSMutableArray *pics = [stackDict objectForKey:@"pics"];
	
	if (pics){
		ct = [pics count];
		for (i = ct - 1; i >= 0; i--) {
			NSMutableDictionary *picDict = [pics objectAtIndex:i];
			// NSUInteger curPicID = [[picDict objectForKey:@"picID"] integerValue];
		
			Pic *pic = [[Pic alloc] initWithPicDict:picDict];
			[pic deleteImageFile];
			
			[pics removeObjectAtIndex:i];
			
            pic = nil;
			// we're done
		}
	}
}


#pragma mark -
#pragma mark Adding/Moving/Deleting Pics

- (void) addPic:(Pic *)aPic {
	[[stackDict objectForKey:@"pics"] addObject:[aPic picDict]];
	
	// we've made a change; stack needs rendering
	self.needsRender = YES;
}

- (void) deletePicID:(NSUInteger)picID {
	NSUInteger i, ct;
	NSMutableArray *pics = [stackDict objectForKey:@"pics"];
	
	if (pics){
		ct = [pics count];
		for (i = 0; i < ct; i++) {
			NSMutableDictionary *picDict = [pics objectAtIndex:i];
			NSUInteger curPicID = [[picDict objectForKey:@"picID"] integerValue];
			if (picID == curPicID) {
				// we've found it; delete it
				Pic *pic = [[Pic alloc] initWithPicDict:picDict];
				[pic deleteImageFile];
				
				[pics removeObjectAtIndex:i];
				
                pic = nil;
				
				// we've made a change; stack needs rendering
				self.needsRender = YES;
				
				// we're done
				break;
			}
		}
	}
}

// here we assume one minor piece of internal info about a Pic: its picID
- (void) bringToFrontPicID:(NSUInteger)picID {
	NSUInteger i, ct;
	NSMutableArray *pics = [stackDict objectForKey:@"pics"];
	
	if (pics){
		ct = [pics count];
		for (i = 0; i < ct; i++) {
			NSMutableDictionary *picDict = [pics objectAtIndex:i];
			NSUInteger curPicID = [[picDict objectForKey:@"picID"] integerValue];
			if (picID == curPicID) {
				// we've found it; move it to last place in array (front of stack)
				
				[pics moveObjectToLastPlace:i];
				
				// we've made a change; stack needs rendering
				self.needsRender = YES;
				
				// we're done
				break;
			}
		}
	}
}


#pragma mark -
#pragma mark Getting Stack Contents (Pics)

- (NSMutableArray *) getPics {
    NSMutableArray *pics = [[NSMutableArray alloc] init];
	
	NSArray *picDicts = [stackDict objectForKey:@"pics"];
	NSUInteger i, ct;
	
	ct = [picDicts count];
	for (i = 0; i < ct; i++) {
		Pic* newPic = [[Pic alloc] initWithPicDict:[picDicts objectAtIndex:i]];
		[pics addObject:newPic];
        
        newPic = nil;
	}
	
	return pics;
}

- (Pic *) getPicWithPicID:(NSUInteger)picID {
	Pic *pic = nil;
	
	NSUInteger i, ct;
	NSMutableArray *pics = [stackDict objectForKey:@"pics"];
	
	if (pics){
		ct = [pics count];
		for (i = 0; i < ct; i++) {
			NSMutableDictionary *picDict = [pics objectAtIndex:i];
			NSUInteger curPicID = [[picDict objectForKey:@"picID"] integerValue];
			if (picID == curPicID) {
				// we've found it; move it to last place in array (front of stack)
                pic = [[Pic alloc] initWithPicDict:picDict];
				
				// we're done
				break;
			}
		}
	}
	
	return pic;
}

#pragma mark -
#pragma mark Finding where a Stack's thumbnail image is stored
+ (NSString *)makeThumbFileNameFromStackID:(NSUInteger)aStackID {
	NSString *thumbFileName = [[NSString stringWithFormat:@"%u",aStackID] stringByAppendingString:@".jpg"];
	
	return thumbFileName;
}

+ (NSString *)makeThumbFilePathFromStackID:(NSUInteger)aStackID {
	NSString *thumbFileName = [Stack makeThumbFileNameFromStackID:aStackID];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *stackThumbsDir = [documentsDirectory stringByAppendingPathComponent:@"stackThumbs"];
	NSString *thumbFilePath = [stackThumbsDir stringByAppendingPathComponent:thumbFileName];
	
	return thumbFilePath;
}

#pragma mark -
#pragma mark Getting/Setting Stack Info

- (UIImage *)thumbImage {
	UIImage *theThumbImage;
	
	NSString *thumbFilePath = [Stack makeThumbFilePathFromStackID:self.stackID];
	
	theThumbImage = [UIImage imageWithContentsOfFile:thumbFilePath];
	
	return theThumbImage;
}


- (void) setThumbImage:(UIImage *)img {
	self.thumbJPEGData = UIImageJPEGRepresentation(img, 1.0f);
}

- (NSData *) thumbJPEGData {
	NSData *data;
	
	NSString *thumbFilePath = [Stack makeThumbFilePathFromStackID:self.stackID];
	
	data = [NSData dataWithContentsOfFile:thumbFilePath];
	
	return data;
}

- (void) setThumbJPEGData:(NSData *)inThumbJPEGData {
	NSString *thumbImageFilePath = [Stack makeThumbFilePathFromStackID:self.stackID];
	[inThumbJPEGData writeToFile:thumbImageFilePath atomically:YES];
	
	self.needsRender = NO;
}


- (BOOL) needsRender {
	NSNumber *stackNeedsRerenderNum = [stackDict objectForKey:@"needsRender"];
	BOOL stackNeedsRerender = YES;
	if (stackNeedsRerenderNum) {
		stackNeedsRerender = [stackNeedsRerenderNum boolValue];
	}
	
	return stackNeedsRerender;
}

- (void) setNeedsRender:(BOOL)doesNeedRender {
	[stackDict setObject:[NSNumber numberWithBool:doesNeedRender] forKey:@"needsRender"];
}

- (NSString *)caption {
	return [stackDict objectForKey:@"caption"];
}

- (void) setCaption:(NSString *)aCaption {
	NSLog(@"caption changed to: %@",aCaption);
	
	[stackDict setObject:aCaption forKey:@"caption"];
}

- (NSUInteger) stackID {
	return [[stackDict objectForKey:@"stackID"] integerValue];
}

- (void) setStackID:(NSUInteger)aStackID {
	[stackDict setObject:[NSNumber numberWithInteger:aStackID] forKey:@"stackID"];
}

- (NSString *) backgroundImageName {
	NSString *bgName = [stackDict objectForKey:@"backgroundImageName"];
	if (!bgName) {
		return @"CoffeeTable";
	}
		
	return bgName;
}

- (void) setBackgroundImageName:(NSString *)aBackgroundImageName {
	[stackDict setObject:aBackgroundImageName forKey:@"backgroundImageName"];
	
	// we've made a change; stack needs rendering
	self.needsRender = YES;
}



@end
