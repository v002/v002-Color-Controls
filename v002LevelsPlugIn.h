//
//  v002LevelsPlugIn.h
//  v002 Color Correct
//
//  Created by vade on 5/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>

#import "v002MasterPluginInterface.h"


@interface v002LevelsPlugIn : v002MasterPluginInterface
{

}
@property (assign) id<QCPlugInInputImageSource> inputImage;
@property (assign) id<QCPlugInOutputImageProvider> outputImage;

@property (assign) double inputInputMinAmount;
@property (assign) double inputInputMaxAmount;

@property (assign) double inputOutputMinAmount;
@property (assign) double inputOutputMaxAmount;

@property (assign) double inputMidPoint;


@end


@interface v002LevelsPlugIn (Execution)
- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx image:(id<QCPlugInInputImageSource>)image inputMin:(double)inMin inputMax:(double)inMax outputMin:(double)outMin outputMax:(double)outMax midPoint:(double)mid;
@end