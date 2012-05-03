
varying vec2 texcoord0;
uniform float inMax;
uniform float inMin;
uniform float outMin;
uniform float outMax;
uniform float midPoint;

uniform sampler2DRect tex0;

void main(void)
{
	vec4 color = texture2DRect(tex0, texcoord0);
	
	vec4 inputRange = min(max(color - vec4(inMin), vec4(0.0)) / (vec4(inMax) - vec4(inMin)), vec4(1.0));
	inputRange = pow(inputRange, vec4(1.0 / (1.5 - midPoint)));
	    
	gl_FragColor = mix(vec4(outMin), vec4(outMax), inputRange);
	
	
}
