shader_type canvas_item;

uniform vec2 offset;
uniform float alpha = 1.0;
uniform sampler2D text_img;
uniform float mult_size : hint_range( 0.01, 100 ) = 1.0;
uniform float fract_ampl : hint_range( 1.0, 10.0 ) = 2.0;
uniform float pattern_size : hint_range( 1.0, 30.0 ) = 8.0;
uniform float light_beam_size : hint_range( 0.0001, 0.02 ) = 0.01;
uniform float back_light_fact : hint_range( 0.1, 0.9 ) = 0.5;
uniform float time_mult : hint_range( 0.1, 0.9 ) = 0.4;
uniform	vec3 color_a : source_color = vec3( 0.047, 0.047, 0.322 );
uniform	vec3 color_b : source_color = vec3( 0.129, 0.039, 0.122);
uniform	vec3 param_c : source_color = vec3( 2.228, 0.0,0.0);
uniform	vec3 param_d : source_color = vec3( 0.377, 1.527,1.897);


vec3 getSceneColor(vec2 uv)
{
    return texture(text_img, uv).rgb;
}

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}




vec3 palette( float t, vec3 a, vec3 b, vec3 c, vec3 d){
	return a + b * cos(6.28318*(c*t*d));
}

// Called for every pixel the material is visible on.
void fragment() {
	//Init UV
	vec2 uv = (SCREEN_UV * 2.0)-1.0;
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	uv.x *= screen_size.x/screen_size.y ;
	uv *= mult_size;
	uv += offset;
	uv = mod(uv + vec2(1, 1), 2) - vec2(1, 1);
	vec2 uv0 = uv;
	
	

	
	
	//Colors
	vec3 final_color = vec3(0.0);
	
	// Itération for fractal pattern
	for(float f = 0.0; f< fract_ampl; f++){
		uv = fract(uv *1.5)-0.5;
		
		
		float local_dist = length(uv) * exp(-length(uv0));
		
		vec3 color = palette(length(uv0)+f*0.4+TIME*time_mult,color_a,color_b,param_c,param_d);
		
		local_dist = sin(local_dist*pattern_size+TIME*time_mult)/pattern_size;
		local_dist = abs(local_dist);
		local_dist = pow(light_beam_size / local_dist, back_light_fact);
		
		final_color += color * color * local_dist;
	}
	
	
    COLOR = vec4(final_color,alpha);
}




//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
