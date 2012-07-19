//
//  v002LevelsPlugIn.m
//  v002 Color Correct
//
//  Created by vade on 5/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "v002LevelsPlugIn.h"

#define	kQCPlugIn_Name				@"v002 Levels"
#define	kQCPlugIn_Description		@"Photoshop style level control."

static void _TextureReleaseCallback(CGLContextObj cgl_ctx, GLuint name, void* info)
{
	glDeleteTextures(1, &name);
}

@implementation v002LevelsPlugIn

@dynamic inputImage;
@dynamic outputImage;
@dynamic inputInputMinAmount;
@dynamic inputInputMaxAmount;
@dynamic inputOutputMinAmount;
@dynamic inputOutputMaxAmount;
@dynamic inputMidPoint;

+ (NSDictionary*) attributes
{	
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey,
            [kQCPlugIn_Description stringByAppendingString:kv002DescriptionAddOnText], QCPlugInAttributeDescriptionKey,
            kQCPlugIn_Category, @"categories", nil];
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
	
	if([key isEqualToString:@"inputInputMinAmount"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Input Minimum", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeMaximumValueKey,
				nil];
	}

	if([key isEqualToString:@"inputInputMaxAmount"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Input Maximum", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeMaximumValueKey,
				nil];
	}

	if([key isEqualToString:@"inputOutputMinAmount"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Ouput Minimum", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	
	if([key isEqualToString:@"inputOutputMaxAmount"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Ouput Maximum", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	
	if([key isEqualToString:@"inputMidPoint"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Mid Point", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0.1], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:0.5], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:3.0], QCPortAttributeMaximumValueKey,
				nil];
	}
	
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
	return [NSArray arrayWithObjects:@"inputImage", @"inputInputMinAmount", @"inputInputMaxAmount", @"inputMidPoint", @"inputOutputMinAmount", @"inputOutputMaxAmount", nil];
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
		self.pluginShaderName = @"v002.Levels";
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

@implementation v002LevelsPlugIn (Execution)

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	CGColorSpaceRef cspace = ([self.inputImage shouldColorMatch]) ? [context colorSpace] : [self.inputImage imageColorSpace];
	
	if(self.inputImage && [self.inputImage lockTextureRepresentationWithColorSpace:cspace forBounds:[self.inputImage imageBounds]])
	{	
		[self.inputImage bindTextureRepresentationToCGLContext:[context CGLContextObj] textureUnit:GL_TEXTURE0 normalizeCoordinates:YES];
		
		
		GLuint finalOutput = [self renderToFBO:cgl_ctx image:self.inputImage inputMin:self.inputInputMinAmount inputMax:self.inputInputMaxAmount outputMin:self.inputOutputMinAmount outputMax:self.inputOutputMaxAmount midPoint:self.inputMidPoint];
		
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

- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx image:(id<QCPlugInInputImageSource>)image inputMin:(double)inMin inputMax:(double)inMax outputMin:(double)outMin outputMax:(double)outMax midPoint:(double)mid
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
	
	glUniform1fARB([pluginShader getUniformLocation:"inMin"], inMin); // load tex1 sampler to texture unit 0 
	glUniform1fARB([pluginShader getUniformLocation:"inMax"], inMax); // load tex1 sampler to texture unit 0 
	glUniform1fARB([pluginShader getUniformLocation:"midPoint"], mid); // load tex1 sampler to texture unit 0 
	glUniform1fARB([pluginShader getUniformLocation:"outMin"], outMin); // load tex1 sampler to texture unit 0 
	glUniform1fARB([pluginShader getUniformLocation:"outMax"], outMax); // load tex1 sampler to texture unit 0 
		
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
