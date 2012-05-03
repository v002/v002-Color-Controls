uniform vec3 red;
uniform vec3 green;
uniform vec3 blue;

uniform float amount;
// define our rectangular texture samplers 
uniform sampler2DRect tex0;

// define our varying texture coordinates 
varying vec2 texcoord0;

void main (void) 
{ 		
	vec4 input0 = texture2DRect(tex0, texcoord0);
		
	vec3 redchannel = vec3(input0.r) * red;
	vec3 greenchannel = vec3(input0.g) * green;
	vec3 bluechannel = vec3(input0.b) * blue;
	
	vec3 result = redchannel + greenchannel + bluechannel;
	
	gl_FragColor = mix(input0, vec4(result, input0.a), amount);

} 
