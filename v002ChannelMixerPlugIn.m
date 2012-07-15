//
//  v002_Color_CorrectPlugIn.m
//  v002 Color Correct
//
//  Created by vade on 5/23/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "v002ChannelMixerPlugIn.h"

#define	kQCPlugIn_Name				@"v002 Channel Mixer"
#define	kQCPlugIn_Description		@"Photoshop style channel mixing."


static void _TextureReleaseCallback(CGLContextObj cgl_ctx, GLuint name, void* info)
{
	glDeleteTextures(1, &name);
}

@implementation v002ChannelMixerPlugIn
@dynamic inputImage;
@dynamic outputImage;

@dynamic inputAmount;

@dynamic inputRedRed;
@dynamic inputRedGreen;
@dynamic inputRedBlue;
@dynamic inputGreenRed;
@dynamic inputGreenGreen;
@dynamic inputGreenBlue;
@dynamic inputBlueRed;
@dynamic inputBlueGreen;	
@dynamic inputBlueBlue;


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
		
	if([key isEqualToString:@"outputImage"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Image", QCPortAttributeNameKey,nil];
	}
	
	if([key isEqualToString:@"inputAmount"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Amount", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	
	if([key isEqualToString:@"inputRedRed"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Red Channel Red Mix", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:2.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	if([key isEqualToString:@"inputRedGreen"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Red Channel Green Mix", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:2.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	if([key isEqualToString:@"inputRedBlue"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Red Channel Blue Mix", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:2.0], QCPortAttributeMaximumValueKey,
				nil];
	}

	if([key isEqualToString:@"inputGreenRed"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Green Channel Red Mix", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:2.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	if([key isEqualToString:@"inputGreenGreen"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Green Channel Green Mix", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:2.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	if([key isEqualToString:@"inputGreenBlue"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Green Channel Blue Mix", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:2.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	
	if([key isEqualToString:@"inputBlueRed"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Blue Channel Red Mix", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:2.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	if([key isEqualToString:@"inputBlueGreen"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Blue Channel Green Mix", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:2.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	if([key isEqualToString:@"inputBlueBlue"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Blue Channel Blue Mix", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:-1.0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:2.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	
	
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
	return [NSArray arrayWithObjects:@"inputImage", @"inputAmount", @"inputRedRed", @"inputRedGreen", @"inputRedBlue", @"inputGreenRed", @"inputGreenGreen", @"inputGreenBlue", @"inputBlueRed", @"inputBlueGreen", @"inputBlueBlue", nil];
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
		self.pluginShaderName = @"v002.ChannelMixer";
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

@implementation v002ChannelMixerPlugIn (Execution)

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
		
	CGColorSpaceRef cspace = ([self.inputImage shouldColorMatch]) ? [context colorSpace] : [self.inputImage imageColorSpace];
	
	if(self.inputImage && [self.inputImage lockTextureRepresentationWithColorSpace:cspace forBounds:[self.inputImage imageBounds]])
	{	
		[self.inputImage bindTextureRepresentationToCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0 normalizeCoordinates:YES];
		
		// output our final image as a QCPluginOutputImageProvider using the QCPluginContext convinience method. No need to go through the trouble of making our own conforming object.	
		CIVector* redVec = [CIVector vectorWithX:self.inputRedRed Y:self.inputRedGreen Z:self.inputRedBlue];
		CIVector* greenVec = [CIVector vectorWithX:self.inputGreenRed Y:self.inputGreenGreen Z:self.inputGreenBlue];
		CIVector* blueVec = [CIVector vectorWithX:self.inputBlueRed Y:self.inputBlueGreen Z:self.inputBlueBlue];
		
		GLuint finalOutput = [self renderToFBO:cgl_ctx image:self.inputImage redVec:redVec greenVec:greenVec blueVec:blueVec amount:self.inputAmount];
		
#if __BIG_ENDIAN__
		id provider = [context outputImageProviderFromTextureWithPixelFormat:QCPlugInPixelFormatARGB8 pixelsWide:[self.inputImage imageBounds].size.width pixelsHigh:[self.inputImage imageBounds].size.height name:finalOutput flipped:NO releaseCallback:_TextureReleaseCallback releaseContext:NULL colorSpace:[context colorSpace] shouldColorMatch:[self.inputImage shouldColorMatch]];
#else
		id provider = [context outputImageProviderFromTextureWithPixelFormat:QCPlugInPixelFormatBGRA8 pixelsWide:[self.inputImage imageBounds].size.width pixelsHigh:[self.inputImage imageBounds].size.height name:finalOutput flipped:NO releaseCallback:_TextureReleaseCallback releaseContext:NULL colorSpace:[context colorSpace] shouldColorMatch:[self.inputImage shouldColorMatch]];
#endif
		
		if(provider == nil)
			return NO;
		
		self.outputImage = provider;
		
		[self.inputImage unbindTextureRepresentationFromCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0];
		[self.inputImage unlockTextureRepresentation];
	}	
	else
		self.outputImage = nil;
	
	return YES;
}

- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx image:(id<QCPlugInInputImageSource>)image redVec:(CIVector*)red greenVec:(CIVector*)green blueVec:(CIVector*)blue amount:(double) amount
{
	GLsizei width = [image imageBounds].size.width,	height = [image imageBounds].size.height;
	
    [pluginFBO pushAttributes:cgl_ctx];
    
    glEnable(GL_TEXTURE_RECTANGLE_EXT);

    GLuint fboTex = 0;
    glGenTextures(1, &fboTex);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, fboTex);
    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    [pluginFBO pushFBO:cgl_ctx];
    [pluginFBO attachFBO:cgl_ctx withTexture:fboTex width:width height:height];
    
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);	
	
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	glEnable(GL_TEXTURE_RECTANGLE_EXT);
	glBindTexture(GL_TEXTURE_RECTANGLE_EXT, [image textureName]);
	glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	// bind our shader program
	glUseProgramObjectARB([pluginShader programObject]);
	
	// set program vars
	glUniform1iARB([pluginShader getUniformLocation:"tex0"], 0); // load tex1 sampler to texture unit 0 

	glUniform1fARB([pluginShader getUniformLocation:"amount"], amount); // load tex1 sampler to texture unit 0 

	glUniform3fARB([pluginShader getUniformLocation:"red"], red.X, red.Y, red.Z); // load tex1 sampler to texture unit 0 
	glUniform3fARB([pluginShader getUniformLocation:"green"], green.X, green.Y, green.Z); // load tex1 sampler to texture unit 0 
	glUniform3fARB([pluginShader getUniformLocation:"blue"], blue.X, blue.Y, blue.Z); // load tex1 sampler to texture unit 0 
	
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
    
	return fboTex;
}					  
@end
