//
//  Pic.m
//  coffeetable
//
//  Created by Eric Oesterle.
//  Copyright 2015 uiGarage. All rights reserved.
//

// This is a thin wrapper around picDict, an NSMutableDictionary (which is not easily subclassed)



#import "Pic.h"
#import "Shoebox.h"
#import "coffeetableAppDelegateiPad.h"

@implementation Pic


#pragma mark -
#pragma mark Pic Data Structure
@synthesize picDict;

#pragma mark -
#pragma mark Pic Properties

@synthesize image, jpegData, caption, transform, picID;

#pragma mark -
#pragma mark Finding where a Pic's Image is Stored

+ (NSString *)makeFileNameFromPicID:(NSUInteger)aPicID {
	NSString *picFileName = [[NSString stringWithFormat:@"%u",aPicID] stringByAppendingString:@".jpg"];
	
	return picFileName;
}

+ (NSString *)makeFilePathFromPicID:(NSUInteger)aPicID {
	NSString *picFileName = [Pic makeFileNameFromPicID:aPicID];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *pixDir = [documentsDirectory stringByAppendingPathComponent:@"pix"];
	NSString *imgFilePath = [pixDir stringByAppendingPathComponent:picFileName];
	
	return imgFilePath;
}


#pragma mark -
#pragma mark Pic Image

- (UIImage *)image {
	UIImage *theImage;
	
	NSString *imgFilePath = [Pic makeFilePathFromPicID:self.picID];
	
	theImage = [UIImage imageWithContentsOfFile:imgFilePath];
	
	NSLog(@"image read in of width %f", theImage.size.width);
	
	return theImage;
}

- (void) setImage:(UIImage *)img {
	// do we really want a UIImage*? or do we want a presaved temp file?
	// we want to somehow, eventually, avoid recompression!!
	self.jpegData = UIImageJPEGRepresentation(img, 1.0f);
}

- (NSData *) jpegData {
	NSData *data;
	
	NSString *imgFilePath = [Pic makeFilePathFromPicID:self.picID];
	
	data = [NSData dataWithContentsOfFile:imgFilePath];
	
	return data;
}

- (void) setJpegData:(NSData *)inJpegData {
	coffeetableAppDelegateiPad *del = [[UIApplication sharedApplication] delegate];
	Shoebox *shoebox = del.shoebox;
	
	NSUInteger newPicID = [shoebox nextPicID];
	NSString *imgFilePath = [Pic makeFilePathFromPicID:newPicID];
	NSString *imgFileName = [Pic makeFileNameFromPicID:newPicID];
	
	[inJpegData writeToFile:imgFilePath atomically:YES];
	
	self.picID = newPicID;
	
	[picDict setObject:imgFileName forKey:@"picFileName"];	
}

- (void) deleteImageFile {	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSUInteger delPicID = [self picID];
	NSString *imgFilePath = [Pic makeFilePathFromPicID:delPicID];
	
	[fm removeItemAtPath:imgFilePath error:NULL];
}


#pragma mark -
#pragma mark Pic Caption

- (NSString *) caption {
	return [picDict objectForKey:@"caption"];
}

- (void) setCaption:(NSString *)cap {
	[picDict setObject:cap forKey:@"caption"];
}


#pragma mark -
#pragma mark Pic Size/Orientation on the Stack

- (CGAffineTransform) transform {
	NSDictionary *transformDict = [picDict objectForKey:@"transform"];
	CGAffineTransform myTransform;
	
	if (transformDict) {
		CGFloat a = [[transformDict objectForKey:@"a"] floatValue];
		CGFloat b = [[transformDict objectForKey:@"b"] floatValue];
		CGFloat c = [[transformDict objectForKey:@"c"] floatValue];
		CGFloat d = [[transformDict objectForKey:@"d"] floatValue];
		CGFloat tx = [[transformDict objectForKey:@"tx"] floatValue];
		CGFloat ty = [[transformDict objectForKey:@"ty"] floatValue];
		
		myTransform = CGAffineTransformMake(a, b, c, d, tx, ty);
	} else {
		myTransform = CGAffineTransformIdentity;
	}
	
	return myTransform;
}

- (void) setTransform:(CGAffineTransform)aTransform {
	NSMutableDictionary *transformDict = [[NSMutableDictionary alloc] init];
	
	[transformDict setObject:[NSNumber numberWithFloat:aTransform.a] forKey:@"a"];
	[transformDict setObject:[NSNumber numberWithFloat:aTransform.b] forKey:@"b"];
	[transformDict setObject:[NSNumber numberWithFloat:aTransform.c] forKey:@"c"];
	[transformDict setObject:[NSNumber numberWithFloat:aTransform.d] forKey:@"d"];
	[transformDict setObject:[NSNumber numberWithFloat:aTransform.tx] forKey:@"tx"];
	[transformDict setObject:[NSNumber numberWithFloat:aTransform.ty] forKey:@"ty"];
	
	[picDict setObject:transformDict forKey:@"transform"];
	
    transformDict = nil;
}


#pragma mark -
#pragma mark Pic's picID

- (void) setPicID:(NSUInteger)aPicID{
	[picDict setObject:[NSNumber numberWithInteger:aPicID] forKey:@"picID"];
}

- (NSUInteger) picID {
	return [[picDict objectForKey:@"picID"] integerValue];
}



#pragma mark -
#pragma mark Creating a Pic

- (id) init {
	self.picDict = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (id) initWithJpegData:(NSData *)inJpegData andCaption:(NSString *)cap{
	if (self = [self init]){
		self.caption = cap;
		self.jpegData = inJpegData;
		self.transform = CGAffineTransformIdentity;
	}
	return self;
}

- (id) initWithImage:(UIImage *)img andCaption:(NSString *)cap {
	if (self = [self init]){
		self.image = img;
		self.caption = cap;
	}
	return self;
}

- (id) initWithPicDict:(NSMutableDictionary *)aPicDict {
	if (self = [super init]) {
		self.picDict = aPicDict;
	}
	return self;
}


#pragma mark -
#pragma mark Cleanup

// ARC: dealloc no longer needed

@end
