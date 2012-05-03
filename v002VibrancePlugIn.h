//
//  v002VibrancePlugIn.h
//  v002 Color Correct
//
//  Created by vade on 5/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "v002MasterPluginInterface.h"


@interface v002VibrancePlugIn : v002MasterPluginInterface
{

}

@property (assign) id<QCPlugInInputImageSource> inputImage;
@property (assign) id<QCPlugInOutputImageProvider> outputImage;

@property (assign) double inputVibrance;

@end

@interface v002VibrancePlugIn (Execution)
- (GLuint) renderToFBO:(CGLContextObj)cgl_ctx image:(id<QCPlugInInputImageSource>)image vibrance:(double)vibrance;
@end