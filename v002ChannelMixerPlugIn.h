//
//  v002_Color_CorrectPlugIn.h
//  v002 Color Correct
//
//  Created by vade on 5/23/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "v002MasterPluginInterface.h"

@interface v002ChannelMixerPlugIn : v002MasterPluginInterface
{
}

@property (assign) id<QCPlugInInputImageSource> inputImage;

@property (assign) double inputAmount;

@property (assign) double inputRedRed;
@property (assign) double inputRedGreen;
@property (assign) double inputRedBlue;

@property (assign) double inputGreenRed;
@property (assign) double inputGreenGreen;
@property (assign) double inputGreenBlue;

@property (assign) double inputBlueRed;
@property (assign) double inputBlueGreen;
@property (assign) double inputBlueBlue;


@property (assign) id<QCPlugInOutputImageProvider> outputImage;

@end

@interface v002ChannelMixerPlugIn (Execution)
- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx image:(id<QCPlugInInputImageSource>)image redVec:(CIVector*)red greenVec:(CIVector*)green blueVec:(CIVector*)blue amount:(double) amount;
@end