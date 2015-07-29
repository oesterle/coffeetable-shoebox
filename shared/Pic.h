//
//  Pic.h
//  coffeetable
//
//  Created by Eric Oesterle.
//  Copyright 2015 uiGarage. All rights reserved.
//

// #interview: add pragma mark sections ???

#import <Foundation/Foundation.h>


@interface Pic : NSObject {
	NSMutableDictionary *picDict;

	// these are just needed by older versions of 32-bit ObjC used by iPhone Sim
	UIImage* image;
	NSData* jpegData;
	NSString* caption;
	CGAffineTransform transform;
	NSUInteger picID;
}

+ (NSString *)makeFilePathFromPicID:(NSUInteger)aPicID;
+ (NSString *)makeFileNameFromPicID:(NSUInteger)aPicID;

- (id) initWithPicDict:(NSMutableDictionary *)aPicDict;
- (id) initWithImage:(UIImage *)img andCaption:(NSString *)cap;
- (id) initWithJpegData:(NSData *)inJpegData andCaption:(NSString *)cap;

// These should all be properties for newer versions of iPhone Simulator now that will supports that
/*
- (UIImage *)image;
- (void)setImage:(UIImage *)img;

- (NSData *)jpegData;
- (void)setJpegData:(NSData *)inJpegData;

- (NSString *)caption;
- (void)setCaption:(NSString *)cap;

- (CGAffineTransform)transform;
- (void)setTransform:(CGAffineTransform)aTransform;

- (NSUInteger)picID;
- (void)setPicID:(NSUInteger)aPicID;
*/

- (void) deleteImageFile;


@property (nonatomic, strong) NSMutableDictionary *picDict;

@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) NSData* jpegData;
@property (nonatomic, strong) NSString* caption;
@property CGAffineTransform transform;
@property NSUInteger picID;


@end
