varying vec2 texcoord0;

uniform sampler2DRect tex0;
uniform float vibrance;

const vec4 lumcoeff = vec4(0.299,0.587,0.114, 0.);

void main(void)
{
	// step 1, get the current color
	vec4 color = texture2DRect(tex0, texcoord0);
	float luma = dot(color, lumcoeff);
	
	// 3 local mask, absdiff the two, get luma	
	vec4 mask = (color - vec4(luma));
	mask = clamp(mask, 0.0, 1.0);
	
	// 4, get the luma, use this to modulate the saturation and contrast amount.
	float lumaMask = dot(lumcoeff, mask);
	lumaMask = 1.0 - lumaMask;
	
	//vec4 saturation = mix(vec4(luma), color, 1.0 + saturation * lumaMask);
	
	vec4 vibrance = mix(vec4(luma), color, 1.0 + vibrance * lumaMask);
	
	
//	step 3 make a single channel mask from the difference blend mode of luma & color, and make it -> luma again
//	vec4 diff = abs(vec4(luma - color));
//	float mask = dot(lumcoeff, diff);
	
//	step 4, saturation via interpolation, using mask to modulate intensity.
//	vec4 saturation = mix(vec4(luma), color, 1.0 + (vibrance * mask));

	// mix the result based on the mask.
	gl_FragColor = vibrance; //mix(color, vibrance, lumaMask);

}
