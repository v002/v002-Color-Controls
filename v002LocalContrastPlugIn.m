//
//  v002VibrancePlugIn.m
//  v002 Color Correct
//
//  Created by vade on 5/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "v002LocalContrastPlugIn.h"

#define	kQCPlugIn_Name				@"v002 Local Contrast"
#define	kQCPlugIn_Description		@"Local Contrast."

static void _TextureReleaseCallback(CGLContextObj cgl_ctx, GLuint name, void* info)
{
	glDeleteTextures(1, &name);
}

@implementation v002LocalContrastPlugIn

@dynamic inputImage;
@dynamic inputBlurredImage;
@dynamic outputImage;
@dynamic inputVibrance;
@dynamic inputSaturation;


+ (NSDictionary*) attributes
{	
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey,
            [kQCPlugIn_Description stringByAppendingString:kv002DescriptionAddOnText], QCPlugInAttributeDescriptionKey,
            kQCPlugIn_Category, QCPlugInAttributeCategoriesKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	if([key isEqualToString:@"inputImage"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey,nil];
	}
	
	if([key isEqualToString:@"inputBlurredImage"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Blurred Image", QCPortAttributeNameKey,nil];
	}
	
	if([key isEqualToString:@"outputImage"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey,nil];
	}
	
	if([key isEqualToString:@"inputVibrance"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Vibrance", QCPortAttributeNameKey,
				//[NSNumber numberWithFloat:0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				nil];
	}
	
	if([key isEqualToString:@"inputSaturation"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Saturation", QCPortAttributeNameKey,
				//[NSNumber numberWithFloat:0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				nil];
	}
	
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
	return [NSArray arrayWithObjects:@"inputImage", @"inputVibrance", nil];
}

+ (QCPlugInExecutionMode) executionMode
{
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode
{
	return kQCPlugInTimeModeNone;
}

- (id) init
{
	if(self = [super init])
	{
		self.pluginShaderName = @"v002.LocalContrast";
	}
	
	return self;
}

- (void) finalize
{	
	[super finalize];
}

- (void) dealloc
{	
	[super dealloc];
}

@end

@implementation v002LocalContrastPlugIn (Execution)

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
    id<QCPlugInInputImageSource> image = self.inputImage;
    id<QCPlugInInputImageSource> bimage = self.inputBlurredImage;

    
	CGColorSpaceRef cspace = ([image shouldColorMatch]) ? [context colorSpace] : [image imageColorSpace];
	CGColorSpaceRef bcspace = ([bimage shouldColorMatch]) ? [context colorSpace] : [bimage imageColorSpace];
	
	if([image lockTextureRepresentationWithColorSpace:cspace forBounds:[image imageBounds]]
	    && [bimage lockTextureRepresentationWithColorSpace:bcspace forBounds:[bimage imageBounds]])
	{	
		[image bindTextureRepresentationToCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0 normalizeCoordinates:YES];
		[bimage bindTextureRepresentationToCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE1 normalizeCoordinates:YES];
		
		GLuint finalOutput = [self renderToFBO:cgl_ctx image:self.inputImage blurredImage:self.inputBlurredImage vibrance:self.inputVibrance saturation:self.inputSaturation];
		
#if __BIG_ENDIAN__
#define v002QCPluginPixelFormat QCPlugInPixelFormatARGB8
#else
#define v002QCPluginPixelFormat QCPlugInPixelFormatBGRA8			
#endif
        // we have to use a 4 channel output format, I8 does not support alpha at fucking all, so if we want text with alpha, we need to use this and waste space. Ugh.
        id provider = [context outputImageProviderFromTextureWithPixelFormat:v002QCPluginPixelFormat pixelsWide:[image imageBounds].size.width pixelsHigh:[image imageBounds].size.height name:finalOutput flipped:NO releaseCallback:_TextureReleaseCallback releaseContext:NULL colorSpace:[context colorSpace] shouldColorMatch:[image shouldColorMatch]];
		
		if(provider == nil)
			return NO;
		
		self.outputImage = provider;

		[bimage unbindTextureRepresentationFromCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE1];
		[bimage unlockTextureRepresentation];

		[image unbindTextureRepresentationFromCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0];
		[image unlockTextureRepresentation];
	}	
	else
		self.outputImage = nil;
	
	return YES;
}

- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx image:(id<QCPlugInInputImageSource>)image blurredImage:(id<QCPlugInInputImageSource>)blurredImage vibrance:(double)vibrance saturation:(double)saturation
{
	GLsizei width = [image imageBounds].size.width,	height = [image imageBounds].size.height;
	
	[pluginFBO pushAttributes:cgl_ctx];
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
    
	GLuint tex;
	glGenTextures(1, &tex);
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, tex);
	glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	
	[pluginFBO pushFBO:cgl_ctx];
	[pluginFBO attachFBO:cgl_ctx withTexture:tex width:width height:height];
	
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	glActiveTexture(GL_TEXTURE1);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, [blurredImage textureName]);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);	
	glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);	
	
	glActiveTexture(GL_TEXTURE0);
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, [image textureName]);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);	
	glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
	glDisable(GL_BLEND);
	
	// bind our shader program
	glUseProgramObjectARB([pluginShader programObject]);
	
	// set program vars
	glUniform1iARB([pluginShader getUniformLocation:"tex0"], 0); // load tex1 sampler to texture unit 0 
	glUniform1iARB([pluginShader getUniformLocation:"tex1"], 1); // load tex1 sampler to texture unit 0 
	glUniform1fARB([pluginShader getUniformLocation:"vibrance"], vibrance); // load tex1 sampler to texture unit 0 
	glUniform1fARB([pluginShader getUniformLocation:"saturation"], saturation); // load tex1 sampler to texture unit 0 
		
	// move to VA for rendering
	GLfloat tex_coords[] = 
	{
		1.0,1.0,
		0.0,1.0,
		0.0,0.0,
		1.0,0.0
	};
	
	GLfloat verts[] = 
	{
		width,height,
		0.0,height,
		0.0,0.0,
		width,0.0
	};
	
	glClientActiveTexture(GL_TEXTURE1);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );

	glClientActiveTexture(GL_TEXTURE0);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
	
	glEnableClientState(GL_VERTEX_ARRAY);		
	glVertexPointer(2, GL_FLOAT, 0, verts );
	glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );	// TODO: GL_QUADS or GL_TRIANGLE_FAN?
	
	// disable shader program
	glUseProgramObjectARB(NULL);
	
	[pluginFBO detachFBO:cgl_ctx];
	[pluginFBO popFBO:cgl_ctx];
	[pluginFBO popAttributes:cgl_ctx];
	return tex;
}					  
@end